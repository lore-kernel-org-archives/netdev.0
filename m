From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 7/8] isdn: replace CONFIG_8xx by CONFIG_PPC_8xx
Date: Thu, 12 Mar 2015 21:52:56 +0300
Message-ID: <5501E088.6020502@cogentembedded.com>
References: <20150312152409.E7B5C1A2422@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	user-mode-linux-devel@lists.sourceforge.net,
	user-mode-linux-user@lists.sourceforge.net,
	linux-fbdev@vger.kernel.org, netdev@vger.kernel.org,
	linux-serial@vger.kernel.org, linux-mtd@lists.infradead.org
To: Christophe Leroy <christophe.leroy@c-s.fr>,
	Karsten Keil <isdn@linux-pingi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f177.google.com ([209.85.217.177]:32878 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751617AbbCLSxA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 14:53:00 -0400
Received: by lbdu14 with SMTP id u14so18121648lbd.0
        for <netdev@vger.kernel.org>; Thu, 12 Mar 2015 11:52:59 -0700 (PDT)
In-Reply-To: <20150312152409.E7B5C1A2422@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 03/12/2015 06:24 PM, Christophe Leroy wrote:

> Two config options exist to define powerpc MPC8xx:
> * CONFIG_PPC_8xx
> * CONFIG_8xx
> In addition, CONFIG_PPC_8xx also defines CONFIG_CPM1 as
> communication co-processor

> arch/powerpc/platforms/Kconfig.cputype has contained the following
> comment about CONFIG_8xx item for some years:
> "# this is temp to handle compat with arch=ppc"

> It looks like not many places still have that old CONFIG_8xx used,
> so it is likely to be a good time to get rid of it completely ?

> Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>

[...]

> diff --git a/drivers/isdn/hardware/mISDN/Kconfig b/drivers/isdn/hardware/mISDN/Kconfig
> index 09df54f..ad9deab 100644
> --- a/drivers/isdn/hardware/mISDN/Kconfig
> +++ b/drivers/isdn/hardware/mISDN/Kconfig
[...]
> @@ -28,7 +28,7 @@ config MISDN_HFCMULTI_8xx
>   	depends on MISDN
>   	depends on MISDN_HFCMULTI
>   	depends on 8xx

    Eh, how about this one?

> -	default 8xx
> +	default PPC_8xx
>   	help
>   	  Enable support for the XHFC embedded solution from Speech Design.

WBR, Sergei
