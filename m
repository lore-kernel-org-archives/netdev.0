From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v7 11/13] net: ethernet: aquantia: Ethtool support
Date: Thu, 19 Jan 2017 14:34:49 -0800
Message-ID: <733a83f4-892e-f77b-3c90-8a3a26642e3e@gmail.com>
References: <cover.1484860589.git.vomlehn@texas.net>
 <e9264b9e538cc308055d8edc9f8bf712969b4765.1484860589.git.vomlehn@texas.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>,
        Pavel Belous <Pavel.Belous@aquantia.com>,
        Dmitry Bezrukov <Dmitry.Bezrukov@aquantia.com>
To: Alexander Loktionov <Alexander.Loktionov@aquantia.com>,
        netdev@vger.kernel.org, David VomLehn <vomlehn@texas.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33425 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753261AbdASWev (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2017 17:34:51 -0500
Received: by mail-pf0-f194.google.com with SMTP id e4so4092443pfg.0
        for <netdev@vger.kernel.org>; Thu, 19 Jan 2017 14:34:51 -0800 (PST)
In-Reply-To: <e9264b9e538cc308055d8edc9f8bf712969b4765.1484860589.git.vomlehn@texas.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/19/2017 01:33 PM, Alexander Loktionov wrote:
> From: David VomLehn <vomlehn@texas.net>
> 
> Add the driver interfaces required for support by the ethtool utility.
> 
> Signed-off-by: Alexander Loktionov <Alexander.Loktionov@aquantia.com>
> Signed-off-by: Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>
> Signed-off-by: Pavel Belous <Pavel.Belous@aquantia.com>
> Signed-off-by: Dmitry Bezrukov <Dmitry.Bezrukov@aquantia.com>
> Signed-off-by: David M. VomLehn <vomlehn@texas.net>
> ---

> +	strlcat(drvinfo->driver, AQ_CFG_DRV_NAME, sizeof(drvinfo->driver));
> +	strlcat(drvinfo->version, AQ_CFG_DRV_VERSION, sizeof(drvinfo->version));
> +
> +	snprintf(drvinfo->fw_version, sizeof(drvinfo->fw_version),
> +		 "%u.%u.%u", firmware_version >> 24,
> +		 (firmware_version >> 16) & 0xFFU, firmware_version & 0xFFFFU);
> +
> +	drvinfo->n_stats = ARRAY_SIZE(aq_ethtool_stat_names) -
> +		(AQ_CFG_VECS_MAX - cfg->vecs) * aq_ethtool_stat_queue_lines;
> +	drvinfo->testinfo_len = 0;
> +	drvinfo->regdump_len = regs_count;
> +	drvinfo->eedump_len = 0;

Can you also report the bus type here via drvinfo->bus_info?
-- 
Florian
