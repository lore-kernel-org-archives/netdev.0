From: Antonio Borneo <borneo.antonio@gmail.com>
Subject: Re: via rhine build regression for arch/sh
Date: Thu, 23 Jul 2015 00:33:10 +0800
Message-ID: <CAAj6DX2dAORB58rypV3Bdy1WfQ4xs_h8J8MUZVGCq2Q6Dqczbg@mail.gmail.com>
References: <20150722135424.GG4477@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexey Charkov <alchark@gmail.com>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f180.google.com ([209.85.214.180]:35875 "EHLO
	mail-ob0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965137AbbGVQdL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2015 12:33:11 -0400
In-Reply-To: <20150722135424.GG4477@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 22, 2015 at 9:54 PM, Paul Gortmaker
<paul.gortmaker@windriver.com> wrote:
> The builds of arch/sh are failing in linux-next with:
>
> drivers/net/ethernet/via/via-rhine.c:1098:2: error: implicit declaration
> of function 'pci_iomap' [-Werror=implicit-function-declaration]
> drivers/net/ethernet/via/via-rhine.c:1119:2: error: implicit declaration
> of function 'pci_iounmap' [-Werror=implicit-function-declaration]
> cc1: some warnings being treated as errors
> make[5]: *** [drivers/net/ethernet/via/via-rhine.o] Error 1
>
> http://kisskb.ellerman.id.au/kisskb/buildresult/12468878/
>
> It either is the one line change in:
>
> commit b7d3282a245f44286b88e436b1d08c518cdf4569
> Author: Antonio Borneo <borneo.antonio@gmail.com>
> Date:   Wed Jun 17 19:42:31 2015 +0800
>
>     net: via/Kconfig: replace USE_OF with OF_???
>
>
> ..or maybe it goes back to the original OF support patch:
>
> commit 2d283862dc62daead9db0dc89cd0d0351e91f765
> Author: Alexey Charkov <alchark@gmail.com>
> Date:   Tue Apr 22 19:28:09 2014 +0400
>
>     net: via-rhine: add OF bus binding
>
>
> I have not bisected to check which, but it seems likely that
> it is one of the above.
>
> Paul.
>

Hi Paul,

yes, I can reproduce it and depends on my patch.
I'm sending out a fix. Could you please check it?

Best Regards,
Antonio
