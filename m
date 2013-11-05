From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 3/7] IBM Akebono: Add support for a new PHY to the IBM
 emac driver
Date: Tue, 5 Nov 2013 10:47:22 -0800
Message-ID: <CAGVrzcZQ26kbim2piOwrvpyOcSaTET5da7Yh4GWv+erfuOBDhQ@mail.gmail.com>
References: <1383629471-16979-1-git-send-email-alistair@popple.id.au> <1383629471-16979-3-git-send-email-alistair@popple.id.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linuxppc-dev@lists.ozlabs.org,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Alistair Popple <alistair@popple.id.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:43530 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755313Ab3KESsD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Nov 2013 13:48:03 -0500
Received: by mail-pd0-f178.google.com with SMTP id x10so9029927pdj.9
        for <netdev@vger.kernel.org>; Tue, 05 Nov 2013 10:48:03 -0800 (PST)
In-Reply-To: <1383629471-16979-3-git-send-email-alistair@popple.id.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[snip]

> +/* RGMII bridge supports only GMII/TBI and RGMII/RTBI PHYs */
> +static inline int rgmii_valid_mode(int phy_mode)
> +{
> +       return  phy_mode == PHY_MODE_GMII ||
> +               phy_mode == PHY_MODE_MII ||
> +               phy_mode == PHY_MODE_RGMII ||
> +               phy_mode == PHY_MODE_TBI ||
> +               phy_mode == PHY_MODE_RTBI;
> +}
> +
> +static inline const char *rgmii_mode_name(int mode)
> +{
> +       switch (mode) {
> +       case PHY_MODE_RGMII:
> +               return "RGMII";
> +       case PHY_MODE_TBI:
> +               return "TBI";
> +       case PHY_MODE_GMII:
> +               return "GMII";
> +       case PHY_MODE_MII:
> +               return "MII";
> +       case PHY_MODE_RTBI:
> +               return "RTBI";
> +       default:
> +               BUG();
> +       }

Any reasons why you are duplicating what is available in
drivers/of/of_net.c ::of_get_phy_mode()?
-- 
Florian
