From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: phy: put genphy_config_init's EXPORT_SYMBOL directly
 after the function
Date: Tue, 23 May 2017 15:28:02 -0700
Message-ID: <02c1c8a9-74ee-0426-905e-005d8190c9f7@gmail.com>
References: <20170523222607.13645-1-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, kernel@pengutronix.de
To: =?UTF-8?Q?Uwe_Kleine-K=c3=b6nig?= <u.kleine-koenig@pengutronix.de>,
        Andrew Lunn <andrew@lunn.ch>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:34191 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S968736AbdEWW2L (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 18:28:11 -0400
Received: by mail-qt0-f193.google.com with SMTP id l39so24145385qtb.1
        for <netdev@vger.kernel.org>; Tue, 23 May 2017 15:28:11 -0700 (PDT)
In-Reply-To: <20170523222607.13645-1-u.kleine-koenig@pengutronix.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/23/2017 03:26 PM, Uwe Kleine-König wrote:
> Commit af6b6967d6e1 ("net: phy: export genphy_config_init()") introduced
> this EXPORT_SYMBOL and put it after gen10g_soft_reset() instead of
> directly after genphy_config_init. Probably this happend when the patch
> was applied because http://patchwork.ozlabs.org/patch/339622/ looks ok.
> 
> Signed-off-by: Uwe Kleine-König <u.kleine-koenig@pengutronix.de>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
