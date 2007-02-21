From: Stephen Hemminger <shemminger@osdl.org>
Subject: iwlwifi warnings
Date: Tue, 20 Feb 2007 22:23:21 -0800
Message-ID: <45DBE559.8080903@osdl.org>
References: <45CCE3CA.4050904@linux.intel.com> <20070213181313.GA5350@ucw.cz> <45D254C6.7050401@linux.intel.com> <20070219224432.GD21199@elf.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: James Ketrenos <jketreno@linux.intel.com>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
	ipw3945-devel@lists.sourceforge.net
To: Pavel Machek <pavel@ucw.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:40250 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751136AbXBUGXz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Feb 2007 01:23:55 -0500
In-Reply-To: <20070219224432.GD21199@elf.ucw.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

BUilding with sparse shows lots of warnings.


$ make C=3D1
Checking kernel compatibility in:
    /lib/modules/2.6.20.1/source
 * Kernel supports required features for 'tip' version.
Building compatibility version in 'compatible/' directory:
Copying compatible/ from origin/...done
make -C /lib/modules/2.6.20.1/build M=3D/home/shemminger/src/iwlwifi-0.=
0.8=20
modules
make[1]: Entering directory `/home/shemminger/kernel/linux-2.6.20.1'
  CHECK   /home/shemminger/src/iwlwifi-0.0.8/compatible/base.c
/home/shemminger/src/iwlwifi-0.0.8/compatible/base.c:11115:12: warning:=
=20
function 'ipw_rate_scale_clear_window' with external linkage has defini=
tion
/home/shemminger/src/iwlwifi-0.0.8/compatible/base.c:11352:12: warning:=
=20
function 'ipw_collect_tx_data' with external linkage has definition
/home/shemminger/src/iwlwifi-0.0.8/compatible/base.c:11480:12: warning:=
=20
function 'ipw_convert_to_rate_index' with external linkage has definiti=
on
/home/shemminger/src/iwlwifi-0.0.8/compatible/base.c:11665:12: warning:=
=20
function 'ipw_convert_to_phy_index' with external linkage has definitio=
n
/home/shemminger/src/iwlwifi-0.0.8/compatible/base.c:11677:30: warning:=
=20
function 'ipw_get_lowest_rate' with external linkage has definition
/home/shemminger/src/iwlwifi-0.0.8/compatible/base.c:11692:12: warning:=
=20
function 'ipw_get_adjacent_rate' with external linkage has definition
/home/shemminger/src/iwlwifi-0.0.8/compatible/base.c:1522:11: warning:=20
Using plain integer as NULL pointer
/home/shemminger/src/iwlwifi-0.0.8/compatible/base.c:10004:16: warning:=
=20
Using plain integer as NULL pointer
  CC [M]  /home/shemminger/src/iwlwifi-0.0.8/compatible/base.o
/home/shemminger/src/iwlwifi-0.0.8/compatible/base.c: In function=20
=1B$-1=F2=F8ipw_rx_handle=F2=F9:
/home/shemminger/src/iwlwifi-0.0.8/compatible/base.c:8175: warning:=20
unused variable =1B$-1=F2=F8sleep=F2=F9
/home/shemminger/src/iwlwifi-0.0.8/compatible/base.c:8195: warning:=20
unused variable =1B$-1=F2=F8beacon=F2=F9
/home/shemminger/src/iwlwifi-0.0.8/compatible/base.c:8227: warning:=20
unused variable =1B$-1=F2=F8notif=F2=F9
/home/shemminger/src/iwlwifi-0.0.8/compatible/base.c:8259: warning:=20
unused variable =1B$-1=F2=F8notif=F2=F9
/home/shemminger/src/iwlwifi-0.0.8/compatible/base.c: At top level:
/home/shemminger/src/iwlwifi-0.0.8/compatible/base.c:3889: warning:=20
=1B$-1=F2=F8ipw_set_rxon_conf=F2=F9 defined but not used
/home/shemminger/src/iwlwifi-0.0.8/compatible/base.c:2523: warning:=20
=1B$-1=F2=F8ipw_rate_ieee2index=F2=F9 defined but not used
/home/shemminger/src/iwlwifi-0.0.8/compatible/base.c:2577: warning:=20
=1B$-1=F2=F8ipw_check_rx_config_cmd=F2=F9 defined but not used
/home/shemminger/src/iwlwifi-0.0.8/compatible/base.c:3628: warning:=20
=1B$-1=F2=F8ipw_setup_rxon_timing=F2=F9 defined but not used
/home/shemminger/src/iwlwifi-0.0.8/compatible/base.c:6931: warning:=20
=1B$-1=F2=F8ipw_send_qos_params_command=F2=F9 defined but not used
/home/shemminger/src/iwlwifi-0.0.8/compatible/base.c:7964: warning:=20
=1B$-1=F2=F8get_tx_fail_reason=F2=F9 defined but not used
/home/shemminger/src/iwlwifi-0.0.8/compatible/base.c:8637: warning:=20
=1B$-1=F2=F8ipw_get_rate_by_rssi=F2=F9 defined but not used
/home/shemminger/src/iwlwifi-0.0.8/compatible/base.c:10371: warning:=20
=1B$-1=F2=F8d_hw_scan=F2=F9 defined but not used
  LD [M]  /home/shemminger/src/iwlwifi-0.0.8/compatible/iwlwifi.o
  Building modules, stage 2.
  MODPOST 1 modules
WARNING: "ieee80211_rx_irqsafe"=20
[/home/shemminger/src/iwlwifi-0.0.8/compatible/iwlwifi.ko] undefined!
WARNING: "ieee80211_register_hwmode"=20
[/home/shemminger/src/iwlwifi-0.0.8/compatible/iwlwifi.ko] undefined!
WARNING: "ieee80211_unregister_hw"=20
[/home/shemminger/src/iwlwifi-0.0.8/compatible/iwlwifi.ko] undefined!
WARNING: "ieee80211_scan_completed"=20
[/home/shemminger/src/iwlwifi-0.0.8/compatible/iwlwifi.ko] undefined!
WARNING: "ieee80211_get_hdrlen"=20
[/home/shemminger/src/iwlwifi-0.0.8/compatible/iwlwifi.ko] undefined!
WARNING: "ieee80211_tx_status"=20
[/home/shemminger/src/iwlwifi-0.0.8/compatible/iwlwifi.ko] undefined!
WARNING: "sta_info_get"=20
[/home/shemminger/src/iwlwifi-0.0.8/compatible/iwlwifi.ko] undefined!
WARNING: "ieee80211_rate_control_register"=20
[/home/shemminger/src/iwlwifi-0.0.8/compatible/iwlwifi.ko] undefined!
WARNING: "ieee80211_netif_oper"=20
[/home/shemminger/src/iwlwifi-0.0.8/compatible/iwlwifi.ko] undefined!
WARNING: "ieee80211_tx_status_irqsafe"=20
[/home/shemminger/src/iwlwifi-0.0.8/compatible/iwlwifi.ko] undefined!
WARNING: "ieee80211_get_hdrlen_from_skb"=20
[/home/shemminger/src/iwlwifi-0.0.8/compatible/iwlwifi.ko] undefined!
WARNING: "ieee80211_rate_control_unregister"=20
[/home/shemminger/src/iwlwifi-0.0.8/compatible/iwlwifi.ko] undefined!
WARNING: "ieee80211_register_hw"=20
[/home/shemminger/src/iwlwifi-0.0.8/compatible/iwlwifi.ko] undefined!
WARNING: "ieee80211_alloc_hw"=20
[/home/shemminger/src/iwlwifi-0.0.8/compatible/iwlwifi.ko] undefined!
WARNING: "ieee80211_free_hw"=20
[/home/shemminger/src/iwlwifi-0.0.8/compatible/iwlwifi.ko] undefined!
WARNING: "sta_info_put"=20
[/home/shemminger/src/iwlwifi-0.0.8/compatible/iwlwifi.ko] undefined!
  CC      /home/shemminger/src/iwlwifi-0.0.8/compatible/iwlwifi.mod.o8$=
=20
make C=3D1
Checking kernel compatibility in:
    /lib/modules/2.6.20.1/source
 * Kernel supports required features for 'tip' version.
Building compatibility version in 'compatible/' directory:
Copying compatible/ from origin/...done
make -C /lib/modules/2.6.20.1/build M=3D/home/shemminger/src/iwlwifi-0.=
0.8=20
modules
make[1]: Entering directory `/home/shemminger/kernel/linux-2.6.20.1'
  CHECK   /home/shemminger/src/iwlwifi-0.0.8/compatible/base.c
