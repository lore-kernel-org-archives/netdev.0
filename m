From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: binding UDP port 0 with SO_REUSEADDR
Date: Wed, 01 Aug 2012 21:02:56 +0200
Message-ID: <1343847776.21269.797.camel@edumazet-glaptop>
References: <CAEZM=bNdyZoTiGYwNM_3v+ro7dEn0q9aTo4040tBDqDSH3HOXg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Tobias S. Josefowitz" <t.josefowitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:65327 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754421Ab2HATDA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Aug 2012 15:03:00 -0400
Received: by weyx8 with SMTP id x8so5319566wey.19
        for <netdev@vger.kernel.org>; Wed, 01 Aug 2012 12:02:59 -0700 (PDT)
In-Reply-To: <CAEZM=bNdyZoTiGYwNM_3v+ro7dEn0q9aTo4040tBDqDSH3HOXg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-08-01 at 13:36 +0200, Tobias S. Josefowitz wrote:
> Hey all,
> 
> I recently noticed that binding UDP port 0 with SO_REUSEADDR yields
> unexpected results for me - the kernel occasionally gives out UDP
> ports used by other processes, if they were bound with SO_REUSEADDR,
> too.
> 
> I did some digging, it seems that
> f24d43c07e208372aa3d3bff419afbf43ba87698 introduced this behaviour.
> I'm not at all sure if this could/should be called a bug, but I need
> to say, it was severly unexpected at my side, and that probably goes
> for others, too.
> 
> Just bringing this to your attention, I have no suggestions on it whatsoever.

And why are you using SO_REUSEADDR on UDP unicast sockets ?

I mean, this is exactly saying " By using this REUSEADDR, I am allowing
this port being used by another process, even from another user"
