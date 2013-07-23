From: Peter Wu <lekensteyn@gmail.com>
Subject: Re: r8169: remove "PHY reset until link up" log spam
Date: Tue, 23 Jul 2013 22:59:18 +0200
Message-ID: <1419387.TRpCvQXgeS@al>
References: <4961229.bXDGvH0dpz@al> <2856794.AWy189S2qk@al> <20130723202340.GB31567@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	nic_swsd@realtek.com
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f169.google.com ([74.125.82.169]:35442 "EHLO
	mail-we0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756516Ab3GWU7Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 16:59:24 -0400
Received: by mail-we0-f169.google.com with SMTP id n57so7683220wev.0
        for <netdev@vger.kernel.org>; Tue, 23 Jul 2013 13:59:22 -0700 (PDT)
In-Reply-To: <20130723202340.GB31567@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 23 July 2013 22:23:40 Francois Romieu wrote:
> Peter Wu <lekensteyn@gmail.com> :
> [...]
> 
> > Which user wants to get log spam every ten seconds ?
> 
> In my world users - be they big workstations or runtime pm enabled
> laptops - may not even care about log [1].
So I am not a real user either because I keep journalctl open / tailf log 
files? I see what you are trying to note, but I doubt the usefulness of this 
specific message. This message appears if:
 (1) The device has just been brought up.
 (2) Has not been connected before while being up.
 (3) Is enabled all the time (runtime PM?)
 (4) No reset it pending.

Only the last point cannot easily be determine from a log context, but these 
do not seem to appear on recent devices? (I've never experienced link issues 
with Realtek Ethernet cards, wireless is another thing)

> > This message was added almost ten years ago, Realtek must
> > certainly have improved their hardware not to be so crappy ?
> 
> With due respect to Realtek, git log or Realtek's own Release.txt file
> do not exactly paint the world as a faery of unicorns.
Or even using the file header as revision log... anyway, you cannot make money 
by selling just crap right? There is enough competition on this market.

Regards,
Peter
