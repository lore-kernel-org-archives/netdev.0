From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH] fec: Remove unneeded asm header files
Date: Thu, 18 Apr 2013 09:42:09 -0300
Message-ID: <CAOMZO5CDi67MGd0Du+bM7FR8RGDf8rVMZJQuq_8B2A-qd3W7EQ@mail.gmail.com>
References: <1366251498-11677-1-git-send-email-festevam@gmail.com>
	<516FE05A.2030604@uclinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Fabio Estevam <fabio.estevam@freescale.com>
To: Greg Ungerer <gerg@uclinux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:51464 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756565Ab3DRMmK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 08:42:10 -0400
Received: by mail-vc0-f174.google.com with SMTP id kw10so2430482vcb.33
        for <netdev@vger.kernel.org>; Thu, 18 Apr 2013 05:42:09 -0700 (PDT)
In-Reply-To: <516FE05A.2030604@uclinux.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Greg,

On Thu, Apr 18, 2013 at 9:00 AM, Greg Ungerer <gerg@uclinux.org> wrote:

> fec_main.c?  That doesn't exist in linux-3.9-rc7.
> Comments and tests below based on fec.c in linux-3.9-rc7.

Yes, fec.c  got was renamed to fec_main.c in net-next:
https://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/tree/drivers/net/ethernet/freescale/fec_main.c

>> -#include <asm/cacheflush.h>
>
> There is a rather bogus looking call to flush_cache_all() conditional
> on CONFIG_M532x, and I suspect removing this include will break that.

Ok, will keep <asm/cacheflush.h> in v2 then.

>> -#ifndef CONFIG_ARM
>> -#include <asm/coldfire.h>
>> -#include <asm/mcfsim.h>
>> -#endif
>
> No problem with this part. I compiled for a couple of ColdFire targets
> and this is ok.

Thanks for testing, Greg.

Regards,

Fabio Estevam
