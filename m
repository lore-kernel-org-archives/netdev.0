From: Hau <hau@realtek.com>
Subject: RE: [PATCH net] r8169:fix "rtl_counters_cond == 1 (loop: 1000, delay: 10)" log spam.
Date: Fri, 19 Feb 2016 11:46:43 +0000
Message-ID: <80377ECBC5453840BA8C7155328B53770135AE5F@RTITMBSV03.realtek.com.tw>
References: <1455807427-3177-1-git-send-email-hau@realtek.com>
 <20160218203516.GA18173@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	nic_swsd <nic_swsd@realtek.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160218203516.GA18173@electric-eye.fr.zoreil.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Chunhao Lin <hau@realtek.com> :
> [...]
> > I add checking driver's pm runtime status in rtl8169_get_stats64() to fix
> > this issue.
> 
> Would you consider taking the device out of suspended mode during
> rtl8169_get_stats64 to prevent outdated stats ?
> 

When in runtime suspend, it mean there is no traffic on NIC, so I did not wake the device during rtl8169_get_stats64().
Maybe we can update tally counter before entering runtime suspend mode.

------Please consider the environment before printing this e-mail.
