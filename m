From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] phylib: export phy_suspend and phy_resume
Date: Tue, 8 Apr 2014 08:26:39 -0700
Message-ID: <CAGVrzcY5aa5z36qooLqRZv2b_z=mJd2KeOjs9W5uWDSZ1hjRdQ@mail.gmail.com>
References: <20140408071101.GA14453@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Tobias Waldekranz <tobias@waldekranz.com>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f181.google.com ([209.85.216.181]:46931 "EHLO
	mail-qc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756788AbaDHP1V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2014 11:27:21 -0400
Received: by mail-qc0-f181.google.com with SMTP id x3so1153008qcv.26
        for <netdev@vger.kernel.org>; Tue, 08 Apr 2014 08:27:20 -0700 (PDT)
In-Reply-To: <20140408071101.GA14453@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-04-08 0:11 GMT-07:00 Tobias Waldekranz <tobias@waldekranz.com>:
> These functions are exported in include/linux/phy.h but the symbol
> exports where missing.

Thanks! I had this sitting somewhere and somehow forgot to send it.

>
> Signed-off-by: Tobias Waldekranz <tobias@waldekranz.com>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>

> ---
>  drivers/net/phy/phy_device.c | 2 ++
>  1 file changed, 2 insertions(+)
>
> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
> index 0ce6066..7485334 100644
> --- a/drivers/net/phy/phy_device.c
> +++ b/drivers/net/phy/phy_device.c
> @@ -695,6 +695,7 @@ int phy_suspend(struct phy_device *phydev)
>                 return phydrv->suspend(phydev);
>         return 0;
>  }
> +EXPORT_SYMBOL(phy_suspend);
>
>  int phy_resume(struct phy_device *phydev)
>  {
> @@ -704,6 +705,7 @@ int phy_resume(struct phy_device *phydev)
>                 return phydrv->resume(phydev);
>         return 0;
>  }
> +EXPORT_SYMBOL(phy_resume);
>
>  /* Generic PHY support and helper functions */
>
> --
> 1.8.4.357.g8d83871.dirty
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
Florian
