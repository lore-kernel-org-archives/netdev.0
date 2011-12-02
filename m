From: Thomas Jarosch <thomas.jarosch@intra2net.com>
Subject: Re: Small glitch in neptune ethernet driver
Date: Fri, 2 Dec 2011 09:49:32 +0100
Message-ID: <201112020949.32369.thomas.jarosch@intra2net.com>
References: <4EA845CF.6070401@intra2net.com> <20111201.220003.905428158537118068.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from re04.intra2net.com ([82.165.46.26]:43013 "EHLO
	re04.intra2net.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752977Ab1LBIte (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2011 03:49:34 -0500
In-Reply-To: <20111201.220003.905428158537118068.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday, 2. December 2011 04:00:03 David Miller wrote:
> diff --git a/drivers/net/ethernet/sun/niu.c
> b/drivers/net/ethernet/sun/niu.c index 680b107..56d106e 100644
> --- a/drivers/net/ethernet/sun/niu.c
> +++ b/drivers/net/ethernet/sun/niu.c
> @@ -8579,9 +8579,11 @@ static int __devinit phy_record(struct niu_parent
> *parent, if (dev_id_1 < 0 || dev_id_2 < 0)
>  		return 0;
>  	if (type == PHY_TYPE_PMA_PMD || type == PHY_TYPE_PCS) {
> +		/* Becuase of the NIU_PHY_ID_MASK being applied, the 8704

The change looks good to me, just fix the typo in "Becuase".

Thanks,
Thomas
