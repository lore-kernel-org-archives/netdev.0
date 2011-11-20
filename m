From: Udo Steinberg <udo@hypervisor.org>
Subject: Firmware errors and warnings with Centrino Advanced-N 6205
Date: Sun, 20 Nov 2011 21:50:03 +0100
Message-ID: <20111120215003.0413cf95@x220>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/x5OCnZqUQ+=zjf66VHP6cEl"; protocol="application/pgp-signature"
To: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from os.inf.tu-dresden.de ([141.76.48.99]:51238 "EHLO
	os.inf.tu-dresden.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753824Ab1KTVRm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Nov 2011 16:17:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/x5OCnZqUQ+=zjf66VHP6cEl
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi,

I'm repeatedly getting firmware errors and warnings on my Centrino 6205 WiFi
card with Linux 3.1. These warnings keep filling the logs at a rate that is
not funny. Any idea how to fix this issue or at least rate-limit those
messages?

Cheers,

	- Udo

Excerpt from syslog:

Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: Microcode SW error detect=
ed.  Restarting 0x82000000.
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: Loaded firmware version: =
17.168.5.3 build 42301
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: Start IWL Error Log Dump:
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: Status: 0x000512E4, count=
: 6
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: 0x00002078 | ADVANCED_SYS=
ASSERT         =20
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: 0x00009514 | uPc
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: 0x00009496 | branchlink1
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: 0x00009496 | branchlink2
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: 0x0000D1F2 | interruptlin=
k1
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: 0x00000000 | interruptlin=
k2
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: 0x01008035 | data1
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: 0x0000C90F | data2
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: 0x000005A7 | line
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: 0x5080B520 | beacon time
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: 0xCC515AE0 | tsf low
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: 0x00000003 | tsf hi
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: 0x00000000 | time gp1
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: 0x29703BF0 | time gp2
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: 0x00000000 | time gp3
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: 0x000111A8 | uCode version
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: 0x000000B0 | hw version
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: 0x00480303 | board version
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: 0x09E8004E | hcmd
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: CSR values:
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: (2nd byte of CSR_INT_COAL=
ESCING is CSR_INT_PERIODIC_REG)
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0:        CSR_HW_IF_CONFIG_R=
EG: 0X00480303
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0:          CSR_INT_COALESCI=
NG: 0X0000ff40
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0:                     CSR_I=
NT: 0X00000000
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0:                CSR_INT_MA=
SK: 0X00000000
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0:           CSR_FH_INT_STAT=
US: 0X00000000
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0:                 CSR_GPIO_=
IN: 0X00000030
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0:                   CSR_RES=
ET: 0X00000000
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0:                CSR_GP_CNT=
RL: 0X080403c5
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0:                  CSR_HW_R=
EV: 0X000000b0
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0:              CSR_EEPROM_R=
EG: 0X07d60ffd
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0:               CSR_EEPROM_=
GP: 0X90000001
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0:              CSR_OTP_GP_R=
EG: 0X00030001
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0:                 CSR_GIO_R=
EG: 0X00080044
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0:            CSR_GP_UCODE_R=
EG: 0X000093bb
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0:           CSR_GP_DRIVER_R=
EG: 0X00000000
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0:           CSR_UCODE_DRV_G=
P1: 0X00000000
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0:           CSR_UCODE_DRV_G=
P2: 0X00000000
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0:                 CSR_LED_R=
EG: 0X00000078
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0:        CSR_DRAM_INT_TBL_R=
EG: 0X88214dd2
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0:        CSR_GIO_CHICKEN_BI=
TS: 0X27800200
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0:             CSR_ANA_PLL_C=
FG: 0X00000000
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0:           CSR_HW_REV_WA_R=
EG: 0X0001001a
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0:        CSR_DBG_HPET_MEM_R=
EG: 0Xffff0010
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: FH register values:
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0:         FH_RSCSR_CHNL0_ST=
TS_WPTR_REG: 0X21316d00
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0:        FH_RSCSR_CHNL0_RBD=
CB_BASE_REG: 0X021479c0
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0:                  FH_RSCSR=
_CHNL0_WPTR: 0X00000060
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0:         FH_MEM_RCSR_CHNL0=
_CONFIG_REG: 0X80819104
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0:          FH_MEM_RSSR_SHAR=
ED_CTRL_REG: 0X000000fc
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0:            FH_MEM_RSSR_RX=
_STATUS_REG: 0X07030000
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0:    FH_MEM_RSSR_RX_ENABLE_=
ERR_IRQ2DRV: 0X00000000
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0:                FH_TSSR_TX=
_STATUS_REG: 0X07ff0001
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0:                 FH_TSSR_T=
X_ERROR_REG: 0X00000000
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: Start IWL Event Log Dump:=
 display last 20 entries
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0695219435:0x028=
a001c:0217
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0695221022:0x028=
b001c:0206
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0695221023:0x000=
00001:0204
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0695221026:0x000=
00001:0214
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0695221027:0x010=
01110:0205
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0695221051:0x000=
00020:0208
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0695221070:0x000=
00000:0302
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0695221104:0x000=
00001:0203
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0695221109:0x028=
b001c:0206
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0695221110:0x000=
00040:0204
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0695221113:0x010=
00110:0211
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0695221117:0x000=
00000:0212
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0695221159:0x000=
00000:0215
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0695221162:0x000=
00008:0220
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0695221179:0x000=
00000:0302
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0695221211:0x000=
000d4:0303
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0695221215:0x000=
0128c:0217
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0695221215:0x028=
b001c:0217
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0695221224:0x09e=
8004e:0401
Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0695221234:0x000=
00000:0125
Nov 20 20:47:42 x220 kernel: iwlagn 0000:03:00.0: Error sending REPLY_ADD_S=
TA: time out after 2000ms.
Nov 20 20:47:42 x220 kernel: iwlagn 0000:03:00.0: Adding station 00:24:fe:4=
1:8d:0e failed.
Nov 20 20:47:42 x220 kernel: iwlagn 0000:03:00.0: Unable to add station 00:=
24:fe:41:8d:0e (-110)
Nov 20 20:47:42 x220 kernel: ------------[ cut here ]------------
Nov 20 20:47:42 x220 kernel: WARNING: at net/mac80211/util.c:1208 ieee80211=
_reconfig+0x1f1/0x407()
Nov 20 20:47:42 x220 kernel: Hardware name: 4290W4H
Nov 20 20:47:42 x220 kernel: Pid: 1896, comm: kworker/0:0 Not tainted 3.1.0=
 #2
Nov 20 20:47:42 x220 kernel: Call Trace:
Nov 20 20:47:42 x220 kernel:  [<ffffffff81036558>] ? warn_slowpath_common+0=
x73/0x87
Nov 20 20:47:42 x220 kernel:  [<ffffffff813b8966>] ? ieee80211_reconfig+0x1=
f1/0x407
Nov 20 20:47:42 x220 kernel:  [<ffffffff8139e8dc>] ? ieee80211_recalc_smps_=
work+0x32/0x32
Nov 20 20:47:42 x220 kernel:  [<ffffffff8139e95a>] ? ieee80211_restart_work=
+0x7e/0x87
Nov 20 20:47:42 x220 kernel:  [<ffffffff810472fa>] ? process_one_work+0x1c8=
/0x2e3
Nov 20 20:47:42 x220 kernel:  [<ffffffff810480c9>] ? worker_thread+0x17a/0x=
23a
Nov 20 20:47:42 x220 kernel:  [<ffffffff81047f4f>] ? manage_workers.clone.1=
8+0x15b/0x15b
Nov 20 20:47:42 x220 kernel:  [<ffffffff81047f4f>] ? manage_workers.clone.1=
8+0x15b/0x15b
Nov 20 20:47:42 x220 kernel:  [<ffffffff8104ba97>] ? kthread+0x7a/0x82
Nov 20 20:47:42 x220 kernel:  [<ffffffff813d21b4>] ? kernel_thread_helper+0=
x4/0x10
Nov 20 20:47:42 x220 kernel:  [<ffffffff8104ba1d>] ? kthread_flush_work_fn+=
0x11/0x11
Nov 20 20:47:42 x220 kernel:  [<ffffffff813d21b0>] ? gs_change+0xb/0xb
Nov 20 20:47:42 x220 kernel: ---[ end trace c69a09b105aa81ab ]---
Nov 20 20:47:42 x220 kernel: iwlagn 0000:03:00.0: Invalid station for AGG t=
id 0
Nov 20 20:47:42 x220 kernel: iwlagn 0000:03:00.0: Attempting to modify non-=
existing station 0
Nov 20 20:47:42 x220 kernel: ------------[ cut here ]------------
Nov 20 20:47:42 x220 kernel: WARNING: at drivers/net/wireless/iwlwifi/iwl-s=
ta.h:134 iwlagn_tx_skb+0xd2/0x68d()
Nov 20 20:47:42 x220 kernel: Hardware name: 4290W4H
Nov 20 20:47:42 x220 kernel: Pid: 3, comm: ksoftirqd/0 Tainted: G        W =
  3.1.0 #2
Nov 20 20:47:42 x220 kernel: Call Trace:
Nov 20 20:47:42 x220 kernel:  [<ffffffff81036558>] ? warn_slowpath_common+0=
x73/0x87
Nov 20 20:47:42 x220 kernel:  [<ffffffff8127ca3a>] ? iwlagn_tx_skb+0xd2/0x6=
8d
Nov 20 20:47:42 x220 kernel:  [<ffffffff8102adde>] ? update_curr+0x77/0xd0
Nov 20 20:47:42 x220 kernel:  [<ffffffff81276029>] ? iwlagn_mac_tx+0xd/0x1c
Nov 20 20:47:42 x220 kernel:  [<ffffffff813b4360>] ? __ieee80211_tx+0x18c/0=
x1ea
Nov 20 20:47:42 x220 kernel:  [<ffffffff813b5f55>] ? ieee80211_tx_pending+0=
x14b/0x20a
Nov 20 20:47:42 x220 kernel:  [<ffffffff8103ab0a>] ? tasklet_action+0x67/0x=
a7
Nov 20 20:47:42 x220 kernel:  [<ffffffff8103ae64>] ? __do_softirq+0x7f/0x106
Nov 20 20:47:42 x220 kernel:  [<ffffffff8103af96>] ? run_ksoftirqd+0xab/0x1=
93
Nov 20 20:47:42 x220 kernel:  [<ffffffff8103aeeb>] ? __do_softirq+0x106/0x1=
06
Nov 20 20:47:42 x220 kernel:  [<ffffffff8104ba97>] ? kthread+0x7a/0x82
Nov 20 20:47:42 x220 kernel:  [<ffffffff813d21b4>] ? kernel_thread_helper+0=
x4/0x10
Nov 20 20:47:42 x220 kernel:  [<ffffffff8104ba1d>] ? kthread_flush_work_fn+=
0x11/0x11
Nov 20 20:47:42 x220 kernel:  [<ffffffff813d21b0>] ? gs_change+0xb/0xb
Nov 20 20:47:42 x220 kernel: ---[ end trace c69a09b105aa81ac ]---
Nov 20 20:47:43 x220 kernel: ------------[ cut here ]------------
Nov 20 20:47:43 x220 kernel: WARNING: at drivers/net/wireless/iwlwifi/iwl-s=
ta.h:134 iwlagn_tx_skb+0xd2/0x68d()
Nov 20 20:47:43 x220 kernel: Hardware name: 4290W4H
Nov 20 20:47:43 x220 kernel: Pid: 1902, comm: firefox Tainted: G        W  =
 3.1.0 #2
Nov 20 20:47:43 x220 kernel: Call Trace:
Nov 20 20:47:43 x220 kernel:  [<ffffffff81036558>] ? warn_slowpath_common+0=
x73/0x87
Nov 20 20:47:43 x220 kernel:  [<ffffffff8127ca3a>] ? iwlagn_tx_skb+0xd2/0x6=
8d
Nov 20 20:47:43 x220 kernel:  [<ffffffff81276029>] ? iwlagn_mac_tx+0xd/0x1c
Nov 20 20:47:43 x220 kernel:  [<ffffffff813b4360>] ? __ieee80211_tx+0x18c/0=
x1ea
Nov 20 20:47:43 x220 kernel:  [<ffffffff813b54ba>] ? ieee80211_tx+0x95/0xad
Nov 20 20:47:43 x220 kernel:  [<ffffffff813b5618>] ? ieee80211_xmit+0x146/0=
x159
Nov 20 20:47:43 x220 kernel:  [<ffffffff813b5dbb>] ? ieee80211_subif_start_=
xmit+0x5b8/0x5d5
Nov 20 20:47:43 x220 kernel:  [<ffffffff81330ef8>] ? dev_hard_start_xmit+0x=
3f2/0x4f0
Nov 20 20:47:43 x220 kernel:  [<ffffffff81342978>] ? sch_direct_xmit+0x67/0=
x18d
Nov 20 20:47:43 x220 kernel:  [<ffffffff813313b5>] ? dev_queue_xmit+0x2fe/0=
x4fc
Nov 20 20:47:43 x220 kernel:  [<ffffffff8134f3b4>] ? ip_finish_output+0x216=
/0x267
Nov 20 20:47:43 x220 kernel:  [<ffffffff8134ea04>] ? ip_queue_xmit+0x2c8/0x=
304
Nov 20 20:47:43 x220 kernel:  [<ffffffff81051ff1>] ? getnstimeofday+0x54/0x=
a5
Nov 20 20:47:43 x220 kernel:  [<ffffffff8136014b>] ? tcp_transmit_skb+0x6b4=
/0x6f4
Nov 20 20:47:43 x220 kernel:  [<ffffffff813609d3>] ? tcp_write_xmit+0x7c8/0=
x8b0
Nov 20 20:47:43 x220 kernel:  [<ffffffff81328188>] ? __alloc_skb+0x5f/0x114
Nov 20 20:47:43 x220 kernel:  [<ffffffff81360b04>] ? __tcp_push_pending_fra=
mes+0x18/0x73
Nov 20 20:47:43 x220 kernel:  [<ffffffff81356ab0>] ? tcp_close+0x157/0x390
Nov 20 20:47:43 x220 kernel:  [<ffffffff81370c00>] ? inet_release+0x77/0x80
Nov 20 20:47:43 x220 kernel:  [<ffffffff81322d65>] ? sock_release+0x10/0x54
Nov 20 20:47:43 x220 kernel:  [<ffffffff81322dcb>] ? sock_close+0x22/0x29
Nov 20 20:47:43 x220 kernel:  [<ffffffff810a89cf>] ? fput+0xea/0x194
Nov 20 20:47:43 x220 kernel:  [<ffffffff810a6d0f>] ? filp_close+0x62/0x6a
Nov 20 20:47:43 x220 kernel:  [<ffffffff810a6da8>] ? sys_close+0x91/0xd5
Nov 20 20:47:43 x220 kernel:  [<ffffffff813d0e3b>] ? system_call_fastpath+0=
x16/0x1b
Nov 20 20:47:43 x220 kernel: ---[ end trace c69a09b105aa81ad ]---
Nov 20 20:47:43 x220 kernel: ------------[ cut here ]------------
Nov 20 20:47:43 x220 kernel: WARNING: at drivers/net/wireless/iwlwifi/iwl-s=
ta.h:134 iwlagn_tx_skb+0xd2/0x68d()
Nov 20 20:47:43 x220 kernel: Hardware name: 4290W4H
Nov 20 20:47:43 x220 kernel: Pid: 0, comm: swapper Tainted: G        W   3.=
1.0 #2
Nov 20 20:47:43 x220 kernel: Call Trace:
Nov 20 20:47:43 x220 kernel:  <IRQ>  [<ffffffff81036558>] ? warn_slowpath_c=
ommon+0x73/0x87
Nov 20 20:47:43 x220 kernel:  [<ffffffff8127ca3a>] ? iwlagn_tx_skb+0xd2/0x6=
8d
Nov 20 20:47:43 x220 kernel:  [<ffffffff81276029>] ? iwlagn_mac_tx+0xd/0x1c
Nov 20 20:47:43 x220 kernel:  [<ffffffff813b4360>] ? __ieee80211_tx+0x18c/0=
x1ea
Nov 20 20:47:43 x220 kernel:  [<ffffffff813b54ba>] ? ieee80211_tx+0x95/0xad
Nov 20 20:47:43 x220 kernel:  [<ffffffff813b5618>] ? ieee80211_xmit+0x146/0=
x159
Nov 20 20:47:43 x220 kernel:  [<ffffffff813b5dbb>] ? ieee80211_subif_start_=
xmit+0x5b8/0x5d5
Nov 20 20:47:43 x220 kernel:  [<ffffffff81330ef8>] ? dev_hard_start_xmit+0x=
3f2/0x4f0
Nov 20 20:47:43 x220 kernel:  [<ffffffff81342978>] ? sch_direct_xmit+0x67/0=
x18d
Nov 20 20:47:43 x220 kernel:  [<ffffffff813313b5>] ? dev_queue_xmit+0x2fe/0=
x4fc
Nov 20 20:47:43 x220 kernel:  [<ffffffff8102adde>] ? update_curr+0x77/0xd0
Nov 20 20:47:43 x220 kernel:  [<ffffffff8134f3b4>] ? ip_finish_output+0x216=
/0x267
Nov 20 20:47:43 x220 kernel:  [<ffffffff8134ea04>] ? ip_queue_xmit+0x2c8/0x=
304
Nov 20 20:47:43 x220 kernel:  [<ffffffff81051ff1>] ? getnstimeofday+0x54/0x=
a5
Nov 20 20:47:43 x220 kernel:  [<ffffffff8136014b>] ? tcp_transmit_skb+0x6b4=
/0x6f4
Nov 20 20:47:43 x220 kernel:  [<ffffffff8135a3f9>] ? tcp_fin.clone.31+0x5c/=
0x18f
Nov 20 20:47:43 x220 kernel:  [<ffffffff8135a94e>] ? tcp_data_queue+0x2de/0=
xb46
Nov 20 20:47:43 x220 kernel:  [<ffffffff8135dca3>] ? tcp_validate_incoming+=
0x1bb/0x28b
Nov 20 20:47:43 x220 kernel:  [<ffffffff8135ec3b>] ? tcp_rcv_state_process+=
0x8f5/0x96e
Nov 20 20:47:43 x220 kernel:  [<ffffffff81363d0d>] ? tcp_v4_do_rcv+0x240/0x=
284
Nov 20 20:47:43 x220 kernel:  [<ffffffff8133f9f4>] ? sk_filter+0x6d/0x78
Nov 20 20:47:43 x220 kernel:  [<ffffffff81365aa1>] ? tcp_v4_rcv+0x416/0x65e
Nov 20 20:47:43 x220 kernel:  [<ffffffff8134b6b0>] ? ip_local_deliver+0xa5/=
0xfe
Nov 20 20:47:43 x220 kernel:  [<ffffffff8132ee96>] ? __netif_receive_skb+0x=
279/0x2af
Nov 20 20:47:43 x220 kernel:  [<ffffffff810b3a0a>] ? send_sigio_to_task+0xf=
6/0x108
Nov 20 20:47:43 x220 kernel:  [<ffffffff81331f3c>] ? netif_receive_skb+0x7e=
/0x84
Nov 20 20:47:43 x220 kernel:  [<ffffffff8104033b>] ? mod_timer+0x189/0x1a1
Nov 20 20:47:43 x220 kernel:  [<ffffffff813b1201>] ? ieee80211_deliver_skb+=
0xc3/0x104
Nov 20 20:47:43 x220 kernel:  [<ffffffff813b20c8>] ? ieee80211_rx_handlers+=
0xe86/0x17e2
Nov 20 20:47:43 x220 kernel:  [<ffffffff810b42fd>] ? send_sigio+0x91/0xa7
Nov 20 20:47:43 x220 kernel:  [<ffffffff8102f3b6>] ? __wake_up+0x35/0x46
Nov 20 20:47:43 x220 kernel:  [<ffffffff813b30d5>] ? ieee80211_prepare_and_=
rx_handle+0x6b1/0x734
Nov 20 20:47:43 x220 kernel:  [<ffffffff813b39f8>] ? ieee80211_rx+0x735/0x7=
ac
Nov 20 20:47:43 x220 kernel:  [<ffffffff81285f46>] ? iwl_rx_reply_rx+0x467/=
0x47e
Nov 20 20:47:43 x220 kernel:  [<ffffffff813a021b>] ? ieee80211_tx_status+0x=
72d/0x73f
Nov 20 20:47:43 x220 kernel:  [<ffffffff8128c444>] ? iwl_irq_tasklet+0x402/=
0x675
Nov 20 20:47:43 x220 kernel:  [<ffffffff8103ab0a>] ? tasklet_action+0x67/0x=
a7
Nov 20 20:47:43 x220 kernel:  [<ffffffff8103ae64>] ? __do_softirq+0x7f/0x106
Nov 20 20:47:43 x220 kernel:  [<ffffffff813d22ac>] ? call_softirq+0x1c/0x26
Nov 20 20:47:43 x220 kernel:  [<ffffffff810033fe>] ? do_softirq+0x31/0x67
Nov 20 20:47:43 x220 kernel:  [<ffffffff8103b118>] ? irq_exit+0x44/0xb0
Nov 20 20:47:43 x220 kernel:  [<ffffffff8100313f>] ? do_IRQ+0x94/0xad
Nov 20 20:47:43 x220 kernel:  [<ffffffff813d07eb>] ? common_interrupt+0x6b/=
0x6b
Nov 20 20:47:43 x220 kernel:  <EOI>  [<ffffffff8104f02c>] ? __hrtimer_start=
_range_ns+0x2c6/0x2d9
Nov 20 20:47:43 x220 kernel:  [<ffffffff8118a94a>] ? intel_idle+0xcd/0xe9
Nov 20 20:47:43 x220 kernel:  [<ffffffff8118a926>] ? intel_idle+0xa9/0xe9
Nov 20 20:47:43 x220 kernel:  [<ffffffff812dca4d>] ? cpuidle_idle_call+0xa0=
/0xdb
Nov 20 20:47:43 x220 kernel:  [<ffffffff81000699>] ? cpu_idle+0x53/0x7c
Nov 20 20:47:43 x220 kernel:  [<ffffffff816879fa>] ? start_kernel+0x2be/0x2=
c9
Nov 20 20:47:43 x220 kernel: ---[ end trace c69a09b105aa81ae ]---
Nov 20 20:47:43 x220 kernel: ------------[ cut here ]------------
Nov 20 20:47:43 x220 kernel: WARNING: at drivers/net/wireless/iwlwifi/iwl-s=
ta.h:134 iwlagn_tx_skb+0xd2/0x68d()
Nov 20 20:47:43 x220 kernel: Hardware name: 4290W4H
Nov 20 20:47:43 x220 kernel: Pid: 0, comm: swapper Tainted: G        W   3.=
1.0 #2
Nov 20 20:47:43 x220 kernel: Call Trace:
Nov 20 20:47:43 x220 kernel:  <IRQ>  [<ffffffff81036558>] ? warn_slowpath_c=
ommon+0x73/0x87
Nov 20 20:47:43 x220 kernel:  [<ffffffff8127ca3a>] ? iwlagn_tx_skb+0xd2/0x6=
8d
Nov 20 20:47:43 x220 kernel:  [<ffffffff81276029>] ? iwlagn_mac_tx+0xd/0x1c
Nov 20 20:47:43 x220 kernel:  [<ffffffff813b4360>] ? __ieee80211_tx+0x18c/0=
x1ea
Nov 20 20:47:43 x220 kernel:  [<ffffffff813b54ba>] ? ieee80211_tx+0x95/0xad
Nov 20 20:47:43 x220 kernel:  [<ffffffff813b5618>] ? ieee80211_xmit+0x146/0=
x159
Nov 20 20:47:43 x220 kernel:  [<ffffffff813b5dbb>] ? ieee80211_subif_start_=
xmit+0x5b8/0x5d5
Nov 20 20:47:43 x220 kernel:  [<ffffffff81330ef8>] ? dev_hard_start_xmit+0x=
3f2/0x4f0
Nov 20 20:47:43 x220 kernel:  [<ffffffff81048223>] ? queue_work_on+0x16/0x20
Nov 20 20:47:43 x220 kernel:  [<ffffffff81048274>] ? queue_work+0x47/0x52
Nov 20 20:47:43 x220 kernel:  [<ffffffff81342978>] ? sch_direct_xmit+0x67/0=
x18d
Nov 20 20:47:43 x220 kernel:  [<ffffffff810b42fd>] ? send_sigio+0x91/0xa7
Nov 20 20:47:43 x220 kernel:  [<ffffffff813313b5>] ? dev_queue_xmit+0x2fe/0=
x4fc
Nov 20 20:47:43 x220 kernel:  [<ffffffff8107a785>] ? free_one_page+0x24e/0x=
264
Nov 20 20:47:43 x220 kernel:  [<ffffffff8134f3b4>] ? ip_finish_output+0x216=
/0x267
Nov 20 20:47:43 x220 kernel:  [<ffffffff8134ea04>] ? ip_queue_xmit+0x2c8/0x=
304
Nov 20 20:47:43 x220 kernel:  [<ffffffff81051ff1>] ? getnstimeofday+0x54/0x=
a5
Nov 20 20:47:43 x220 kernel:  [<ffffffff8136014b>] ? tcp_transmit_skb+0x6b4=
/0x6f4
Nov 20 20:47:43 x220 kernel:  [<ffffffff81360f7b>] ? tcp_retransmit_skb+0x4=
1c/0x505
Nov 20 20:47:43 x220 kernel:  [<ffffffff81285f46>] ? iwl_rx_reply_rx+0x467/=
0x47e
Nov 20 20:47:43 x220 kernel:  [<ffffffff81362ca0>] ? tcp_retransmit_timer+0=
x4f8/0x4f8
Nov 20 20:47:43 x220 kernel:  [<ffffffff81362b02>] ? tcp_retransmit_timer+0=
x35a/0x4f8
Nov 20 20:47:43 x220 kernel:  [<ffffffff81362d3b>] ? tcp_write_timer+0x9b/0=
x18d
Nov 20 20:47:43 x220 kernel:  [<ffffffff8103fe83>] ? run_timer_softirq+0x19=
b/0x230
Nov 20 20:47:43 x220 kernel:  [<ffffffff8103ae64>] ? __do_softirq+0x7f/0x106
Nov 20 20:47:43 x220 kernel:  [<ffffffff813d22ac>] ? call_softirq+0x1c/0x26
Nov 20 20:47:43 x220 kernel:  [<ffffffff810033fe>] ? do_softirq+0x31/0x67
Nov 20 20:47:43 x220 kernel:  [<ffffffff8103b118>] ? irq_exit+0x44/0xb0
Nov 20 20:47:43 x220 kernel:  [<ffffffff81014a09>] ? smp_apic_timer_interru=
pt+0x85/0x95
Nov 20 20:47:43 x220 kernel:  [<ffffffff813d184b>] ? apic_timer_interrupt+0=
x6b/0x70
Nov 20 20:47:43 x220 kernel:  <EOI>  [<ffffffff8118a94a>] ? intel_idle+0xcd=
/0xe9
Nov 20 20:47:43 x220 kernel:  [<ffffffff8118a926>] ? intel_idle+0xa9/0xe9
Nov 20 20:47:43 x220 kernel:  [<ffffffff812dca4d>] ? cpuidle_idle_call+0xa0=
/0xdb
Nov 20 20:47:43 x220 kernel:  [<ffffffff81000699>] ? cpu_idle+0x53/0x7c
Nov 20 20:47:43 x220 kernel:  [<ffffffff816879fa>] ? start_kernel+0x2be/0x2=
c9
Nov 20 20:47:43 x220 kernel: ---[ end trace c69a09b105aa81af ]---

... and it goes on and on

--Sig_/x5OCnZqUQ+=zjf66VHP6cEl
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iEYEARECAAYFAk7JZ/sACgkQnhRzXSM7nSlMcgCdH4pddcWJo+V1SAA2fa2PueLP
kOMAnjFgAc2fH5Ruj+LVz0d6UNh9OO71
=MTLa
-----END PGP SIGNATURE-----

--Sig_/x5OCnZqUQ+=zjf66VHP6cEl--
