From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] net: netcp: Fixes efuse mac addr swap on k2e
 and k2l
Date: Wed, 29 Jul 2015 17:16:24 -0700 (PDT)
Message-ID: <20150729.171624.568549486034691205.davem@davemloft.net>
References: <1438113671-6098-1-git-send-email-w-kwok2@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: m-karicheri2@ti.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: w-kwok2@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35057 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752280AbbG3AQZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2015 20:16:25 -0400
In-Reply-To: <1438113671-6098-1-git-send-email-w-kwok2@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: WingMan Kwok <w-kwok2@ti.com>
Date: Tue, 28 Jul 2015 16:01:11 -0400

> On some of the K2E and K2L platforms, the two DWORDs in
> efuse occupied by the pre-programmed mac address for
> slave port 1 are swapped.  To workaround this issue,
> this patch adds a new define NETCP_EFUSE_ADDR_SWAP (2)
> which signifies the occurrence of such swapping so that
> the driver can take proper action.  The flag can be
> enabled in the corresponding netcp interface dts binding
> as efuse-mac = <2>  under the corresponding netcp
> interface node.
> 
> Signed-off-by: WingMan Kwok <w-kwok2@ti.com>

Applied, thanks.
