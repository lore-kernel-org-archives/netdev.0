From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH] drivers/ptp/Kconfig: add "depends on HAS_IOMEM" for 'PTP_1588_CLOCK_PCH'
Date: Thu, 27 Jun 2013 08:48:26 +0200
Message-ID: <CAMuHMdVY07PmR-qY-cfgd6X+zHM30oAFMd6oMRZ1NOvXcDS8YQ@mail.gmail.com>
References: <51CB8CB7.6010006@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Richard Cochran <richardcochran@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Richard Weinberger <richard@nod.at>
To: Chen Gang <gang.chen@asianux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:45014 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752462Ab3F0Gs1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jun 2013 02:48:27 -0400
Received: by mail-pb0-f47.google.com with SMTP id rr13so492760pbb.34
        for <netdev@vger.kernel.org>; Wed, 26 Jun 2013 23:48:26 -0700 (PDT)
In-Reply-To: <51CB8CB7.6010006@asianux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 27, 2013 at 2:52 AM, Chen Gang <gang.chen@asianux.com> wrot=
e:
> The related driver need depend on HAS_IOMEM, or may be built under UM=
L
> architecture.
>
> The related error (with allmodconfig, without pcap):
>
>     CC [M]  drivers/ptp/ptp_pch.o
>   drivers/ptp/ptp_pch.c: In function =E2=80=98pch_remove=E2=80=99:
>   drivers/ptp/ptp_pch.c:571:3: error: implicit declaration of functio=
n =E2=80=98iounmap=E2=80=99 [-Werror=3Dimplicit-function-declaration]
>   drivers/ptp/ptp_pch.c: In function =E2=80=98pch_probe=E2=80=99:
>   drivers/ptp/ptp_pch.c:621:2: error: implicit declaration of functio=
n =E2=80=98ioremap=E2=80=99 [-Werror=3Dimplicit-function-declaration]
>   drivers/ptp/ptp_pch.c:621:13: warning: assignment makes pointer fro=
m integer without a cast [enabled by default]
>   cc1: some warnings being treated as errors
>
> Signed-off-by: Chen Gang <gang.chen@asianux.com>

Acked-by: Geert Uytterhoeven <geert@linux-m68k.org>

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-=
m68k.org

In personal conversations with technical people, I call myself a hacker=
=2E But
when I'm talking to journalists I just say "programmer" or something li=
ke that.
                                -- Linus Torvalds
