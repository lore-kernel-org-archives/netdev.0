From: David Dillow <dave@thedillows.org>
Subject: Re: [0/3] mc_filter on big-endian arch
Date: 12 Jun 2004 23:01:56 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1087095716.4085.4.camel@ori.thedillows.org>
References: <OF72A3CA91.7584BEA0-ON88256EAF.001F34CA-88256EAF.001F8BE8@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, Jeff Garzik <jgarzik@pobox.com>,
        Netdev <netdev@oss.sgi.com>, Roger Luethi <rl@hellgate.ch>
Return-path: <netdev-bounce@oss.sgi.com>
To: David Stevens <dlstevens@us.ibm.com>
In-Reply-To: <OF72A3CA91.7584BEA0-ON88256EAF.001F34CA-88256EAF.001F8BE8@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2004-06-10 at 01:45, David Stevens wrote:
> PS - Here's a trivial program that will join a group. If you run this on
> one side, then a ping to the multicast address will work when it's in
> the group, and stop answering when it exits. There are more general
> things that have been around for years for testing-- I just threw this
> together just now. (I hope it doesn't have any bugs! :-) ) Should be
> suitable for testing hardware multicast address filters...

Thank you for sending this program; it saved me having to write my own,
and it helped me to demonstrate that multicast already works properly
under typhoon. As it turns out, my copy of tcpdump was turning on
ALL_MULTI on the interface, even with "-p", and the NIC was responding
appropriately. So the multicast packets I saw coming in were legitimate.

So, summary, typhoon multicast is OK, on both big and little endian
machines.

Roger, thanks for spurring me to finally test this.

Dave
