From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Subject: [PATCH 1/6] bna: Brocade 10Gb Ethernet device driver
Date: Wed, 10 Feb 2010 09:10:53 -0800
Message-ID: <20100210091053.2104bc8e@nehalam>
References: <201002100629.o1A6TFUk026363@blc-10-10.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, adapter_linux_open_src_team@brocade.com
To: Rasesh Mody <rmody@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36156 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755356Ab0BJRLI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Feb 2010 12:11:08 -0500
In-Reply-To: <201002100629.o1A6TFUk026363@blc-10-10.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 9 Feb 2010 22:29:15 -0800
Rasesh Mody <rmody@brocade.com> wrote:

> +	netdev = alloc_etherdev(sizeof(struct bnad));
> +	if (!netdev) {
> +		dev_err(&pdev->dev, "alloc_etherdev failed\n");
> +		err = -ENOMEM;
> +		goto release_regions;
> +	}
> +	SET_NETDEV_DEV(netdev, &pdev->dev);
> +	pci_set_drvdata(pdev, netdev);
> +
> +	bnad = netdev_priv(netdev);
> +
> +	memset(bnad, 0, sizeof(struct bnad));

The private area provided by alloc_etherdev is already 
guaranteed to be zerod.

-- 
