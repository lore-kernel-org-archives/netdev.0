From: David Miller <davem@davemloft.net>
Subject: Re: [v2] net: phy: fixed: propagate fixed link values to struct
Date: Thu, 27 Aug 2015 11:25:10 -0700 (PDT)
Message-ID: <20150827.112510.1634155959917737972.davem@davemloft.net>
References: <1440601127-7663-1-git-send-email-madalin.bucur@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, stsp@list.ru, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Igal.Liberman@freescale.com
To: madalin.bucur@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45515 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751755AbbH0SZN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 14:25:13 -0400
In-Reply-To: <1440601127-7663-1-git-send-email-madalin.bucur@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Madalin Bucur <madalin.bucur@freescale.com>
Date: Wed, 26 Aug 2015 17:58:47 +0300

> The fixed link values parsed from the device tree are stored in
> the struct fixed_phy member status. The struct phy_device members
> speed, duplex were not updated.
> 
> Signed-off-by: Madalin Bucur <madalin.bucur@freescale.com>
> ---
> v2: always setting phy->link, thanks Stas

Applied.