/home/shemminger/src/iwlwifi-0.0.8/compatible/base.c:11115:12: warning:=
=20
function 'ipw_rate_scale_clear_window' with external linkage has defini=
tion
/home/shemminger/src/iwlwifi-0.0.8/compatible/base.c:11352:12: warning:=
=20
function 'ipw_collect_tx_data' with external linkage has definition
/home/shemminger/src/iwlwifi-0.0.8/compatible/base.c:11480:12: warning:=
=20
function 'ipw_convert_to_rate_index' with external linkage has definiti=
on
/home/shemminger/src/iwlwifi-0.0.8/compatible/base.c:11665:12: warning:=
=20
function 'ipw_convert_to_phy_index' with external linkage has definitio=
n
/home/shemminger/src/iwlwifi-0.0.8/compatible/base.c:11677:30: warning:=
=20
function 'ipw_get_lowest_rate' with external linkage has definition
/home/shemminger/src/iwlwifi-0.0.8/compatible/base.c:11692:12: warning:=
=20
function 'ipw_get_adjacent_rate' with external linkage has definition
/home/shemminger/src/iwlwifi-0.0.8/compatible/base.c:1522:11: warning:=20
Using plain integer as NULL pointer
/home/shemminger/src/iwlwifi-0.0.8/compatible/base.c:10004:16: warning:=
=20
Using plain integer as NULL pointer
  CC [M]  /home/shemminger/src/iwlwifi-0.0.8/compatible/base.o
