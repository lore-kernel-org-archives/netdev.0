From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: Output on raw sockets ignores IP_DF when packet is bigger than
 pmtu
Date: Thu, 6 Mar 2003 10:30:33 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0303061025210.9448-100000@dyn9-47-18-140.beaverton.ibm.com>
References: <03030611014533.2221238e.7643064@psc.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: NETDEV@oss.sgi.com, <RREDDY@vms.psc.edu>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Raghurama 'REDDY'" <rreddy@psc.edu>
In-Reply-To: <03030611014533.2221238e.7643064@psc.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 6 Mar 2003, Raghurama 'REDDY' wrote:

> Is there a way to get the host to not fragment when IP_DF is set,
> iresspective what the pmtu is?

You can disable pmtu discovery on a socket using the IP level socket option 
IP_MTU_DISCOVER.

System wide pmtu discovery can be disabled by setting 
	/proc/sys/net/ipv4/ip_no_pmtu_disc

-Sridhar
