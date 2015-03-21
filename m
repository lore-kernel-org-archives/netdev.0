From: Fabio Estevam <festevam@gmail.com>
Subject: Re: Bug in drivers/net/ethernet/freescale/fec_main.c, TX is broken.
 In 4.0.0-rc3
Date: Sat, 21 Mar 2015 19:35:30 -0300
Message-ID: <CAOMZO5BnPQTFoBRr4EGH24_yZZAY6NJmVFg4WeiJcTqrYqki5A@mail.gmail.com>
References: <390621425930628@web28o.yandex.ru>
	<3625951426018334@web26j.yandex.ru>
	<BLUPR03MB373A446E2D97992CA7AAA32F5020@BLUPR03MB373.namprd03.prod.outlook.com>
	<726281426513068@web10o.yandex.ru>
	<BLUPR03MB3739B9C6E14A106CCAEBA32F5020@BLUPR03MB373.namprd03.prod.outlook.com>
	<994171426532944@web7m.yandex.ru>
	<20150321205359.GM8656@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: =?UTF-8?B?0J/QsNC90L7QsiDQkNC90LTRgNC10Lk=?= <rockford@yandex.ru>,
	"fugang.duan@freescale.com" <fugang.duan@freescale.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-arm-kernel <linux-arm-kernel@lists.infradead.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f48.google.com ([209.85.215.48]:36375 "EHLO
	mail-la0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751403AbbCUWfb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2015 18:35:31 -0400
Received: by labe2 with SMTP id e2so34725980lab.3
        for <netdev@vger.kernel.org>; Sat, 21 Mar 2015 15:35:30 -0700 (PDT)
In-Reply-To: <20150321205359.GM8656@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Russell,

On Sat, Mar 21, 2015 at 5:53 PM, Russell King - ARM Linux
<linux@arm.linux.org.uk> wrote:

> Given that this bug can seriously screw data up in undetectable ways (TCP
> checksums don't save you, because the FEC generates them on the data which
> it read from memory, even if it happened to read the data from the SoC's
> boot ROM) we do need to get this fixed ASAP.

Current mainline has 2b995f63987013 reverted, so 4.0-rc5 will not have
this corruption problem.

Regards,

Fabio Estevam
