From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 1/3] Add LAN743X driver
Date: Fri, 11 Aug 2017 15:59:08 -0700
Message-ID: <20170811155908.04d9eb4c@xeon-e3>
References: <90A7E81AE28BAE4CBDDB3B35F187D264406F603F@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
        <UNGLinuxDriver@microchip.com>
To: <Bryan.Whitehead@microchip.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f46.google.com ([74.125.83.46]:35647 "EHLO
        mail-pg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753127AbdHKXGf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2017 19:06:35 -0400
Received: by mail-pg0-f46.google.com with SMTP id v189so20677093pgd.2
        for <netdev@vger.kernel.org>; Fri, 11 Aug 2017 16:06:35 -0700 (PDT)
In-Reply-To: <90A7E81AE28BAE4CBDDB3B35F187D264406F603F@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 11 Aug 2017 19:47:57 +0000
<Bryan.Whitehead@microchip.com> wrote:

> +static void lan743x_pcidev_remove(struct pci_dev *pdev)
> +{
> +	struct net_device *netdev = NULL;
> +	struct lan743x_adapter *adapter = NULL;
> +
> +	netdev = pci_get_drvdata(pdev);
> +	adapter = netdev_priv(netdev);

Useless double initialization
