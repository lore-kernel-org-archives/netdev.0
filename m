From: Hayes Wang <hayeswang@realtek.com>
Subject: RE: [PATCH net 1/2] r8169: fix the default setting of rx vlan
Date: Mon, 15 Sep 2014 03:22:54 +0000
Message-ID: <0835B3720019904CB8F7AA43166CEEB2523183@RTITMBSV03.realtek.com.tw>
References: <1394712342-15778-38-Taiwan-albertk@realtek.com>
 <1394712342-15778-39-Taiwan-albertk@realtek.com>
 <20140912194014.GA15496@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	nic_swsd <nic_swsd@realtek.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140912194014.GA15496@electric-eye.fr.zoreil.com>
Content-Language: zh-TW
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 Francois Romieu [mailto:romieu@fr.zoreil.com] 
> Sent: Saturday, September 13, 2014 3:40 AM
[...]
> The same fix should be relevant for NETIF_F_RXCSUM. You may thus as
> well remove the "changed" test in __rtl8169_set_features and keep
> everything there.

In the probe function (rtl_init_one), RxChkSum has been assgined to
tp->cp_cmd, so only the vlan setting is incorrect. Therefore, I fix
it only. Do I still have to remove the "changed" test?
 
Best Regards,
Hayes
