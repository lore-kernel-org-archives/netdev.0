From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2 v2] net: dsa: remove restriction on
 platform_device
Date: Mon, 09 Mar 2015 23:50:58 -0400 (EDT)
Message-ID: <20150309.235058.2202053434488150193.davem@davemloft.net>
References: <1425936681-31910-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, linux@roeck-us.net,
	andrew@lunn.ch, cphealy@gmail.com, mathieu@codeaurora.org,
	jonasj76@gmail.com, andrey.volkov@nexvision.fr,
	Chris.Packham@alliedtelesis.co.nz
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45008 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751333AbbCJDvB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 23:51:01 -0400
In-Reply-To: <1425936681-31910-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Mon,  9 Mar 2015 14:31:19 -0700

> This patch series removes the restriction in DSA to operate exclusively with
> platform_device Ethernet MAC drivers when using Device Tree. This basically
> allows arbitrary Ethernet MAC drivers to be used now in conjunction with
> Device Tree.
> 
> The reason was that DSA was using a of_find_device_by_node() which limits
> the device_node to device pointer search exclusively to platform_device,
> in our case, we are interested in doing a "class" research and lookup the
> net_device.
> 
> Thanks to Chris Packham for testing this on his platform.
> 
> Changes in v2:
> 
> - fix build for !CONFIG_OF_NET

Applied, thanks Florian.
