From: Andreas Mohr <andi@lisas.de>
Subject: Re: [PATCH] Fix Micrel KSZ8842 Kconfig description
Date: Fri, 21 Aug 2009 12:46:06 +0200
Message-ID: <20090821104606.GA13440@rhlx01.hs-esslingen.de>
References: <20090821102033.GA26577@rhlx01.hs-esslingen.de> <4A8E78C1.20409@mocean-labs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andreas Mohr <andi@lisas.de>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
To: Richard =?iso-8859-1?Q?R=F6jfors?=
	<richard.rojfors.ext@mocean-labs.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhlx01.hs-esslingen.de ([129.143.116.10]:55217 "EHLO
	rhlx01.hs-esslingen.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751434AbZHUKqE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Aug 2009 06:46:04 -0400
Content-Disposition: inline
In-Reply-To: <4A8E78C1.20409@mocean-labs.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Fri, Aug 21, 2009 at 12:36:49PM +0200, Richard R=F6jfors wrote:
> Andreas Mohr wrote:
>> Hi,
>>
>> when doing a "make oldconfig" recently, non-descriptive item "Micrel=
 KSZ8842"
>> came up, and when I hit "?" to get more info, all I got was a tight-=
lipped
>> "This platform driver is for Micrel KSZ8842 chip.".
>
> I see your pain

Thanks, and very fast reply too :)

> Remove "PCI-based"
>
> This is a platform device, it is not PCI based.
> The KS8842 can sit behind PCI, ISA or VLB, this driver basically =20
> supports the ISA mappings.
>
> --Richard

OK, I had added that because manufacturer specifications seemed to sugg=
est
PCI use only. "platform device" should have been a warning sign I guess=
=2E..


Signed-off-by: Andreas Mohr <andi@lisas.de>

--- linux-2.6.31-rc6/drivers/net/Kconfig.orig	2009-08-21 12:00:31.00000=
0000 +0200
+++ linux-2.6.31-rc6/drivers/net/Kconfig	2009-08-21 12:41:48.000000000 =
+0200
@@ -1727,7 +1727,8 @@ config KS8842
 	tristate "Micrel KSZ8842"
 	depends on HAS_IOMEM
 	help
-	  This platform driver is for Micrel KSZ8842 chip.
+	  This platform driver is for Micrel KSZ8842 / KS8842
+	  2-port ethernet switch chip (managed, VLAN, QoS).
=20
 config KS8851
        tristate "Micrel KS8851 SPI"
