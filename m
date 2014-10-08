From: Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH] net: description of dma_cookie cause make xmldocs warning
Date: Wed, 8 Oct 2014 08:16:16 -0700
Message-ID: <CAPcyv4hn7oJ7tpZFX9GDOpRku_w=CA0rhU+r=_dn_xYyn3_kCg@mail.gmail.com>
References: <1412780019-32475-1-git-send-email-standby24x7@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Masanari Iida <standby24x7@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:43236 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750858AbaJHPQR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2014 11:16:17 -0400
Received: by mail-ig0-f174.google.com with SMTP id a13so2225634igq.7
        for <netdev@vger.kernel.org>; Wed, 08 Oct 2014 08:16:17 -0700 (PDT)
In-Reply-To: <1412780019-32475-1-git-send-email-standby24x7@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 8, 2014 at 7:53 AM, Masanari Iida <standby24x7@gmail.com> wrote:
> In commit 7bced397510ab569d31de4c70b39e13355046387,
> dma_cookie was removed from struct skbuff.
> But the description of dma_cookie still exist.
> So the "make xmldocs" output following warning.
>
> Warning(.//include/linux/skbuff.h:609): Excess struct/union
> /enum/typedef member 'dma_cookie' description in 'sk_buff'
>
> Remove description of dma_cookie fix the symptom.
>
> Signed-off-by: Masanari Iida <standby24x7@gmail.com>

Acked-by: Dan Williams <dan.j.williams@intel.com>
