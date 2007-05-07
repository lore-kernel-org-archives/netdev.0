From: "Alexey Zaytsev" <alexey.zaytsev@gmail.com>
Subject: Re: [PATCH 2/3] ARM: include IXP4xx "fuses" support
Date: Mon, 7 May 2007 09:24:48 +0400
Message-ID: <f19298770705062224v5f60535bn7dfce17f4a5e04f@mail.gmail.com>
References: <m3abwhcy74.fsf@maximus.localdomain>
	 <m3wszlbiom.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Jeff Garzik" <jeff@garzik.org>,
	"Russell King" <rmk@arm.linux.org.uk>,
	lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.arm.linux.org.uk
To: "Krzysztof Halasa" <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.234]:47575 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754012AbXEGFYt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 May 2007 01:24:49 -0400
Received: by wr-out-0506.google.com with SMTP id 76so1469663wra
        for <netdev@vger.kernel.org>; Sun, 06 May 2007 22:24:49 -0700 (PDT)
In-Reply-To: <m3wszlbiom.fsf@maximus.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello, Krzysztof.

On 5/7/07, Krzysztof Halasa <khc@pm.waw.pl> wrote:
...
> +                                IXP4XX_FUSE_RSA |                      \
> +                                IXP4XX_FUSE_XSCALE_MAX_FREQ)
> +

#ifndef __ASSEMBLY__

> +static inline u32 ixp4xx_read_fuses(void)
> +{
> +       unsigned int fuses = ~*IXP4XX_EXP_CFG2;
...
> +       fuses &= ~IXP4XX_FUSE_RESERVED;
> +}

#endif /* __ASSEMBLY__ */

> +
>  #endif


Are you sure this is the version you wanted to send? I don't see how this could
compile without this #ifndef. And also there is some problem with undefined
processor_id, but this is not your fault, but a flaw in the pre-rc1
kernel, which
I hope is now noticed. So maybe you should just send the patches made for
the 2.6.21 kernel?

Otherwise, when applied on top of my 2.6.20 kernel, the driver just
works (at least
I see the pings, haven't considered any other tests yet), thank you a lot!
