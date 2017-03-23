From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: stmmac: Performance regression after commit aff3d9eff843 "net:
 stmmac: enable multiple buffers"
Date: Thu, 23 Mar 2017 11:48:38 +0100
Message-ID: <465dc72e-8a1f-b41f-105f-add2164df6d5@st.com>
References: <20170323100828.GC16625@Red>
 <68200e05-04fd-1cc1-f6d6-f77e9e6f1d9d@synopsys.com>
 <20170323102037.GD16625@Red>
 <a7c928ec-e4e5-b618-d0d4-2a833be10d53@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexandre.torgue@st.com,
 linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: Joao Pinto <Joao.Pinto@synopsys.com>, Corentin Labbe
 <clabbe.montjoie@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <a7c928ec-e4e5-b618-d0d4-2a833be10d53@synopsys.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Hello

On 3/23/2017 11:20 AM, Corentin Labbe wrote:
>> I have a 4.21 QoS Core with 4 RX + 4 TX and detected no regression.
>> >Could you please share the iperf cmds you are using in order for me to reproduce
>> >in my side?

Joao, you have a really powerful HW integration with multiple channels 
for both RX and TX.
Often this is not the same for other setup where, usually just a DMA0 is 
present or, sometime, there
is just one RX extra channel.

My question is, what happens on this kind of configurations? Are we 
still guarantying the best performances?

Also we have to guarantee, that the TSO and SG are always working. 
Another point is the buffer sizes that
can be different among platforms.

The problem  below reported by Corentin push me to think that there is a 
bug, so we should
understand when this has been introduced and if likely fixed by some 
configuration we are
not take care right now.

ndesc_get_rx_status: Oversized frame spanned multiple buffers"


Best Regards
Peppe
