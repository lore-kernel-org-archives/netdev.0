From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] be2net: Fallback to the older opcode if
 MCC_CREATE_EXT opcode is not supported on the card
Date: Tue, 31 May 2011 15:28:23 -0700 (PDT)
Message-ID: <20110531.152823.294573066.davem@davemloft.net>
References: <fc661b1b-2368-41ce-9c6d-d0f799e243d8@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: somnath.kotur@Emulex.Com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56745 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932753Ab1EaW20 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 May 2011 18:28:26 -0400
In-Reply-To: <fc661b1b-2368-41ce-9c6d-d0f799e243d8@exht1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Somnath Kotur <somnath.kotur@Emulex.Com>
Date: Tue, 31 May 2011 19:52:45 +0530

> @@ -3395,6 +3395,10 @@ static int __devinit be_probe(struct pci_dev *pdev,
>  	}
>  
>  	dev_info(&pdev->dev, "%s port %d\n", nic_name(pdev), adapter->port_num);
> +	/* By default all priorities are enabled.
> +	Needed in case of no GRP5 evt support */

Please format this comment properly:

	/* By default all priorities are enabled.
	 * Needed in case of no GRP5 evt support
	 */
