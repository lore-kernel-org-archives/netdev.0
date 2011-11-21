From: Udo Steinberg <udo@hypervisor.org>
Subject: Re: Firmware errors and warnings with Centrino Advanced-N 6205
Date: Mon, 21 Nov 2011 19:48:24 +0100
Message-ID: <20111121194824.12f4c276@x220>
References: <20111120210012.405bd632@x220>
	<1321889065.2258.5.camel@wwguy-ubuntu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/cKCrnKDW1GjStIV/uPmn/+f"; protocol="application/pgp-signature"
Cc: Linux Network Mailing List <netdev@vger.kernel.org>,
	linux-wireless@vger.kernel.org
To: wwguy <wey-yi.w.guy@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from os.inf.tu-dresden.de ([141.76.48.99]:48214 "EHLO
	os.inf.tu-dresden.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751842Ab1KUSsn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 13:48:43 -0500
In-Reply-To: <1321889065.2258.5.camel@wwguy-ubuntu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/cKCrnKDW1GjStIV/uPmn/+f
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Wey,

Yes, I'm using a 40 Mhz channel. "iw wlan0 link" reports:

Connected to 00:24:fe:41:8d:0e (on wlan0)
        freq: 2412
        RX: 80815 bytes (507 packets)
        TX: 3881 bytes (34 packets)
        signal: -40 dBm
        tx bitrate: 40.5 MBit/s MCS 2 40Mhz

Cheers,

	- Udo

On Mon, 21 Nov 2011 07:24:25 -0800 wwguy (W) wrote:

W> Hi Udo,
W>=20
W> Are you using 40MHz?
W>=20
W> Thanks
W> Wey
W>=20
W> On Sun, 2011-11-20 at 12:00 -0800, Udo Steinberg wrote:
W> > Hi,
W> >=20
W> > I'm repeatedly getting firmware errors and warnings on my Centrino 620=
5 WiFi
W> > card with Linux 3.1. These warnings keep filling the logs at a rate th=
at is
W> > not funny. Any idea how to fix this issue or at least rate-limit those
W> > messages?
W> >=20
W> > Cheers,
W> >=20
W> > 	- Udo
W> >=20
W> > Excerpt from syslog:
W> >=20
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: Microcode SW error d=
etected.  Restarting 0x82000000.
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: Loaded firmware vers=
ion: 17.168.5.3 build 42301
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: Start IWL Error Log =
Dump:
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: Status: 0x000512E4, =
count: 6
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: 0x00002078 | ADVANCE=
D_SYSASSERT         =20
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: 0x00009514 | uPc
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: 0x00009496 | branchl=
ink1
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: 0x00009496 | branchl=
ink2
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: 0x0000D1F2 | interru=
ptlink1
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: 0x00000000 | interru=
ptlink2
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: 0x01008035 | data1
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: 0x0000C90F | data2
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: 0x000005A7 | line
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: 0x5080B520 | beacon =
time
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: 0xCC515AE0 | tsf low
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: 0x00000003 | tsf hi
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: 0x00000000 | time gp1
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: 0x29703BF0 | time gp2
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: 0x00000000 | time gp3
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: 0x000111A8 | uCode v=
ersion
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: 0x000000B0 | hw vers=
ion
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: 0x00480303 | board v=
ersion
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: 0x09E8004E | hcmd
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: CSR values:
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: (2nd byte of CSR_INT=
_COALESCING is CSR_INT_PERIODIC_REG)
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0:        CSR_HW_IF_CON=
FIG_REG: 0X00480303
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0:          CSR_INT_COA=
LESCING: 0X0000ff40
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0:                     =
CSR_INT: 0X00000000
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0:                CSR_I=
NT_MASK: 0X00000000
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0:           CSR_FH_INT=
_STATUS: 0X00000000
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0:                 CSR_=
GPIO_IN: 0X00000030
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0:                   CS=
R_RESET: 0X00000000
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0:                CSR_G=
P_CNTRL: 0X080403c5
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0:                  CSR=
_HW_REV: 0X000000b0
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0:              CSR_EEP=
ROM_REG: 0X07d60ffd
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0:               CSR_EE=
PROM_GP: 0X90000001
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0:              CSR_OTP=
_GP_REG: 0X00030001
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0:                 CSR_=
GIO_REG: 0X00080044
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0:            CSR_GP_UC=
ODE_REG: 0X000093bb
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0:           CSR_GP_DRI=
VER_REG: 0X00000000
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0:           CSR_UCODE_=
DRV_GP1: 0X00000000
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0:           CSR_UCODE_=
DRV_GP2: 0X00000000
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0:                 CSR_=
LED_REG: 0X00000078
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0:        CSR_DRAM_INT_=
TBL_REG: 0X88214dd2
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0:        CSR_GIO_CHICK=
EN_BITS: 0X27800200
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0:             CSR_ANA_=
PLL_CFG: 0X00000000
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0:           CSR_HW_REV=
_WA_REG: 0X0001001a
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0:        CSR_DBG_HPET_=
MEM_REG: 0Xffff0010
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: FH register values:
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0:         FH_RSCSR_CHN=
L0_STTS_WPTR_REG: 0X21316d00
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0:        FH_RSCSR_CHNL=
0_RBDCB_BASE_REG: 0X021479c0
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0:                  FH_=
RSCSR_CHNL0_WPTR: 0X00000060
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0:         FH_MEM_RCSR_=
CHNL0_CONFIG_REG: 0X80819104
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0:          FH_MEM_RSSR=
_SHARED_CTRL_REG: 0X000000fc
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0:            FH_MEM_RS=
SR_RX_STATUS_REG: 0X07030000
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0:    FH_MEM_RSSR_RX_EN=
ABLE_ERR_IRQ2DRV: 0X00000000
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0:                FH_TS=
SR_TX_STATUS_REG: 0X07ff0001
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0:                 FH_T=
SSR_TX_ERROR_REG: 0X00000000
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: Start IWL Event Log =
Dump: display last 20 entries
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0695219435:=
0x028a001c:0217
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0695221022:=
0x028b001c:0206
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0695221023:=
0x00000001:0204
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0695221026:=
0x00000001:0214
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0695221027:=
0x01001110:0205
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0695221051:=
0x00000020:0208
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0695221070:=
0x00000000:0302
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0695221104:=
0x00000001:0203
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0695221109:=
0x028b001c:0206
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0695221110:=
0x00000040:0204
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0695221113:=
0x01000110:0211
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0695221117:=
0x00000000:0212
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0695221159:=
0x00000000:0215
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0695221162:=
0x00000008:0220
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0695221179:=
0x00000000:0302
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0695221211:=
0x000000d4:0303
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0695221215:=
0x0000128c:0217
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0695221215:=
0x028b001c:0217
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0695221224:=
0x09e8004e:0401
W> > Nov 20 20:47:40 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0695221234:=
0x00000000:0125
W> > Nov 20 20:47:42 x220 kernel: iwlagn 0000:03:00.0: Error sending REPLY_=
ADD_STA: time out after 2000ms.
W> > Nov 20 20:47:42 x220 kernel: iwlagn 0000:03:00.0: Adding station 00:24=
:fe:41:8d:0e failed.
W> > Nov 20 20:47:42 x220 kernel: iwlagn 0000:03:00.0: Unable to add statio=
n 00:24:fe:41:8d:0e (-110)
W> > Nov 20 20:47:42 x220 kernel: ------------[ cut here ]------------
W> > Nov 20 20:47:42 x220 kernel: WARNING: at net/mac80211/util.c:1208 ieee=
80211_reconfig+0x1f1/0x407()
W> > Nov 20 20:47:42 x220 kernel: Hardware name: 4290W4H
W> > Nov 20 20:47:42 x220 kernel: Pid: 1896, comm: kworker/0:0 Not tainted =
3.1.0 #2
W> > Nov 20 20:47:42 x220 kernel: Call Trace:
W> > Nov 20 20:47:42 x220 kernel:  [<ffffffff81036558>] ? warn_slowpath_com=
mon+0x73/0x87
W> > Nov 20 20:47:42 x220 kernel:  [<ffffffff813b8966>] ? ieee80211_reconfi=
g+0x1f1/0x407
W> > Nov 20 20:47:42 x220 kernel:  [<ffffffff8139e8dc>] ? ieee80211_recalc_=
smps_work+0x32/0x32
W> > Nov 20 20:47:42 x220 kernel:  [<ffffffff8139e95a>] ? ieee80211_restart=
_work+0x7e/0x87
W> > Nov 20 20:47:42 x220 kernel:  [<ffffffff810472fa>] ? process_one_work+=
0x1c8/0x2e3
W> > Nov 20 20:47:42 x220 kernel:  [<ffffffff810480c9>] ? worker_thread+0x1=
7a/0x23a
W> > Nov 20 20:47:42 x220 kernel:  [<ffffffff81047f4f>] ? manage_workers.cl=
one.18+0x15b/0x15b
W> > Nov 20 20:47:42 x220 kernel:  [<ffffffff81047f4f>] ? manage_workers.cl=
one.18+0x15b/0x15b
W> > Nov 20 20:47:42 x220 kernel:  [<ffffffff8104ba97>] ? kthread+0x7a/0x82
W> > Nov 20 20:47:42 x220 kernel:  [<ffffffff813d21b4>] ? kernel_thread_hel=
per+0x4/0x10
W> > Nov 20 20:47:42 x220 kernel:  [<ffffffff8104ba1d>] ? kthread_flush_wor=
k_fn+0x11/0x11
W> > Nov 20 20:47:42 x220 kernel:  [<ffffffff813d21b0>] ? gs_change+0xb/0xb
W> > Nov 20 20:47:42 x220 kernel: ---[ end trace c69a09b105aa81ab ]---
W> > Nov 20 20:47:42 x220 kernel: iwlagn 0000:03:00.0: Invalid station for =
AGG tid 0
W> > Nov 20 20:47:42 x220 kernel: iwlagn 0000:03:00.0: Attempting to modify=
 non-existing station 0
W> > Nov 20 20:47:42 x220 kernel: ------------[ cut here ]------------
W> > Nov 20 20:47:42 x220 kernel: WARNING: at drivers/net/wireless/iwlwifi/=
iwl-sta.h:134 iwlagn_tx_skb+0xd2/0x68d()
W> > Nov 20 20:47:42 x220 kernel: Hardware name: 4290W4H
W> > Nov 20 20:47:42 x220 kernel: Pid: 3, comm: ksoftirqd/0 Tainted: G     =
   W   3.1.0 #2
W> > Nov 20 20:47:42 x220 kernel: Call Trace:
W> > Nov 20 20:47:42 x220 kernel:  [<ffffffff81036558>] ? warn_slowpath_com=
mon+0x73/0x87
W> > Nov 20 20:47:42 x220 kernel:  [<ffffffff8127ca3a>] ? iwlagn_tx_skb+0xd=
2/0x68d
W> > Nov 20 20:47:42 x220 kernel:  [<ffffffff8102adde>] ? update_curr+0x77/=
0xd0
W> > Nov 20 20:47:42 x220 kernel:  [<ffffffff81276029>] ? iwlagn_mac_tx+0xd=
/0x1c
W> > Nov 20 20:47:42 x220 kernel:  [<ffffffff813b4360>] ? __ieee80211_tx+0x=
18c/0x1ea
W> > Nov 20 20:47:42 x220 kernel:  [<ffffffff813b5f55>] ? ieee80211_tx_pend=
ing+0x14b/0x20a
W> > Nov 20 20:47:42 x220 kernel:  [<ffffffff8103ab0a>] ? tasklet_action+0x=
67/0xa7
W> > Nov 20 20:47:42 x220 kernel:  [<ffffffff8103ae64>] ? __do_softirq+0x7f=
/0x106
W> > Nov 20 20:47:42 x220 kernel:  [<ffffffff8103af96>] ? run_ksoftirqd+0xa=
b/0x193
W> > Nov 20 20:47:42 x220 kernel:  [<ffffffff8103aeeb>] ? __do_softirq+0x10=
6/0x106
W> > Nov 20 20:47:42 x220 kernel:  [<ffffffff8104ba97>] ? kthread+0x7a/0x82
W> > Nov 20 20:47:42 x220 kernel:  [<ffffffff813d21b4>] ? kernel_thread_hel=
per+0x4/0x10
W> > Nov 20 20:47:42 x220 kernel:  [<ffffffff8104ba1d>] ? kthread_flush_wor=
k_fn+0x11/0x11
W> > Nov 20 20:47:42 x220 kernel:  [<ffffffff813d21b0>] ? gs_change+0xb/0xb
W> > Nov 20 20:47:42 x220 kernel: ---[ end trace c69a09b105aa81ac ]---
W> > Nov 20 20:47:43 x220 kernel: ------------[ cut here ]------------
W> > Nov 20 20:47:43 x220 kernel: WARNING: at drivers/net/wireless/iwlwifi/=
iwl-sta.h:134 iwlagn_tx_skb+0xd2/0x68d()
W> > Nov 20 20:47:43 x220 kernel: Hardware name: 4290W4H
W> > Nov 20 20:47:43 x220 kernel: Pid: 1902, comm: firefox Tainted: G      =
  W   3.1.0 #2
W> > Nov 20 20:47:43 x220 kernel: Call Trace:
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff81036558>] ? warn_slowpath_com=
mon+0x73/0x87
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff8127ca3a>] ? iwlagn_tx_skb+0xd=
2/0x68d
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff81276029>] ? iwlagn_mac_tx+0xd=
/0x1c
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff813b4360>] ? __ieee80211_tx+0x=
18c/0x1ea
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff813b54ba>] ? ieee80211_tx+0x95=
/0xad
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff813b5618>] ? ieee80211_xmit+0x=
146/0x159
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff813b5dbb>] ? ieee80211_subif_s=
tart_xmit+0x5b8/0x5d5
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff81330ef8>] ? dev_hard_start_xm=
it+0x3f2/0x4f0
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff81342978>] ? sch_direct_xmit+0=
x67/0x18d
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff813313b5>] ? dev_queue_xmit+0x=
2fe/0x4fc
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff8134f3b4>] ? ip_finish_output+=
0x216/0x267
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff8134ea04>] ? ip_queue_xmit+0x2=
c8/0x304
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff81051ff1>] ? getnstimeofday+0x=
54/0xa5
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff8136014b>] ? tcp_transmit_skb+=
0x6b4/0x6f4
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff813609d3>] ? tcp_write_xmit+0x=
7c8/0x8b0
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff81328188>] ? __alloc_skb+0x5f/=
0x114
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff81360b04>] ? __tcp_push_pendin=
g_frames+0x18/0x73
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff81356ab0>] ? tcp_close+0x157/0=
x390
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff81370c00>] ? inet_release+0x77=
/0x80
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff81322d65>] ? sock_release+0x10=
/0x54
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff81322dcb>] ? sock_close+0x22/0=
x29
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff810a89cf>] ? fput+0xea/0x194
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff810a6d0f>] ? filp_close+0x62/0=
x6a
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff810a6da8>] ? sys_close+0x91/0x=
d5
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff813d0e3b>] ? system_call_fastp=
ath+0x16/0x1b
W> > Nov 20 20:47:43 x220 kernel: ---[ end trace c69a09b105aa81ad ]---
W> > Nov 20 20:47:43 x220 kernel: ------------[ cut here ]------------
W> > Nov 20 20:47:43 x220 kernel: WARNING: at drivers/net/wireless/iwlwifi/=
iwl-sta.h:134 iwlagn_tx_skb+0xd2/0x68d()
W> > Nov 20 20:47:43 x220 kernel: Hardware name: 4290W4H
W> > Nov 20 20:47:43 x220 kernel: Pid: 0, comm: swapper Tainted: G        W=
   3.1.0 #2
