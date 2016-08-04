From: "Niklas =?iso-8859-1?Q?S=F6derlund?=" <niklas.soderlund@ragnatech.se>
Subject: Re: [PATCH 1/2] ravb: use SET_RUNTIME_PM_OPS macro
Date: Thu, 4 Aug 2016 17:28:14 +0200
Message-ID: <20160804152814.GQ3672@bigcity.dyn.berto.se>
References: <20160803135647.23242-1-niklas.soderlund+renesas@ragnatech.se>
 <20160803135647.23242-2-niklas.soderlund+renesas@ragnatech.se>
 <CAMuHMdU-czrkroEKkWg-WFJ7ayqhGntDtuaRXFoyQnm_wDdxvw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux-Renesas <linux-renesas-soc@vger.kernel.org>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	"David S. Miller" <davem@davemloft.net>,
	Wolfram Sang <wsa@the-dreams.de>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f53.google.com ([209.85.215.53]:35343 "EHLO
	mail-lf0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756395AbcHDPaF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Aug 2016 11:30:05 -0400
Received: by mail-lf0-f53.google.com with SMTP id f93so184672138lfi.2
        for <netdev@vger.kernel.org>; Thu, 04 Aug 2016 08:28:17 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAMuHMdU-czrkroEKkWg-WFJ7ayqhGntDtuaRXFoyQnm_wDdxvw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2016-08-04 15:33:18 +0200, Geert Uytterhoeven wrote:
> On Wed, Aug 3, 2016 at 3:56 PM, Niklas Söderlund
> <niklas.soderlund+renesas@ragnatech.se> wrote:
> > Use macro to define the runtime PM operations.
> >
> > Signed-off-by: Niklas Söderlund <niklas.soderlund+renesas@ragnatech.se>
> 
> Duplicate of  commit 524c6f691b99065577b245b250efe93fb0cda5c4
> Author: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
> Date:   Mon May 30 05:25:43 2016 +0900
> 
>     ravb: Add SET_RUNTIME_PM_OPS macro
> 
>     Use SET_RUNTIME_PM_OPS macro instead of assigning a member of
>     dev_pm_ops directly.
> 
>     Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
>     Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>
>     Acked-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>

Wops, I will drop my commit then. Thanks for pointing it out.

> 
> Gr{oetje,eeting}s,
> 
>                         Geert
> 
> --
> Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org
> 
> In personal conversations with technical people, I call myself a hacker. But
> when I'm talking to journalists I just say "programmer" or something like that.
>                                 -- Linus Torvalds

-- 
Regards,
Niklas Söderlund