/home/shemminger/src/iwlwifi-0.0.8/compatible/base.c: In function=20
=1B$-1=F2=F8ipw_rx_handle=F2=F9:
/home/shemminger/src/iwlwifi-0.0.8/compatible/base.c:8175: warning:=20
unused variable =1B$-1=F2=F8sleep=F2=F9
/home/shemminger/src/iwlwifi-0.0.8/compatible/base.c:8195: warning:=20
unused variable =1B$-1=F2=F8beacon=F2=F9
/home/shemminger/src/iwlwifi-0.0.8/compatible/base.c:8227: warning:=20
unused variable =1B$-1=F2=F8notif=F2=F9
/home/shemminger/src/iwlwifi-0.0.8/compatible/base.c:8259: warning:=20
unused variable =1B$-1=F2=F8notif=F2=F9
/home/shemminger/src/iwlwifi-0.0.8/compatible/base.c: At top level:
/home/shemminger/src/iwlwifi-0.0.8/compatible/base.c:3889: warning:=20
=1B$-1=F2=F8ipw_set_rxon_conf=F2=F9 defined but not used
/home/shemminger/src/iwlwifi-0.0.8/compatible/base.c:2523: warning:=20
=1B$-1=F2=F8ipw_rate_ieee2index=F2=F9 defined but not used
/home/shemminger/src/iwlwifi-0.0.8/compatible/base.c:2577: warning:=20
=1B$-1=F2=F8ipw_check_rx_config_cmd=F2=F9 defined but not used
/home/shemminger/src/iwlwifi-0.0.8/compatible/base.c:3628: warning:=20
=1B$-1=F2=F8ipw_setup_rxon_timing=F2=F9 defined but not used
/home/shemminger/src/iwlwifi-0.0.8/compatible/base.c:6931: warning:=20
=1B$-1=F2=F8ipw_send_qos_params_command=F2=F9 defined but not used
/home/shemminger/src/iwlwifi-0.0.8/compatible/base.c:7964: warning:=20
=1B$-1=F2=F8get_tx_fail_reason=F2=F9 defined but not used
/home/shemminger/src/iwlwifi-0.0.8/compatible/base.c:8637: warning:=20
=1B$-1=F2=F8ipw_get_rate_by_rssi=F2=F9 defined but not used
/home/shemminger/src/iwlwifi-0.0.8/compatible/base.c:10371: warning:=20
=1B$-1=F2=F8d_hw_scan=F2=F9 defined but not used
  LD [M]  /home/shemminger/src/iwlwifi-0.0.8/compatible/iwlwifi.o
  Building modules, stage 2.
  MODPOST 1 modules
