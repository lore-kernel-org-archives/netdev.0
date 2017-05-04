From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: new warning at net/wireless/util.c:1236
Date: Thu, 04 May 2017 07:35:31 +0300
Message-ID: <87o9v99r3g.fsf@purkki.adurom.net>
References: <CA+55aFxyp5gpUZEYHXLwyhbK6DMWf4RoVykGxq9FPtO=j4yJsw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        Johannes Berg <johannes@sipsolutions.net>,
        Linux Wireless List <linux-wireless@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Luca Coelho <luciano.coelho@intel.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:58492 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752138AbdEDEfg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 4 May 2017 00:35:36 -0400
In-Reply-To: <CA+55aFxyp5gpUZEYHXLwyhbK6DMWf4RoVykGxq9FPtO=j4yJsw@mail.gmail.com>
        (Linus Torvalds's message of "Wed, 3 May 2017 19:28:29 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Linus Torvalds <torvalds@linux-foundation.org> writes:

> So my Dell XPS 13 seems to have grown a new warning as of the
> networking merge yesterday.
>
> Things still work, but when it starts warning, it generates a *lot* of
> noise (I got 36 of these within about ten minutes).
>
> I have no idea what triggered it, because when I rebooted (not because
> of this issue, but just to reboot into a newer kernel) I don't see it
> again.
>
> This is all pretty regular wireless - it's intel 8260 wireless in a
> fairly normal laptop.
>
> Things still seem to *work* ok, so the only problem here is the overly
> verbose and useless WARN_ON. It doesn't even print out *which* rate it
> is warning about, it just does that stupid unconditional WARN_ON()
> without ever shutting up about it..
>
> The WARN_ON() seems to be old, but my logs don't seem to have any
> mention of this until today, so there's something that has changed
> that now triggers it.
>
> Ideas?
>
>                   Linus
>
> ---
>
> WARNING: CPU: 3 PID: 1138 at net/wireless/util.c:1236
> cfg80211_calculate_bitrate+0x139/0x170 [cfg80211]

As this is with iwlwifi adding also Luca. There were some rate handling
changes in iwlwifi, like commit 77e409455f41, but don't know if that
could cause this.

-- 
Kalle Valo
