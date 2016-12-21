From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] stmmac: enable rx queues
Date: Wed, 21 Dec 2016 13:26:47 -0500 (EST)
Message-ID: <20161221.132647.1022935257419607406.davem@davemloft.net>
References: <406c3af0c74809090a49d14af6a27cca2f5e9d6b.1482253639.git.jpinto@synopsys.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, seraphin.bonnaffe@st.com,
        hock.leong.kweh@intel.com, niklas.cassel@axis.com, pavel@ucw.cz,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Joao.Pinto@synopsys.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <406c3af0c74809090a49d14af6a27cca2f5e9d6b.1482253639.git.jpinto@synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joao Pinto <Joao.Pinto@synopsys.com>
Date: Tue, 20 Dec 2016 17:09:28 +0000

> When the hardware is synthesized with multiple queues, all queues are
> disabled for default. This patch adds the rx queues configuration.
> This patch was successfully tested in a Synopsys QoS Reference design.
> 
> Signed-off-by: Joao Pinto <jpinto@synopsys.com>
> ---
> changes v2 -> v3 (Seraphin Bonnaffe):
> - GMAC_RX_QUEUE_CLEAR macro simplified
> changes v1 -> v2 (Niklas Cassel and Seraphin Bonnaffe):
> - Instead of using number of DMA channels, lets use number of queues
> - Create 2 flavors of RX queue enable Macros: AV and DCB (AV by default)
> - Make sure that the RX queue related bits are cleared before setting
> - Check if rx_queue_enable is available before executing

This change seems more appropriate for net-next, please resubmit when
that tree opens up again.

Thanks.