W> > Nov 20 20:47:43 x220 kernel: Call Trace:
W> > Nov 20 20:47:43 x220 kernel:  <IRQ>  [<ffffffff81036558>] ? warn_slowp=
ath_common+0x73/0x87
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff8127ca3a>] ? iwlagn_tx_skb+0xd=
2/0x68d
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff81276029>] ? iwlagn_mac_tx+0xd=
/0x1c
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff813b4360>] ? __ieee80211_tx+0x=
18c/0x1ea
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff813b54ba>] ? ieee80211_tx+0x95=
/0xad
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff813b5618>] ? ieee80211_xmit+0x=
146/0x159
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff813b5dbb>] ? ieee80211_subif_s=
tart_xmit+0x5b8/0x5d5
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff81330ef8>] ? dev_hard_start_xm=
it+0x3f2/0x4f0
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff81342978>] ? sch_direct_xmit+0=
x67/0x18d
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff813313b5>] ? dev_queue_xmit+0x=
2fe/0x4fc
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff8102adde>] ? update_curr+0x77/=
0xd0
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff8134f3b4>] ? ip_finish_output+=
0x216/0x267
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff8134ea04>] ? ip_queue_xmit+0x2=
c8/0x304
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff81051ff1>] ? getnstimeofday+0x=
54/0xa5
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff8136014b>] ? tcp_transmit_skb+=
0x6b4/0x6f4
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff8135a3f9>] ? tcp_fin.clone.31+=
0x5c/0x18f
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff8135a94e>] ? tcp_data_queue+0x=
2de/0xb46
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff8135dca3>] ? tcp_validate_inco=
ming+0x1bb/0x28b
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff8135ec3b>] ? tcp_rcv_state_pro=
cess+0x8f5/0x96e
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff81363d0d>] ? tcp_v4_do_rcv+0x2=
40/0x284
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff8133f9f4>] ? sk_filter+0x6d/0x=
78
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff81365aa1>] ? tcp_v4_rcv+0x416/=
0x65e
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff8134b6b0>] ? ip_local_deliver+=
0xa5/0xfe
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff8132ee96>] ? __netif_receive_s=
kb+0x279/0x2af
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff810b3a0a>] ? send_sigio_to_tas=
k+0xf6/0x108
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff81331f3c>] ? netif_receive_skb=
+0x7e/0x84
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff8104033b>] ? mod_timer+0x189/0=
x1a1
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff813b1201>] ? ieee80211_deliver=
_skb+0xc3/0x104
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff813b20c8>] ? ieee80211_rx_hand=
lers+0xe86/0x17e2
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff810b42fd>] ? send_sigio+0x91/0=
xa7
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff8102f3b6>] ? __wake_up+0x35/0x=
46
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff813b30d5>] ? ieee80211_prepare=
_and_rx_handle+0x6b1/0x734
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff813b39f8>] ? ieee80211_rx+0x73=
5/0x7ac
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff81285f46>] ? iwl_rx_reply_rx+0=
x467/0x47e
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff813a021b>] ? ieee80211_tx_stat=
us+0x72d/0x73f
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff8128c444>] ? iwl_irq_tasklet+0=
x402/0x675
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff8103ab0a>] ? tasklet_action+0x=
67/0xa7
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff8103ae64>] ? __do_softirq+0x7f=
/0x106
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff813d22ac>] ? call_softirq+0x1c=
/0x26
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff810033fe>] ? do_softirq+0x31/0=
x67
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff8103b118>] ? irq_exit+0x44/0xb0
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff8100313f>] ? do_IRQ+0x94/0xad
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff813d07eb>] ? common_interrupt+=
0x6b/0x6b
W> > Nov 20 20:47:43 x220 kernel:  <EOI>  [<ffffffff8104f02c>] ? __hrtimer_=
start_range_ns+0x2c6/0x2d9
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff8118a94a>] ? intel_idle+0xcd/0=
xe9
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff8118a926>] ? intel_idle+0xa9/0=
xe9
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff812dca4d>] ? cpuidle_idle_call=
+0xa0/0xdb
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff81000699>] ? cpu_idle+0x53/0x7c
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff816879fa>] ? start_kernel+0x2b=
e/0x2c9
W> > Nov 20 20:47:43 x220 kernel: ---[ end trace c69a09b105aa81ae ]---
W> > Nov 20 20:47:43 x220 kernel: ------------[ cut here ]------------
W> > Nov 20 20:47:43 x220 kernel: WARNING: at drivers/net/wireless/iwlwifi/=
iwl-sta.h:134 iwlagn_tx_skb+0xd2/0x68d()
W> > Nov 20 20:47:43 x220 kernel: Hardware name: 4290W4H
W> > Nov 20 20:47:43 x220 kernel: Pid: 0, comm: swapper Tainted: G        W=
   3.1.0 #2
