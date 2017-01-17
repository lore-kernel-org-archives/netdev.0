From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] net:add one common config
 ARCH_WANT_RELAX_ORDER to support relax ordering.
Date: Tue, 17 Jan 2017 14:15:33 -0500 (EST)
Message-ID: <20170117.141533.680344033700095483.davem@davemloft.net>
References: <1483939954-9864-1-git-send-email-maowenan@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com,
        alexander.duyck@gmail.com
To: maowenan@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41750 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751026AbdAQT0Z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 14:26:25 -0500
In-Reply-To: <1483939954-9864-1-git-send-email-maowenan@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mao Wenan <maowenan@huawei.com>
Date: Mon, 9 Jan 2017 13:32:34 +0800

> Relax ordering(RO) is one feature of 82599 NIC, to enable this feature can
> enhance the performance for some cpu architecure, such as SPARC and so on.
> Currently it only supports one special cpu architecture(SPARC) in 82599
> driver to enable RO feature, this is not very common for other cpu architecture
> which really needs RO feature.
> This patch add one common config CONFIG_ARCH_WANT_RELAX_ORDER to set RO feature,
> and should define CONFIG_ARCH_WANT_RELAX_ORDER in sparc Kconfig firstly.
> 
> Signed-off-by: Mao Wenan <maowenan@huawei.com>

Since no-one has reviewed this patch, and I do not feel comfortable with applying
it without such review, I am tossing this patch.

If someone eventually reviews it, repost this patch.
