From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 1/3] Add LAN743X driver
Date: Fri, 11 Aug 2017 15:50:57 -0700
Message-ID: <20170811155057.30cb4966@xeon-e3>
References: <90A7E81AE28BAE4CBDDB3B35F187D264406F603F@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
        <UNGLinuxDriver@microchip.com>
To: <Bryan.Whitehead@microchip.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:36714 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753713AbdHKWvE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2017 18:51:04 -0400
Received: by mail-pg0-f51.google.com with SMTP id v77so20521132pgb.3
        for <netdev@vger.kernel.org>; Fri, 11 Aug 2017 15:51:04 -0700 (PDT)
In-Reply-To: <90A7E81AE28BAE4CBDDB3B35F187D264406F603F@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 11 Aug 2017 19:47:57 +0000
<Bryan.Whitehead@microchip.com> wrote:

> +
> +	netdev = alloc_etherdev(sizeof(struct lan743x_adapter));
> +	if (!netdev) {
> +		NETIF_ERROR(adapter, probe, adapter->netdev,
> +			    "alloc_etherdev returned NULL");
> +		ret = -ENOMEM;
> +		goto clean_up;
> +	}
> +
> +	strncpy(netdev->name, pci_name(pdev), sizeof(netdev->name) - 1);
> +	SET_NETDEV_DEV(netdev, &pdev->dev);
> +	pci_set_drvdata(pdev, netdev);
> +	adapter = netdev_priv(netdev);
> +	if (!adapter) {
> +		NETIF_ERROR(adapter, probe, adapter->netdev,
> +			    "netdev_priv returned NULL");
> +		ret = -ENOMEM;
> +		goto clean_up;
> +	}
> +	memset(adapter, 0, sizeof(struct lan743x_adapter));

netdev_priv area is already zerod