W> > Nov 20 20:47:43 x220 kernel: Call Trace:
W> > Nov 20 20:47:43 x220 kernel:  <IRQ>  [<ffffffff81036558>] ? warn_slowp=
ath_common+0x73/0x87
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff8127ca3a>] ? iwlagn_tx_skb+0xd=
2/0x68d
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff81276029>] ? iwlagn_mac_tx+0xd=
/0x1c
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff813b4360>] ? __ieee80211_tx+0x=
18c/0x1ea
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff813b54ba>] ? ieee80211_tx+0x95=
/0xad
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff813b5618>] ? ieee80211_xmit+0x=
146/0x159
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff813b5dbb>] ? ieee80211_subif_s=
tart_xmit+0x5b8/0x5d5
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff81330ef8>] ? dev_hard_start_xm=
it+0x3f2/0x4f0
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff81048223>] ? queue_work_on+0x1=
6/0x20
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff81048274>] ? queue_work+0x47/0=
x52
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff81342978>] ? sch_direct_xmit+0=
x67/0x18d
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff810b42fd>] ? send_sigio+0x91/0=
xa7
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff813313b5>] ? dev_queue_xmit+0x=
2fe/0x4fc
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff8107a785>] ? free_one_page+0x2=
4e/0x264
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff8134f3b4>] ? ip_finish_output+=
0x216/0x267
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff8134ea04>] ? ip_queue_xmit+0x2=
c8/0x304
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff81051ff1>] ? getnstimeofday+0x=
54/0xa5
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff8136014b>] ? tcp_transmit_skb+=
0x6b4/0x6f4
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff81360f7b>] ? tcp_retransmit_sk=
b+0x41c/0x505
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff81285f46>] ? iwl_rx_reply_rx+0=
x467/0x47e
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff81362ca0>] ? tcp_retransmit_ti=
mer+0x4f8/0x4f8
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff81362b02>] ? tcp_retransmit_ti=
mer+0x35a/0x4f8
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff81362d3b>] ? tcp_write_timer+0=
x9b/0x18d
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff8103fe83>] ? run_timer_softirq=
+0x19b/0x230
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff8103ae64>] ? __do_softirq+0x7f=
/0x106
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff813d22ac>] ? call_softirq+0x1c=
/0x26
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff810033fe>] ? do_softirq+0x31/0=
x67
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff8103b118>] ? irq_exit+0x44/0xb0
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff81014a09>] ? smp_apic_timer_in=
terrupt+0x85/0x95
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff813d184b>] ? apic_timer_interr=
upt+0x6b/0x70
W> > Nov 20 20:47:43 x220 kernel:  <EOI>  [<ffffffff8118a94a>] ? intel_idle=
+0xcd/0xe9
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff8118a926>] ? intel_idle+0xa9/0=
xe9
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff812dca4d>] ? cpuidle_idle_call=
+0xa0/0xdb
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff81000699>] ? cpu_idle+0x53/0x7c
W> > Nov 20 20:47:43 x220 kernel:  [<ffffffff816879fa>] ? start_kernel+0x2b=
e/0x2c9
W> > Nov 20 20:47:43 x220 kernel: ---[ end trace c69a09b105aa81af ]---
W> >=20
W> > ... and it goes on and on

--Sig_/cKCrnKDW1GjStIV/uPmn/+f
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iEYEARECAAYFAk7KnPgACgkQnhRzXSM7nSmuTQCfRR6xrdHVh0Ptc/LwwaA0ZIxa
6wIAn3Xo+dZ3D4WNiL/0t4M1sgybvMOr
=SEtd
-----END PGP SIGNATURE-----

--Sig_/cKCrnKDW1GjStIV/uPmn/+f--
