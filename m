From: "David S. Miller" <davem@redhat.com>
Subject: Re: Route cache performance under stress
Date: Tue, 10 Jun 2003 08:49:40 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030610.084940.74727904.davem@redhat.com>
References: <008001c32eda$56760830$4a00000a@badass>
	<20030609195652.E35696@shell.cyberus.ca>
	<Pine.LNX.4.51.0306092006420.12038@ns.istop.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@shell.cyberus.ca, xerox@foonet.net, sim@netnation.com,
   fw@deneb.enyo.de, netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: ralph+d@istop.com, ralph@istop.com
In-Reply-To: <Pine.LNX.4.51.0306092006420.12038@ns.istop.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Ralph Doncaster <ralph@istop.com>
   Date: Mon, 9 Jun 2003 20:32:48 -0400 (EDT)
   
   Lastly from the software side Linux doesn't seem to have anything like
   BSD's parameter to control user/system CPU sharing.  Once my CPU load
   reaches 70-80%, I'd rather have some dropped packets than let the CPU hit
   100% and end up with my BGP sessions drop.

When packet (more specifically, software interrupt) processing
reaches a certain level, we offload the work into process context.
