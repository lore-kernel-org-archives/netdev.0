From: Jisheng Zhang <jszhang@marvell.com>
Subject: Re: [PATCH v2 net-next] net: phy: marvell: Add Wake from LAN
 support for 88E1510 PHY
Date: Mon, 23 Jan 2017 11:00:45 +0800
Message-ID: <20170123110045.3524b3b6@xhacker>
References: <1485140295-11339-1-git-send-email-houjingj@marvell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <thomas.petazzoni@free-electrons.com>,
        <netdev@vger.kernel.org>
To: Jingju Hou <houjingj@marvell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016f401.pphosted.com ([67.231.156.173]:60359 "EHLO
        mx0b-0016f401.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750708AbdAWDFM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 22 Jan 2017 22:05:12 -0500
In-Reply-To: <1485140295-11339-1-git-send-email-houjingj@marvell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 23 Jan 2017 10:58:15 +0800 wrote:

> This is test on BG4CT platform with 88E1518 marvell PHY.
> 
> Signed-off-by: Jingju Hou <houjingj@marvell.com>

Reviewed-by: Jisheng Zhang <jszhang@marvell.com>

> ---
> Since v1:
> - add some commit messages
> 
>  drivers/net/phy/marvell.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
> index 0b78210..ed0d235 100644
> --- a/drivers/net/phy/marvell.c
> +++ b/drivers/net/phy/marvell.c
> @@ -1679,6 +1679,8 @@ static int marvell_probe(struct phy_device *phydev)
>  		.ack_interrupt = &marvell_ack_interrupt,
>  		.config_intr = &marvell_config_intr,
>  		.did_interrupt = &m88e1121_did_interrupt,
> +		.get_wol = &m88e1318_get_wol,
> +		.set_wol = &m88e1318_set_wol,
>  		.resume = &marvell_resume,
>  		.suspend = &marvell_suspend,
>  		.get_sset_count = marvell_get_sset_count,
