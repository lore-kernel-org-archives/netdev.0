From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Subject: RE: [PATCH 1/5] net: qlcnic: don't set unused function argument
Date: Thu, 16 Jun 2016 13:26:46 +0000
Message-ID: <BN3PR11MB02732854F64F5C128D8BF72C8B560@BN3PR11MB0273.namprd11.prod.outlook.com>
References: <20160616113831.4108439-1-arnd@arndb.de>
 <20160616113831.4108439-2-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>,
	Dept-GE Linux NIC Dev <Dept-GELinuxNICDev@qlogic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160616113831.4108439-2-arnd@arndb.de>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>-----Original Message-----
>From: Arnd Bergmann [mailto:arnd@arndb.de]
>Sent: Thursday, June 16, 2016 5:08 PM
>To: Dept-GE Linux NIC Dev <Dept-GELinuxNICDev@qlogic.com>
>Cc: Arnd Bergmann <arnd@arndb.de>; David Miller
><davem@davemloft.net>; Rajesh Borundia <rajesh.borundia@qlogic.com>;
>netdev <netdev@vger.kernel.org>; linux-kernel <linux-
>kernel@vger.kernel.org>
>Subject: [PATCH 1/5] net: qlcnic: don't set unused function argument
>
>We get a warning for qlcnic_83xx_get_mac_address when building with
>"make W=1":
>
>drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c: In function
>'qlcnic_83xx_get_mac_address':
>drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c:2156:8: error:
>parameter 'function' set but not used [-Werror=unused-but-set-parameter]
>
>Clearly this is harmless, but there is also no point for setting the variable, so
>we can simply remove the assignment.
>
>Signed-off-by: Arnd Bergmann <arnd@arndb.de>
>---
> drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c | 1 -
> 1 file changed, 1 deletion(-)
>
>diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
>b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
>index f9640d5ce6ba..bdbcd2b088a0 100644
>--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
>+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
>@@ -2159,7 +2159,6 @@ int qlcnic_83xx_get_mac_address(struct
>qlcnic_adapter *adapter, u8 *mac,
> 	struct qlcnic_cmd_args cmd;
> 	u32 mac_low, mac_high;
>
>-	function = 0;
> 	err = qlcnic_alloc_mbx_args(&cmd, adapter,
>QLCNIC_CMD_MAC_ADDRESS);
> 	if (err)
> 		return err;
>--
>2.9.0

Acked-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
