From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net/phy: Remove return value for a void function
Date: Tue, 1 Apr 2014 10:47:41 -0700
Message-ID: <CAGVrzcY3Xjd4H3BSgj1K52t+Mjh+Qv5RYjuFiNG0K9k6FinnGw@mail.gmail.com>
References: <1396363464-28923-1-git-send-email-Shruti@Freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, emmedve1@freescale.com
To: Shruti@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:40373 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751318AbaDARsW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2014 13:48:22 -0400
Received: by mail-pd0-f178.google.com with SMTP id x10so9936875pdj.9
        for <netdev@vger.kernel.org>; Tue, 01 Apr 2014 10:48:22 -0700 (PDT)
In-Reply-To: <1396363464-28923-1-git-send-email-Shruti@Freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-04-01 7:44 GMT-07:00  <Shruti@freescale.com>:
> From: Shruti Kanetkar <Shruti@Freescale.com>
>
> Signed-off-by: Shruti Kanetkar <Shruti@Freescale.com>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>

> ---
>  drivers/net/phy/vitesse.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/phy/vitesse.c b/drivers/net/phy/vitesse.c
> index 14372c6..1f2f060 100644
> --- a/drivers/net/phy/vitesse.c
> +++ b/drivers/net/phy/vitesse.c
> @@ -319,8 +319,8 @@ static int __init vsc82xx_init(void)
>
>  static void __exit vsc82xx_exit(void)
>  {
> -       return phy_drivers_unregister(vsc82xx_driver,
> -               ARRAY_SIZE(vsc82xx_driver));
> +       phy_drivers_unregister(vsc82xx_driver,
> +                              ARRAY_SIZE(vsc82xx_driver));
>  }
>
>  module_init(vsc82xx_init);
> --
> 1.8.3.1
>
>



-- 
Florian
