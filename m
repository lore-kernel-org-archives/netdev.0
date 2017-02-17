From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 1/3] net: stmicro: prepare dwmac4 core for
 mtl
Date: Fri, 17 Feb 2017 13:02:06 -0500 (EST)
Message-ID: <20170217.130206.307364283233407941.davem@davemloft.net>
References: <cover.1487243644.git.jpinto@synopsys.com>
        <cover.1487243644.git.jpinto@synopsys.com>
        <9aa3ec8ee45cb921bbc478415bc62336285e156a.1487243644.git.jpinto@synopsys.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org
To: Joao.Pinto@synopsys.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46356 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934144AbdBQSC1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2017 13:02:27 -0500
In-Reply-To: <9aa3ec8ee45cb921bbc478415bc62336285e156a.1487243644.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joao Pinto <Joao.Pinto@synopsys.com>
Date: Thu, 16 Feb 2017 11:19:39 +0000

> This patch adds the following features:
> 
> a) RX and TX scheduling algorithm configuration (can be configured in the
> Device Tree)
> b) TX VLAN tag priority configuration (can be configured in the Device Tree)
> c) RX VLAN tag priority routing configuration (can be configured in the
> Device Tree)
> d) TX weight configuration (can be configured in the Device Tree)
> e) RX queue to RX DMA channel mapping
> f) RX queue enabling
> g) MAC and individual queue related interrupt analysis
> h) Flow Control configuration by queue
> 
> The number of RX and TX queues to use comes from the FEATURES register.
> 
> With this patch we get the core related operations ready for multiple
> queue/channel.
> 
> Signed-off-by: Joao Pinto <jpinto@synopsys.com>

This would be so much easier to review if you used one patch for each
of those new configuration features.

In fact, it would make an appropriate complete patch series on it's own.

Thanks.
