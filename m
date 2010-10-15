From: "Gerd v. Egidy" <lists@egidy.de>
Subject: Re: -j MARK in raw vs. mangle (was Re: xfrm by MARK: tcp problems when mark for in and out differ)
Date: Fri, 15 Oct 2010 10:05:32 +0200
Message-ID: <201010151005.32973.lists@egidy.de>
References: <201010141616.58795.lists@egidy.de> <4CB7FCEB.5070804@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rs02.intra2net.com ([81.169.173.116]:52743 "EHLO
	rs02.intra2net.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752314Ab0JOIFg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Oct 2010 04:05:36 -0400
In-Reply-To: <4CB7FCEB.5070804@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Patrick,

> > So it seems this has nothing to do with xfrm, but that the MARK target
> > has different effects when used in raw than in mangle. I was using raw
> > because I had to set conntrack zones too and it was more conveniant to
> > do both in one place.
> > 
> > Can one of the netfilter guys comment on this? Is using MARK in raw not
> > fully supported or has known deficiencies?
> 
> No, the problem is most likely that for outgoing packets, the XFRM
> lookup is done with the route lookup before the packet is even sent,
> so once it hits the raw or mangle table, it is too late. mangle however
> performs rerouting when the mark value changes, at which point a new
> XFRM lookup is performed.

ah, this would explain it. Thanks for the explanation. I'll just stick with 
mangle for marking.

Kind regards,

Gerd

-- 
Address (better: trap) for people I really don't want to get mail from:
jonas@cactusamerica.com
