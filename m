From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] tulip: Support for byte queue limits
Date: Fri, 12 Jul 2013 06:39:45 -0700
Message-ID: <1373636385.10804.5.camel@edumazet-glaptop>
References: <20130712132054.16269.qmail@science.horizon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: grundler@parisc-linux.org, netdev@vger.kernel.org
To: George Spelvin <linux@horizon.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:58606 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964827Ab3GLNjr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jul 2013 09:39:47 -0400
Received: by mail-pa0-f44.google.com with SMTP id lj1so9028944pab.17
        for <netdev@vger.kernel.org>; Fri, 12 Jul 2013 06:39:47 -0700 (PDT)
In-Reply-To: <20130712132054.16269.qmail@science.horizon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-07-12 at 09:20 -0400, George Spelvin wrote:
> The New Hotness of fq_codel wants bql support, but my WAN link is on my
> Old And Busted tulip card, which lacks it.
> 
> It's just a few lines, but the important thing is knowing where to
> put them, and I've sort of guessed.  In particular, it seems like the
> netdev_sent_queue call could be almost anywhere in tulip_start_xmit and
> I'm not sure if there are reasons to prefer any particular position.
> 
> (You may have my S-o-b on copyright grounds, but I'd like to test it
> some more before declaring this patch ready to be merged.)

Seems fine to me.

You might wait before David Miller re-opens net-next for new
submissions, a bit after linux-3.11-rc1 is released, before
sending an official patch.

Thanks
