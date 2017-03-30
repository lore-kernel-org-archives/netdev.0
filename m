From: Joel Stanley <joel@jms.id.au>
Subject: Re: [PATCH] net/faraday: Explicitly include linux/of.h and linux/property.h
Date: Fri, 31 Mar 2017 09:18:57 +1030
Message-ID: <CACPK8XfMNWG1=X79=XySTu4C4iqWGU+ytgt7z3R+RRb3mEVX8A@mail.gmail.com>
References: <20170330160012.14824-1-broonie@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S . Miller" <davem@davemloft.net>,
        Gavin Shan <gwshan@linux.vnet.ibm.com>, netdev@vger.kernel.org
To: Mark Brown <broonie@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f194.google.com ([209.85.213.194]:33826 "EHLO
        mail-yb0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932557AbdC3WtU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 30 Mar 2017 18:49:20 -0400
Received: by mail-yb0-f194.google.com with SMTP id m133so1645307ybb.1
        for <netdev@vger.kernel.org>; Thu, 30 Mar 2017 15:49:19 -0700 (PDT)
In-Reply-To: <20170330160012.14824-1-broonie@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 31, 2017 at 2:30 AM, Mark Brown <broonie@kernel.org> wrote:
> This driver uses interfaces from linux/of.h and linux/property.h but
> relies on implict inclusion of those headers which means that changes in
> other headers could break the build, as happened in -next for arm today.
> Add a explicit includes.
>
> Signed-off-by: Mark Brown <broonie@kernel.org>

Acked-by: Joel Stanley <joel@jms.id.au>

Thank you for fixing this Mark.

Cheers,

Joel

> ---
>  drivers/net/ethernet/faraday/ftgmac100.c | 2 ++
>  1 file changed, 2 insertions(+)
>
> diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
> index 928b0df2b8e0..ade6b3e4ed13 100644
> --- a/drivers/net/ethernet/faraday/ftgmac100.c
> +++ b/drivers/net/ethernet/faraday/ftgmac100.c
> @@ -28,8 +28,10 @@
>  #include <linux/io.h>
>  #include <linux/module.h>
>  #include <linux/netdevice.h>
> +#include <linux/of.h>
>  #include <linux/phy.h>
>  #include <linux/platform_device.h>
> +#include <linux/property.h>
>  #include <net/ip.h>
>  #include <net/ncsi.h>
>
> --
> 2.11.0
>
