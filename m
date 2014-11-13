From: Javier Martinez Canillas <javier@dowhile0.org>
Subject: Re: [PATCH] smsc911x: power-up phydev before doing a software reset.
Date: Thu, 13 Nov 2014 09:27:39 +0100
Message-ID: <CABxcv=n0u2dvRyFr_dWXQaJpEMa2-9ZWGMSDaTYVr907SjX8ew@mail.gmail.com>
References: <1415643789-5367-1-git-send-email-eballetbo@iseebcn.com>
	<20141111.183042.469456165241690341.davem@davemloft.net>
	<CAFqH_50cpvdvCgD-=HQDZ1OT9vmzWkExNHzoASNaruSKLnJZBA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Steve Glendinning <steve.glendinning@shawell.net>,
	Enrico Butera <ebutera@gmail.com>
To: Enric Balletbo Serra <eballetbo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f41.google.com ([74.125.82.41]:55978 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751013AbaKMI1l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2014 03:27:41 -0500
Received: by mail-wg0-f41.google.com with SMTP id l18so737728wgh.14
        for <netdev@vger.kernel.org>; Thu, 13 Nov 2014 00:27:39 -0800 (PST)
In-Reply-To: <CAFqH_50cpvdvCgD-=HQDZ1OT9vmzWkExNHzoASNaruSKLnJZBA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Enric,

On Thu, Nov 13, 2014 at 8:57 AM, Enric Balletbo Serra
<eballetbo@gmail.com> wrote:
>
> Yes, I'm agree. I'll send version 2 of the patch changing this. Also
> there are other places that use the mdelay family intead of
> usleep_range() and can only be invoked from process context. Maybe
> would be interesting send another patch changing this.
>

Agreed, that could be a separate patch though.

Also there is a mdelay(100) before enabling energy detect mode in
smsc911x_phy_enable_energy_detect() which I believe can be removed.

Best regards,
Javier
