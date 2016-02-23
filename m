From: Hau <hau@realtek.com>
Subject: RE: [PATCH net v2] r8169:fix "rtl_counters_cond == 1 (loop: 1000, delay: 10)" log spam.
Date: Tue, 23 Feb 2016 07:57:16 +0000
Message-ID: <80377ECBC5453840BA8C7155328B53770135FF33@RTITMBSV03.realtek.com.tw>
References: <1456153794-2028-1-git-send-email-hau@realtek.com>
 <20160222231301.GA17876@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	nic_swsd <nic_swsd@realtek.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160222231301.GA17876@electric-eye.fr.zoreil.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Nits:
> 
> - the tp->TxDescArray test provides the required synchronization: see
>   rtl8169_{open/close} and their pm_runtime_{get / put}.
> 
> - ioaddr is not really needed : tp->mmio_addr appears only once and it does
>   not mess the 72..80 cols limit.
> 
> - even if the device can only be automatically runtime suspended some time
>   after a link down event, you may address davem's point regarding stats
>   reliability and move rtl8169_rx_missed + rtl8169_update_counters after
>   rtl8169_net_suspend.

I will submit the new patch according to your advice.

Thanks.

Please consider the environment before printing this e-mail.
