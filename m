From: Julian Anastasov <ja@ssi.bg>
Subject: Re: Bug? ARP with wrong src IP address
Date: Thu, 24 Jul 2003 19:32:55 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0307241922270.10460-100000@l>
References: <200307241804140253.00527C89@192.168.128.16>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Bart De Schuymer <bdschuym@pandora.be>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Carlos Velasco <carlosev@newipnet.com>
In-Reply-To: <200307241804140253.00527C89@192.168.128.16>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

On Thu, 24 Jul 2003, Carlos Velasco wrote:

> This would be another approach, configuring the IP address on the 
> ethernet interface (ex. eth0:2) and not advertising or replying arp with 
> the hidden patch.
> However the usual approach is configuring the destination IP address on 
> a loopback interface that does real "hiding" as it's no more in ethernet 
> interface.

	The Linux concept differs. As for hidden, it works for 
different interface, not for the one where the probe is received. The 
alias names do not play here.

> As long as I know, Solaris 8 and Windows 2000 have no problems with the 
> ARP Request, as they use the src IP address of the ethernet interface. 
> But as I have seen in the RFC it seems that Cisco devices should reply 
> to this ARP request without looking into the source ip address.

	There are some exceptions for the src IP. Even Linux will
not reply if the src IP in incoming probe matches local IP. But
may be only Linux preserves the src IP in outgoing probes.

Regards

--
Julian Anastasov <ja@ssi.bg>
