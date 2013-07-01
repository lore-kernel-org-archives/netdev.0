From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH] drivers/ptp/Kconfig: add "depends on HAS_IOMEM" for 'PTP_1588_CLOCK_PCH'
Date: Mon, 1 Jul 2013 13:19:09 +0200
Message-ID: <CAMuHMdXSExr0w-occZyHgj8o87q4_+BRH7e-bktMRfqfTqk8vQ@mail.gmail.com>
References: <51CB8CB7.6010006@asianux.com>
	<20130628.212311.1348427834856668120.davem@davemloft.net>
	<51D0DCB5.5060106@asianux.com>
	<51D11661.7040604@nod.at>
	<51D11D14.8000706@asianux.com>
	<51D122F0.1000204@nod.at>
	<51D12545.4000108@asianux.com>
	<CAMuHMdXnO8-9riLcFLQfMoWJRgy7gtQJdKkHZNR0D5eaM4=oxQ@mail.gmail.com>
	<51D1341E.6090908@asianux.com>
	<CAMuHMdVkVQvo0vAyHc8Cny7eCtWwcZGBWqK3dBS+ZEwNzhtHjw@mail.gmail.com>
	<51D1642F.9010303@nod.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Chen Gang <gang.chen@asianux.com>,
	David Miller <davem@davemloft.net>,
	Richard Cochran <richardcochran@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Richard Weinberger <richard@nod.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:61432 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753277Ab3GALTK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jul 2013 07:19:10 -0400
Received: by mail-pb0-f45.google.com with SMTP id mc8so4685204pbc.18
        for <netdev@vger.kernel.org>; Mon, 01 Jul 2013 04:19:09 -0700 (PDT)
In-Reply-To: <51D1642F.9010303@nod.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 1, 2013 at 1:12 PM, Richard Weinberger <richard@nod.at> wrote:
> Am 01.07.2013 09:56, schrieb Geert Uytterhoeven:
>> If we follow your reasoning, we can add dummy variants of all hardware support
>> that lives in arch/*/include/asm to asm-generic, so everything would compile
>> for all platforms. But that's now what we want.
>
> I hope you meant *not* want?

Sorry, s/now/not/

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
