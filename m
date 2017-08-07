From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] ibmvnic: Add netdev_dbg output for debugging
Date: Mon, 07 Aug 2017 08:29:55 -0700
Message-ID: <1502119795.2219.21.camel@perches.com>
References: <20170807190258.13228.24698.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: jallen@linux.vnet.ibm.com, tlfalcon@linux.vnet.ibm.com
To: Nathan Fontenot <nfont@linux.vnet.ibm.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0159.hostedemail.com ([216.40.44.159]:47975 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751247AbdHGP37 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 11:29:59 -0400
In-Reply-To: <20170807190258.13228.24698.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-08-07 at 15:02 -0400, Nathan Fontenot wrote:
> To ease debugging of the ibmvnic driver add a series of netdev_dbg()
> statements to track driver status, especially during initialization,
> removal, and resetting of the driver.

For some of the function entry logging, it seems
better to use ftrace instead.

> diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
[]
> @@ -389,6 +389,8 @@ static int init_stats_token(struct ibmvnic_adapter *adapter)
>  	struct device *dev = &adapter->vdev->dev;
>  	dma_addr_t stok;
>  
> +	netdev_dbg(adapter->netdev, "Initializing stats token\n");

here and subsequent.
