From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] [NET]: Supporting UDP-Lite (RFC 3828) in Linux
Date: Fri, 10 Nov 2006 14:38:46 -0800 (PST)
Message-ID: <20061110.143846.93212026.davem@davemloft.net>
References: <200611101609.21333@strip-the-willow>
	<20061110093715.0aadd791@freekitty>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gerrit@erg.abdn.ac.uk, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:3305
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1424456AbWKJWio (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Nov 2006 17:38:44 -0500
To: shemminger@osdl.org
In-Reply-To: <20061110093715.0aadd791@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Fri, 10 Nov 2006 09:37:15 -0800

> On Fri, 10 Nov 2006 16:09:20 +0000
> Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> 
> > [NET/IPv4]: Support for the UDP-Lite protocol (RFC 3828)
> > 
> > This adds support for UDP-Lite to the IPv4 stack, provided as an extension
> > to the existing UDPv4 code:
> > 	* generic routines are all located in net/ipv4/udp.c
> > 	* UDP-Lite specific routines are in net/ipv4/udplite.c
> > 	* MIB/statistics support in /proc/net/snmp and /proc/net/udplite
> > 	* shared API with extensions for partial checksum coverage
> > 	* consolidation of shared code
> > 
> > 
> 
> This code is does too much inlining (like existing network code).
> Should it be made configurable?

It doesn't get built at all if you check his patches :-)

But once that's fixed up, I think we can fix that with a followon
patch.  We've put Gerrit through the ringer enough on this stuff.
