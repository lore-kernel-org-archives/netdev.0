From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Re: [PATCH v3] stmmac: enable rx queues
Date: Thu, 22 Dec 2016 10:12:52 +0000
Message-ID: <fb91a9e2-8387-f8be-db2f-2041a8152f2a@synopsys.com>
References: <406c3af0c74809090a49d14af6a27cca2f5e9d6b.1482253639.git.jpinto@synopsys.com>
 <20161221.132647.1022935257419607406.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: <peppe.cavallaro@st.com>, <seraphin.bonnaffe@st.com>,
        <hock.leong.kweh@intel.com>, <niklas.cassel@axis.com>,
        <pavel@ucw.cz>, <linux-kernel@vger.kernel.org>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>, <Joao.Pinto@synopsys.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161221.132647.1022935257419607406.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Às 6:26 PM de 12/21/2016, David Miller escreveu:
> From: Joao Pinto <Joao.Pinto@synopsys.com>
> Date: Tue, 20 Dec 2016 17:09:28 +0000
> 
>> When the hardware is synthesized with multiple queues, all queues are
>> disabled for default. This patch adds the rx queues configuration.
>> This patch was successfully tested in a Synopsys QoS Reference design.
>>
>> Signed-off-by: Joao Pinto <jpinto@synopsys.com>
>> ---
>> changes v2 -> v3 (Seraphin Bonnaffe):
>> - GMAC_RX_QUEUE_CLEAR macro simplified
>> changes v1 -> v2 (Niklas Cassel and Seraphin Bonnaffe):
>> - Instead of using number of DMA channels, lets use number of queues
>> - Create 2 flavors of RX queue enable Macros: AV and DCB (AV by default)
>> - Make sure that the RX queue related bits are cleared before setting
>> - Check if rx_queue_enable is available before executing
> 
> This change seems more appropriate for net-next, please resubmit when
> that tree opens up again.
> 
> Thanks.
> 

Ok, great! Could you please send me an estimate of when the net-next is going to
open again?

Thanks
