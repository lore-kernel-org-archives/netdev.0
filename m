From: Glen Turner <gdt@gdt.id.au>
Subject: Re: UDP path MTU discovery
Date: Fri, 02 Apr 2010 16:11:58 +1030
Message-ID: <1270186918.2119.27.camel@ilion>
References: <1269561751.2891.8.camel@ilion>
	 <877how25kx.fsf@basil.nowhere.org> <4BB0DCF6.9020401@hp.com>
	 <1270078984.2389.33.camel@ilion>
	 <20100401005539.GZ20695@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hp.com>, netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eth6445.sa.adsl.internode.on.net ([150.101.30.44]:58648 "EHLO
	aix.gdt.id.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754426Ab0DBFkp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Apr 2010 01:40:45 -0400
In-Reply-To: <20100401005539.GZ20695@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-04-01 at 02:55 +0200, Andi Kleen wrote:
> > What we need is an API for an instant notification that a ICMP Packet
> > Too Big message has arrived concerning the socket.
> 
> That already exists of course: IP_RECVERR

Hi Andi,

So what should I code?  The suggested EMSGSIZE or your suggestion
of grabbing all returning ICMP and parsing it?  Noting that the
second choice is pretty ugly.  That both seem specific to Linux is
frustrating, but that is life -- adding support for an operating
system seems to inevitably add #ifdefs for this sort of code.

Let me know and I'll code it into FreeRADIUS and radsecproxy and
I'll see how they go with 802.1x requests over IPv6.

Thanks so much for your time, Glen

-- 
 Glen Turner
 www.gdt.id.au/~gdt