WARNING: "ieee80211_rx_irqsafe"=20
[/home/shemminger/src/iwlwifi-0.0.8/compatible/iwlwifi.ko] undefined!
WARNING: "ieee80211_register_hwmode"=20
[/home/shemminger/src/iwlwifi-0.0.8/compatible/iwlwifi.ko] undefined!
WARNING: "ieee80211_unregister_hw"=20
[/home/shemminger/src/iwlwifi-0.0.8/compatible/iwlwifi.ko] undefined!
WARNING: "ieee80211_scan_completed"=20
[/home/shemminger/src/iwlwifi-0.0.8/compatible/iwlwifi.ko] undefined!
WARNING: "ieee80211_get_hdrlen"=20
[/home/shemminger/src/iwlwifi-0.0.8/compatible/iwlwifi.ko] undefined!
WARNING: "ieee80211_tx_status"=20
[/home/shemminger/src/iwlwifi-0.0.8/compatible/iwlwifi.ko] undefined!
WARNING: "sta_info_get"=20
[/home/shemminger/src/iwlwifi-0.0.8/compatible/iwlwifi.ko] undefined!
WARNING: "ieee80211_rate_control_register"=20
[/home/shemminger/src/iwlwifi-0.0.8/compatible/iwlwifi.ko] undefined!
WARNING: "ieee80211_netif_oper"=20
[/home/shemminger/src/iwlwifi-0.0.8/compatible/iwlwifi.ko] undefined!
WARNING: "ieee80211_tx_status_irqsafe"=20
[/home/shemminger/src/iwlwifi-0.0.8/compatible/iwlwifi.ko] undefined!
WARNING: "ieee80211_get_hdrlen_from_skb"=20
[/home/shemminger/src/iwlwifi-0.0.8/compatible/iwlwifi.ko] undefined!
WARNING: "ieee80211_rate_control_unregister"=20
[/home/shemminger/src/iwlwifi-0.0.8/compatible/iwlwifi.ko] undefined!
WARNING: "ieee80211_register_hw"=20
[/home/shemminger/src/iwlwifi-0.0.8/compatible/iwlwifi.ko] undefined!
WARNING: "ieee80211_alloc_hw"=20
[/home/shemminger/src/iwlwifi-0.0.8/compatible/iwlwifi.ko] undefined!
WARNING: "ieee80211_free_hw"=20
[/home/shemminger/src/iwlwifi-0.0.8/compatible/iwlwifi.ko] undefined!
WARNING: "sta_info_put"=20
[/home/shemminger/src/iwlwifi-0.0.8/compatible/iwlwifi.ko] undefined!
  CC      /home/shemminger/src/iwlwifi-0.0.8/compatible/iwlwifi.mod.o
  LD [M]  /home/shemminger/src/iwlwifi-0.0.8/compatible/iwlwifi.ko
make[1]: Leaving directory `/home/shemminger/kernel/linux-2.6.20.1'

  LD [M]  /home/shemminger/src/iwlwifi-0.0.8/compatible/iwlwifi.ko
make[1]: Leaving directory `/home/shemminger/kernel/linux-2.6.20.1'

