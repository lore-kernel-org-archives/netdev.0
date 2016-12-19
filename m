From: =?utf-8?B?TWljaGHFgiBLxJlwaWXFhA==?= <kernel@kempniu.pl>
Subject: Re: "rfkill: Add rfkill-any LED trigger" causes deadlock
Date: Mon, 19 Dec 2016 15:01:15 +0100
Message-ID: <20161219140115.GA18194@kmp-mobile.hq.kempniu.pl>
References: <20161216163707.GA2629@gmail.com>
 <CACpa5=_chGuU3zVcVR3nkNySwz1cGAQTs39v+BjwcDNSvOqhTw@mail.gmail.com>
 <1482137772.31461.1.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: =?utf-8?B?0JzQuNGF0LDQuNC7INCa0YDQuNC90LrQuNC9?=
        <krinkin.m.u@gmail.com>, linux-wireless@vger.kernel.org,
        davem@davemloft.net, netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f44.google.com ([209.85.215.44]:32859 "EHLO
        mail-lf0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754686AbcLSOBW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2016 09:01:22 -0500
Received: by mail-lf0-f44.google.com with SMTP id c13so54623997lfg.0
        for <netdev@vger.kernel.org>; Mon, 19 Dec 2016 06:01:21 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1482137772.31461.1.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mike, Johannes, sorry for the trouble caused.

> Thanks for the report. I'm sorry I missed this in review - obviously we
> can't call something that acquires the mutex from rfkill_set_sw_state()
> which clearly states, in the documentation:
> 
>  * This function can be called in any context, even from within rfkill
>  * callbacks.

Drat, I missed that, sorry.

> I've reverted the change (and the follow-up fix) now.

Just to ensure things get cleaned up properly, as of now it looks like
you only reverted patch 2/2 of my v2 and Arnd's fix to patch 1/2, not
patch 1/2 itself.

> Michał, if you want to resubmit with this fixed, please also make sure
> you don't reintroduce the unused label warning and have the appropriate
> #ifdef that Arnd had later added for your change.

Noted, thanks.  I will post v3 once I figure out how to handle locking
properly.

-- 
Best regards,
Michał Kępień
