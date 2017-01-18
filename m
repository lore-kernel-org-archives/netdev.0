From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next] net:add one common config
 ARCH_WANT_RELAX_ORDER to support relax ordering
Date: Wed, 18 Jan 2017 16:33:16 -0500 (EST)
Message-ID: <20170118.163316.323226545540028057.davem@davemloft.net>
References: <1484700605-2412-1-git-send-email-maowenan@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexander.duyck@gmail.com,
        jeffrey.t.kirsher@intel.com
To: maowenan@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41398 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751773AbdARVec (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2017 16:34:32 -0500
In-Reply-To: <1484700605-2412-1-git-send-email-maowenan@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mao Wenan <maowenan@huawei.com>
Date: Wed, 18 Jan 2017 08:50:05 +0800

> Relax ordering(RO) is one feature of 82599 NIC, to enable this feature can
> enhance the performance for some cpu architecure, such as SPARC and so on.
> Currently it only supports one special cpu architecture(SPARC) in 82599
> driver to enable RO feature, this is not very common for other cpu architecture
> which really needs RO feature.
> This patch add one common config CONFIG_ARCH_WANT_RELAX_ORDER to set RO feature,
> and should define CONFIG_ARCH_WANT_RELAX_ORDER in sparc Kconfig firstly.
> 
> Signed-off-by: Mao Wenan <maowenan@huawei.com>
> Reviewed-by: Alexander Duyck <alexander.duyck@gmail.com>
> ---
> v2 -> v3: add reviewed information.

Applied, thanks.
