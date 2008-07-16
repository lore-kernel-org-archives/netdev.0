From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next] atl1e: Atheros L1E Gigabit Ethernet driver
Date: Wed, 16 Jul 2008 08:53:29 -0700
Message-ID: <20080716085329.03e97b2a@extreme>
References: <72981EBCFD196144B7C6999B9FC34A9A3EE60E9F58@SHEXMB-01.global.atheros.com>
	<20080715211514.25848d8a@extreme>
	<72981EBCFD196144B7C6999B9FC34A9A3EE60EA59C@SHEXMB-01.global.atheros.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "jeff@garzik.org" <jeff@garzik.org>,
	David Miller <davem@davemloft.net>,
	"jcliburn@gmail.com" <jcliburn@gmail.com>,
	"parag.warudkar@gmail.com" <parag.warudkar@gmail.com>,
	Willy Tarreau <w@1wt.eu>,
	"oliver.schuster@schweigstill.de" <oliver.schuster@schweigstill.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Jie Yang <Jie.Yang@Atheros.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758837AbYGPPyW@vger.kernel.org>
In-Reply-To: <72981EBCFD196144B7C6999B9FC34A9A3EE60EA59C@SHEXMB-01.global.atheros.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 16 Jul 2008 17:42:52 +0800
Jie Yang <Jie.Yang@Atheros.com> wrote:

> From: Jie Yang <jie.yang@atheros.com>
> 
> Full patch for the Atheros L1E Gigabit Ethernet driver.
> Supportring AR8121, AR8113 and AR8114
> 
> Signed-off-by: Jie Yang <jie.yang @atheros.com>

Output of checkpatch (scripts/checkpatch.pl in kernel source).
Personally, I am not a whitespace bigot, and don't think
all the warnings in checkpatch have to be fixed.

----------
ERROR: patch seems to be corrupt (line wrapped?)
#121: FILE: drivers/net/atl1e/atl1e.h:9:
ree

WARNING: space prohibited between function name and open parenthesis '('
#212: FILE: drivers/net/atl1e/atl1e.h:97:
+       _tpd =3D (((_vlan) << (4)) | (((_vlan) >> 13) & 7) |\

ERROR: spaces required around that '=' (ctx:WxV)
#212: FILE: drivers/net/atl1e/atl1e.h:97:
+       _tpd =3D (((_vlan) << (4)) | (((_vlan) >> 13) & 7) |\
             ^

ERROR: code indent should use tabs where possible
#213: FILE: drivers/net/atl1e/atl1e.h:98:
+                (((_vlan) >> 9) & 8))$

WARNING: space prohibited between function name and open parenthesis '('
#216: FILE: drivers/net/atl1e/atl1e.h:101:
+       _vlan =3D (((_tpd) >> 8) | (((_tpd) & 0x77) << 9) |\

ERROR: spaces required around that '=' (ctx:WxV)
#216: FILE: drivers/net/atl1e/atl1e.h:101:
+       _vlan =3D (((_tpd) >> 8) | (((_tpd) & 0x77) << 9) |\
              ^

ERROR: code indent should use tabs where possible
#217: FILE: drivers/net/atl1e/atl1e.h:102:
+                  (((_tdp) & 0x88) << 5))$

ERROR: code indent should use tabs where possible
#234: FILE: drivers/net/atl1e/atl1e.h:119:
+                        ADVERTISE_10_FULL  |\$

ERROR: code indent should use tabs where possible
#235: FILE: drivers/net/atl1e/atl1e.h:120:
+                        ADVERTISE_100_HALF |\$

ERROR: code indent should use tabs where possible
#236: FILE: drivers/net/atl1e/atl1e.h:121:
+                        ADVERTISE_100_FULL |\$

ERROR: code indent should use tabs where possible
#237: FILE: drivers/net/atl1e/atl1e.h:122:
+                        ADVERTISE_1000_FULL)$

ERROR: spaces required around that '=' (ctx:WxV)
#359: FILE: drivers/net/atl1e/atl1e.h:244:
+       atl1e_dma_req_128 =3D 0,
                          ^

ERROR: spaces required around that '=' (ctx:WxV)
#360: FILE: drivers/net/atl1e/atl1e.h:245:
+       atl1e_dma_req_256 =3D 1,
                          ^

ERROR: spaces required around that '=' (ctx:WxV)
#361: FILE: drivers/net/atl1e/atl1e.h:246:
+       atl1e_dma_req_512 =3D 2,
                          ^

ERROR: spaces required around that '=' (ctx:WxV)
#362: FILE: drivers/net/atl1e/atl1e.h:247:
+       atl1e_dma_req_1024 =3D 3,
                           ^

ERROR: spaces required around that '=' (ctx:WxV)
#363: FILE: drivers/net/atl1e/atl1e.h:248:
+       atl1e_dma_req_2048 =3D 4,
                           ^

ERROR: spaces required around that '=' (ctx:WxV)
#364: FILE: drivers/net/atl1e/atl1e.h:249:
+       atl1e_dma_req_4096 =3D 5
                           ^

ERROR: spaces required around that '=' (ctx:WxV)
#368: FILE: drivers/net/atl1e/atl1e.h:253:
+       atl1e_rrs_disable =3D 0,
                          ^

ERROR: spaces required around that '=' (ctx:WxV)
#369: FILE: drivers/net/atl1e/atl1e.h:254:
+       atl1e_rrs_ipv4 =3D 1,
                       ^

ERROR: spaces required around that '=' (ctx:WxV)
#370: FILE: drivers/net/atl1e/atl1e.h:255:
+       atl1e_rrs_ipv4_tcp =3D 2,
                           ^

ERROR: spaces required around that '=' (ctx:WxV)
#371: FILE: drivers/net/atl1e/atl1e.h:256:
+       atl1e_rrs_ipv6 =3D 4,
                       ^

ERROR: spaces required around that '=' (ctx:WxV)
#372: FILE: drivers/net/atl1e/atl1e.h:257:
+       atl1e_rrs_ipv6_tcp =3D 8
                           ^

ERROR: spaces required around that '=' (ctx:WxV)
#376: FILE: drivers/net/atl1e/atl1e.h:261:
+       athr_l1e =3D 0,
                 ^

ERROR: spaces required around that '=' (ctx:WxV)
#377: FILE: drivers/net/atl1e/atl1e.h:262:
+       athr_l2e_revA =3D 1,
                      ^

ERROR: spaces required around that '=' (ctx:WxV)
#378: FILE: drivers/net/atl1e/atl1e.h:263:
+       athr_l2e_revB =3D 2
                      ^

ERROR: code indent should use tabs where possible
#523: FILE: drivers/net/atl1e/atl1e.h:382:
+                         interrupt request */$

ERROR: code indent should use tabs where possible
#559: FILE: drivers/net/atl1e/atl1e.h:417:
+                                             receive data offset in the pa=$

ERROR: code indent should use tabs where possible
#563: FILE: drivers/net/atl1e/atl1e.h:419:
+                                            the receive data offset in the=$

ERROR: code indent should use tabs where possible
#645: FILE: drivers/net/atl1e/atl1e.h:499:
+               writel((value), ((a)->hw_addr + reg)))$

ERROR: code indent should use tabs where possible
#648: FILE: drivers/net/atl1e/atl1e.h:502:
+               readl((a)->hw_addr))$

ERROR: code indent should use tabs where possible
#651: FILE: drivers/net/atl1e/atl1e.h:505:
+               readl((a)->hw_addr + reg))$

ERROR: code indent should use tabs where possible
#655: FILE: drivers/net/atl1e/atl1e.h:509:
+               writeb((value), ((a)->hw_addr + reg)))$

ERROR: code indent should use tabs where possible
#658: 
+               readb((a)->hw_addr + reg))$

ERROR: code indent should use tabs where possible
#661: 
+               writew((value), ((a)->hw_addr + reg)))$

ERROR: code indent should use tabs where possible
#664: 
+               readw((a)->hw_addr + reg))$

ERROR: code indent should use tabs where possible
#667: 
+               writel((value), (((a)->hw_addr + reg) + ((offset) << 2))))$

ERROR: code indent should use tabs where possible
#670: 
+               readl(((a)->hw_addr + reg) + ((offset) << 2)))$

ERROR: need consistent spacing around '/' (ctx:WxO)
#681: 
+#endif /* _ATL1_E_H_ */
        ^

ERROR: space required before that '*' (ctx:OxW)
#681: 
+#endif /* _ATL1_E_H_ */
         ^

ERROR: space prohibited after that '*' (ctx:OxW)
#681: 
+#endif /* _ATL1_E_H_ */
         ^

ERROR: need consistent spacing around '*' (ctx:WxO)
#681: 
+#endif /* _ATL1_E_H_ */
                      ^

ERROR: code indent should use tabs where possible
#723: FILE: drivers/net/atl1e/atl1e_ethtool.c:30:
+                             struct ethtool_cmd *ecmd)$

ERROR: spaces required around that '=' (ctx:WxV)
#725: FILE: drivers/net/atl1e/atl1e_ethtool.c:32:
+       struct atl1e_adapter *adapter =3D netdev_priv(netdev);
                                      ^

ERROR: spaces required around that '=' (ctx:WxV)
#726: FILE: drivers/net/atl1e/atl1e_ethtool.c:33:
+       struct atl1e_hw *hw =3D &adapter->hw;
                            ^

ERROR: need consistent spacing around '&' (ctx:WxV)
#726: FILE: drivers/net/atl1e/atl1e_ethtool.c:33:
+       struct atl1e_hw *hw =3D &adapter->hw;
                                ^

WARNING: space prohibited between function name and open parenthesis '('
#728: FILE: drivers/net/atl1e/atl1e_ethtool.c:35:
+       ecmd->supported =3D (SUPPORTED_10baseT_Half  |

ERROR: spaces required around that '=' (ctx:WxV)
#728: FILE: drivers/net/atl1e/atl1e_ethtool.c:35:
+       ecmd->supported =3D (SUPPORTED_10baseT_Half  |
                        ^

ERROR: code indent should use tabs where possible
#729: FILE: drivers/net/atl1e/atl1e_ethtool.c:36:
+                          SUPPORTED_10baseT_Full  |$

ERROR: code indent should use tabs where possible
#730: FILE: drivers/net/atl1e/atl1e_ethtool.c:37:
+                          SUPPORTED_100baseT_Half |$

ERROR: code indent should use tabs where possible
#731: FILE: drivers/net/atl1e/atl1e_ethtool.c:38:
+                          SUPPORTED_100baseT_Full |$

ERROR: code indent should use tabs where possible
#732: FILE: drivers/net/atl1e/atl1e_ethtool.c:39:
+                          SUPPORTED_Autoneg       |$

ERROR: code indent should use tabs where possible
#733: FILE: drivers/net/atl1e/atl1e_ethtool.c:40:
+                          SUPPORTED_TP);$

ERROR: spaces required around that '=' (ctx:WxV)
#734: FILE: drivers/net/atl1e/atl1e_ethtool.c:41:
+       if (hw->nic_type =3D=3D athr_l1e)
                         ^

ERROR: spaces required around that '=' (ctx:VxV)
#734: FILE: drivers/net/atl1e/atl1e_ethtool.c:41:
+       if (hw->nic_type =3D=3D athr_l1e)
                            ^

ERROR: do not use assignment in if condition
#734: FILE: drivers/net/atl1e/atl1e_ethtool.c:41:
+       if (hw->nic_type =3D=3D athr_l1e)

ERROR: code indent should use tabs where possible
#735: FILE: drivers/net/atl1e/atl1e_ethtool.c:42:
+               ecmd->supported |=3D SUPPORTED_1000baseT_Full;$

ERROR: spaces required around that '|=' (ctx:WxV)
#735: FILE: drivers/net/atl1e/atl1e_ethtool.c:42:
+               ecmd->supported |=3D SUPPORTED_1000baseT_Full;
                                ^

ERROR: spaces required around that '=' (ctx:WxV)
#737: FILE: drivers/net/atl1e/atl1e_ethtool.c:44:
+       ecmd->advertising =3D ADVERTISED_TP;
                          ^

ERROR: spaces required around that '|=' (ctx:WxV)
#739: FILE: drivers/net/atl1e/atl1e_ethtool.c:46:
+       ecmd->advertising |=3D ADVERTISED_Autoneg;
                          ^

ERROR: spaces required around that '|=' (ctx:WxV)
#740: FILE: drivers/net/atl1e/atl1e_ethtool.c:47:
+       ecmd->advertising |=3D hw->autoneg_advertised;
                          ^

ERROR: spaces required around that '=' (ctx:WxV)
#742: FILE: drivers/net/atl1e/atl1e_ethtool.c:49:
+       ecmd->port =3D PORT_TP;
                   ^

ERROR: spaces required around that '=' (ctx:WxV)
#743: FILE: drivers/net/atl1e/atl1e_ethtool.c:50:
+       ecmd->phy_address =3D 0;
                          ^

ERROR: spaces required around that '=' (ctx:WxV)
#744: FILE: drivers/net/atl1e/atl1e_ethtool.c:51:
+       ecmd->transceiver =3D XCVR_INTERNAL;
                          ^

ERROR: spaces required around that '!=' (ctx:WxV)
#746: FILE: drivers/net/atl1e/atl1e_ethtool.c:53:
+       if (adapter->link_speed !=3D SPEED_0) {
                                ^

ERROR: code indent should use tabs where possible
#747: FILE: drivers/net/atl1e/atl1e_ethtool.c:54:
+               ecmd->speed =3D adapter->link_speed;$

ERROR: spaces required around that '=' (ctx:WxV)
#747: FILE: drivers/net/atl1e/atl1e_ethtool.c:54:
+               ecmd->speed =3D adapter->link_speed;
                            ^

ERROR: code indent should use tabs where possible
#748: FILE: drivers/net/atl1e/atl1e_ethtool.c:55:
+               if (adapter->link_duplex =3D=3D FULL_DUPLEX)$

ERROR: spaces required around that '=' (ctx:WxV)
#748: FILE: drivers/net/atl1e/atl1e_ethtool.c:55:
+               if (adapter->link_duplex =3D=3D FULL_DUPLEX)
                                         ^

ERROR: spaces required around that '=' (ctx:VxV)
#748: FILE: drivers/net/atl1e/atl1e_ethtool.c:55:
+               if (adapter->link_duplex =3D=3D FULL_DUPLEX)
                                            ^

ERROR: do not use assignment in if condition
#748: FILE: drivers/net/atl1e/atl1e_ethtool.c:55:
+               if (adapter->link_duplex =3D=3D FULL_DUPLEX)

ERROR: code indent should use tabs where possible
#749: FILE: drivers/net/atl1e/atl1e_ethtool.c:56:
+                       ecmd->duplex =3D DUPLEX_FULL;$

ERROR: spaces required around that '=' (ctx:WxV)
#749: FILE: drivers/net/atl1e/atl1e_ethtool.c:56:
+                       ecmd->duplex =3D DUPLEX_FULL;
                                     ^

ERROR: code indent should use tabs where possible
#750: FILE: drivers/net/atl1e/atl1e_ethtool.c:57:
+               else$

ERROR: code indent should use tabs where possible
#751: FILE: drivers/net/atl1e/atl1e_ethtool.c:58:
+                       ecmd->duplex =3D DUPLEX_HALF;$

ERROR: spaces required around that '=' (ctx:WxV)
#751: FILE: drivers/net/atl1e/atl1e_ethtool.c:58:
+                       ecmd->duplex =3D DUPLEX_HALF;
                                     ^

ERROR: code indent should use tabs where possible
#753: FILE: drivers/net/atl1e/atl1e_ethtool.c:60:
+               ecmd->speed =3D -1;$

ERROR: spaces required around that '=' (ctx:WxV)
#753: FILE: drivers/net/atl1e/atl1e_ethtool.c:60:
+               ecmd->speed =3D -1;
                            ^

ERROR: need consistent spacing around '-' (ctx:WxV)
#753: FILE: drivers/net/atl1e/atl1e_ethtool.c:60:
+               ecmd->speed =3D -1;
                                ^

ERROR: code indent should use tabs where possible
#754: FILE: drivers/net/atl1e/atl1e_ethtool.c:61:
+               ecmd->duplex =3D -1;$

ERROR: spaces required around that '=' (ctx:WxV)
#754: FILE: drivers/net/atl1e/atl1e_ethtool.c:61:
+               ecmd->duplex =3D -1;
                             ^

ERROR: need consistent spacing around '-' (ctx:WxV)
#754: FILE: drivers/net/atl1e/atl1e_ethtool.c:61:
+               ecmd->duplex =3D -1;
                                 ^

ERROR: spaces required around that '=' (ctx:WxV)
#757: FILE: drivers/net/atl1e/atl1e_ethtool.c:64:
+       ecmd->autoneg =3D AUTONEG_ENABLE;
                      ^

ERROR: code indent should use tabs where possible
#762: FILE: drivers/net/atl1e/atl1e_ethtool.c:69:
+                             struct ethtool_cmd *ecmd)$

ERROR: spaces required around that '=' (ctx:WxV)
#764: FILE: drivers/net/atl1e/atl1e_ethtool.c:71:
+       struct atl1e_adapter *adapter =3D netdev_priv(netdev);
                                      ^

ERROR: spaces required around that '=' (ctx:WxV)
#765: FILE: drivers/net/atl1e/atl1e_ethtool.c:72:
+       struct atl1e_hw *hw =3D &adapter->hw;
                            ^

ERROR: need consistent spacing around '&' (ctx:WxV)
#765: FILE: drivers/net/atl1e/atl1e_ethtool.c:72:
+       struct atl1e_hw *hw =3D &adapter->hw;
                                ^

ERROR: code indent should use tabs where possible
#768: FILE: drivers/net/atl1e/atl1e_ethtool.c:75:
+               msleep(1);$

ERROR: spaces required around that '=' (ctx:WxV)
#770: FILE: drivers/net/atl1e/atl1e_ethtool.c:77:
+       if (ecmd->autoneg =3D=3D AUTONEG_ENABLE) {
                          ^

ERROR: spaces required around that '=' (ctx:VxV)
#770: FILE: drivers/net/atl1e/atl1e_ethtool.c:77:
+       if (ecmd->autoneg =3D=3D AUTONEG_ENABLE) {
                             ^

ERROR: do not use assignment in if condition
#770: FILE: drivers/net/atl1e/atl1e_ethtool.c:77:
+       if (ecmd->autoneg =3D=3D AUTONEG_ENABLE) {

ERROR: code indent should use tabs where possible
#771: FILE: drivers/net/atl1e/atl1e_ethtool.c:78:
+               u16 adv4, adv9;$

ERROR: code indent should use tabs where possible
#773: FILE: drivers/net/atl1e/atl1e_ethtool.c:80:
+               if ((ecmd->advertising&ADVERTISE_1000_FULL)) {$

ERROR: code indent should use tabs where possible
#774: FILE: drivers/net/atl1e/atl1e_ethtool.c:81:
+                       if (hw->nic_type =3D=3D athr_l1e) {$

ERROR: spaces required around that '=' (ctx:WxV)
#774: FILE: drivers/net/atl1e/atl1e_ethtool.c:81:
+                       if (hw->nic_type =3D=3D athr_l1e) {
                                         ^

ERROR: spaces required around that '=' (ctx:VxV)
#774: FILE: drivers/net/atl1e/atl1e_ethtool.c:81:
+                       if (hw->nic_type =3D=3D athr_l1e) {
                                            ^

ERROR: do not use assignment in if condition
#774: FILE: drivers/net/atl1e/atl1e_ethtool.c:81:
+                       if (hw->nic_type =3D=3D athr_l1e) {

ERROR: code indent should use tabs where possible
#775: FILE: drivers/net/atl1e/atl1e_ethtool.c:82:
+                               hw->autoneg_advertised =3D$

ERROR: spaces required around that '=' (ctx:WxV)
#775: FILE: drivers/net/atl1e/atl1e_ethtool.c:82:
+                               hw->autoneg_advertised =3D
                                                       ^

ERROR: code indent should use tabs where possible
#776: FILE: drivers/net/atl1e/atl1e_ethtool.c:83:
+                                       ecmd->advertising & AT_ADV_MASK;$

ERROR: code indent should use tabs where possible
#777: FILE: drivers/net/atl1e/atl1e_ethtool.c:84:
+                       } else {$

ERROR: code indent should use tabs where possible
#778: FILE: drivers/net/atl1e/atl1e_ethtool.c:85:
+                               clear_bit(__AT_RESETTING, &adapter->flags);$

ERROR: code indent should use tabs where possible
#779: FILE: drivers/net/atl1e/atl1e_ethtool.c:86:
+                               return -EINVAL;$

ERROR: code indent should use tabs where possible
#780: FILE: drivers/net/atl1e/atl1e_ethtool.c:87:
+                       }$

ERROR: code indent should use tabs where possible
#781: FILE: drivers/net/atl1e/atl1e_ethtool.c:88:
+               } else if (ecmd->advertising&ADVERTISE_1000_HALF) {$

ERROR: code indent should use tabs where possible
#782: FILE: drivers/net/atl1e/atl1e_ethtool.c:89:
+                       clear_bit(__AT_RESETTING, &adapter->flags);$

ERROR: code indent should use tabs where possible
#783: FILE: drivers/net/atl1e/atl1e_ethtool.c:90:
+                       return -EINVAL;$

ERROR: code indent should use tabs where possible
#784: FILE: drivers/net/atl1e/atl1e_ethtool.c:91:
+               } else {$

ERROR: code indent should use tabs where possible
#785: FILE: drivers/net/atl1e/atl1e_ethtool.c:92:
+                       hw->autoneg_advertised =3D$

ERROR: spaces required around that '=' (ctx:WxV)
#785: FILE: drivers/net/atl1e/atl1e_ethtool.c:92:
+                       hw->autoneg_advertised =3D
                                               ^

ERROR: code indent should use tabs where possible
#786: FILE: drivers/net/atl1e/atl1e_ethtool.c:93:
+                               ecmd->advertising & AT_ADV_MASK;$

ERROR: code indent should use tabs where possible
#787: FILE: drivers/net/atl1e/atl1e_ethtool.c:94:
+               }$

ERROR: code indent should use tabs where possible
#788: FILE: drivers/net/atl1e/atl1e_ethtool.c:95:
+               ecmd->advertising =3D hw->autoneg_advertised |$

ERROR: spaces required around that '=' (ctx:WxV)
#788: FILE: drivers/net/atl1e/atl1e_ethtool.c:95:
+               ecmd->advertising =3D hw->autoneg_advertised |
                                  ^

ERROR: code indent should use tabs where possible
#789: FILE: drivers/net/atl1e/atl1e_ethtool.c:96:
+                                   ADVERTISED_TP | ADVERTISED_Autoneg;$

ERROR: code indent should use tabs where possible
#791: FILE: drivers/net/atl1e/atl1e_ethtool.c:98:
+               adv4 =3D hw->mii_autoneg_adv_reg & ~MII_AR_SPEED_MASK;$

ERROR: spaces required around that '=' (ctx:WxV)
#791: FILE: drivers/net/atl1e/atl1e_ethtool.c:98:
+               adv4 =3D hw->mii_autoneg_adv_reg & ~MII_AR_SPEED_MASK;
                     ^

ERROR: code indent should use tabs where possible
#792: FILE: drivers/net/atl1e/atl1e_ethtool.c:99:
+               adv9 =3D hw->mii_1000t_ctrl_reg & ~MII_AT001_CR_1000T_SPEED=$

ERROR: spaces required around that '=' (ctx:WxV)
#792: FILE: drivers/net/atl1e/atl1e_ethtool.c:99:
+               adv9 =3D hw->mii_1000t_ctrl_reg & ~MII_AT001_CR_1000T_SPEED=
                     ^

ERROR: spaces required around that '=' (ctx:VxE)
#792: FILE: drivers/net/atl1e/atl1e_ethtool.c:99:
+               adv9 =3D hw->mii_1000t_ctrl_reg & ~MII_AT001_CR_1000T_SPEED=
                                                                           ^

ERROR: code indent should use tabs where possible
#794: FILE: drivers/net/atl1e/atl1e_ethtool.c:100:
+               if (hw->autoneg_advertised & ADVERTISE_10_HALF)$

ERROR: code indent should use tabs where possible
#795: FILE: drivers/net/atl1e/atl1e_ethtool.c:101:
+                       adv4 |=3D MII_AR_10T_HD_CAPS;$

ERROR: spaces required around that '|=' (ctx:WxV)
#795: FILE: drivers/net/atl1e/atl1e_ethtool.c:101:
+                       adv4 |=3D MII_AR_10T_HD_CAPS;
                             ^

ERROR: code indent should use tabs where possible
#796: FILE: drivers/net/atl1e/atl1e_ethtool.c:102:
+               if (hw->autoneg_advertised & ADVERTISE_10_FULL)$

ERROR: code indent should use tabs where possible
#797: FILE: drivers/net/atl1e/atl1e_ethtool.c:103:
+                       adv4 |=3D MII_AR_10T_FD_CAPS;$

ERROR: spaces required around that '|=' (ctx:WxV)
#797: FILE: drivers/net/atl1e/atl1e_ethtool.c:103:
+                       adv4 |=3D MII_AR_10T_FD_CAPS;
                             ^

ERROR: code indent should use tabs where possible
#798: FILE: drivers/net/atl1e/atl1e_ethtool.c:104:
+               if (hw->autoneg_advertised & ADVERTISE_100_HALF)$

ERROR: code indent should use tabs where possible
#799: FILE: drivers/net/atl1e/atl1e_ethtool.c:105:
+                       adv4 |=3D MII_AR_100TX_HD_CAPS;$

ERROR: spaces required around that '|=' (ctx:WxV)
#799: FILE: drivers/net/atl1e/atl1e_ethtool.c:105:
+                       adv4 |=3D MII_AR_100TX_HD_CAPS;
                             ^

ERROR: code indent should use tabs where possible
#800: FILE: drivers/net/atl1e/atl1e_ethtool.c:106:
+               if (hw->autoneg_advertised & ADVERTISE_100_FULL)$

ERROR: code indent should use tabs where possible
#801: FILE: drivers/net/atl1e/atl1e_ethtool.c:107:
+                       adv4 |=3D MII_AR_100TX_FD_CAPS;$

ERROR: spaces required around that '|=' (ctx:WxV)
#801: FILE: drivers/net/atl1e/atl1e_ethtool.c:107:
+                       adv4 |=3D MII_AR_100TX_FD_CAPS;
                             ^

ERROR: code indent should use tabs where possible
#802: FILE: drivers/net/atl1e/atl1e_ethtool.c:108:
+               if (hw->autoneg_advertised & ADVERTISE_1000_FULL)$

ERROR: code indent should use tabs where possible
#803: FILE: drivers/net/atl1e/atl1e_ethtool.c:109:
+                       adv9 |=3D MII_AT001_CR_1000T_FD_CAPS;$

ERROR: spaces required around that '|=' (ctx:WxV)
#803: FILE: drivers/net/atl1e/atl1e_ethtool.c:109:
+                       adv9 |=3D MII_AT001_CR_1000T_FD_CAPS;
                             ^

ERROR: code indent should use tabs where possible
#805: FILE: drivers/net/atl1e/atl1e_ethtool.c:111:
+               if (adv4 !=3D hw->mii_autoneg_adv_reg ||$

ERROR: spaces required around that '!=' (ctx:WxV)
#805: FILE: drivers/net/atl1e/atl1e_ethtool.c:111:
+               if (adv4 !=3D hw->mii_autoneg_adv_reg ||
                         ^

ERROR: code indent should use tabs where possible
#806: FILE: drivers/net/atl1e/atl1e_ethtool.c:112:
+                               adv9 !=3D hw->mii_1000t_ctrl_reg) {$

ERROR: spaces required around that '!=' (ctx:WxV)
#806: FILE: drivers/net/atl1e/atl1e_ethtool.c:112:
+                               adv9 !=3D hw->mii_1000t_ctrl_reg) {
                                     ^

ERROR: code indent should use tabs where possible
#807: FILE: drivers/net/atl1e/atl1e_ethtool.c:113:
+                       hw->mii_autoneg_adv_reg =3D adv4;$

ERROR: spaces required around that '=' (ctx:WxV)
#807: FILE: drivers/net/atl1e/atl1e_ethtool.c:113:
+                       hw->mii_autoneg_adv_reg =3D adv4;
                                                ^

ERROR: code indent should use tabs where possible
#808: FILE: drivers/net/atl1e/atl1e_ethtool.c:114:
+                       hw->mii_1000t_ctrl_reg =3D adv9;$

ERROR: spaces required around that '=' (ctx:WxV)
#808: FILE: drivers/net/atl1e/atl1e_ethtool.c:114:
+                       hw->mii_1000t_ctrl_reg =3D adv9;
                                               ^

ERROR: code indent should use tabs where possible
#809: FILE: drivers/net/atl1e/atl1e_ethtool.c:115:
+                       hw->re_autoneg =3D true;$

ERROR: spaces required around that '=' (ctx:WxV)
#809: FILE: drivers/net/atl1e/atl1e_ethtool.c:115:
+                       hw->re_autoneg =3D true;
                                       ^

ERROR: code indent should use tabs where possible
#810: FILE: drivers/net/atl1e/atl1e_ethtool.c:116:
+               }$

ERROR: code indent should use tabs where possible
#813: FILE: drivers/net/atl1e/atl1e_ethtool.c:119:
+               clear_bit(__AT_RESETTING, &adapter->flags);$

ERROR: code indent should use tabs where possible
#814: FILE: drivers/net/atl1e/atl1e_ethtool.c:120:
+               return -EINVAL;$

ERROR: code indent should use tabs where possible
#820: FILE: drivers/net/atl1e/atl1e_ethtool.c:126:
+               atl1e_down(adapter);$

ERROR: code indent should use tabs where possible
#821: FILE: drivers/net/atl1e/atl1e_ethtool.c:127:
+               atl1e_up(adapter);$

ERROR: code indent should use tabs where possible
#823: FILE: drivers/net/atl1e/atl1e_ethtool.c:129:
+               atl1e_reset_hw(&adapter->hw);$

ERROR: spaces required around that '!=' (ctx:WxV)
#831: FILE: drivers/net/atl1e/atl1e_ethtool.c:137:
+       return (netdev->features & NETIF_F_HW_CSUM) !=3D 0;
                                                    ^

ERROR: code indent should use tabs where possible
#853: FILE: drivers/net/atl1e/atl1e_ethtool.c:159:
+                          struct ethtool_regs *regs, void *p)$

ERROR: spaces required around that '=' (ctx:WxV)
#855: FILE: drivers/net/atl1e/atl1e_ethtool.c:161:
+       struct atl1e_adapter *adapter =3D netdev_priv(netdev);
                                      ^

ERROR: spaces required around that '=' (ctx:WxV)
#856: FILE: drivers/net/atl1e/atl1e_ethtool.c:162:
+       struct atl1e_hw *hw =3D &adapter->hw;
                            ^

ERROR: need consistent spacing around '&' (ctx:WxV)
#856: FILE: drivers/net/atl1e/atl1e_ethtool.c:162:
+       struct atl1e_hw *hw =3D &adapter->hw;
                                ^

ERROR: spaces required around that '=' (ctx:WxV)
#857: FILE: drivers/net/atl1e/atl1e_ethtool.c:163:
+       u32 *regs_buff =3D p;
                       ^

WARNING: space prohibited between function name and open parenthesis '('
#862: FILE: drivers/net/atl1e/atl1e_ethtool.c:168:
+       regs->version =3D (1 << 24) | (hw->revision_id << 16) | hw->device_=

ERROR: spaces required around that '=' (ctx:WxV)
#862: FILE: drivers/net/atl1e/atl1e_ethtool.c:168:
+       regs->version =3D (1 << 24) | (hw->revision_id << 16) | hw->device_=
                      ^

ERROR: spaces required around that '=' (ctx:VxE)
#862: FILE: drivers/net/atl1e/atl1e_ethtool.c:168:
+       regs->version =3D (1 << 24) | (hw->revision_id << 16) | hw->device_=
                                                                           ^

ERROR: spaces required around that '=' (ctx:WxV)
#865: FILE: drivers/net/atl1e/atl1e_ethtool.c:170:
+       regs_buff[0]  =3D AT_READ_REG(hw, REG_VPD_CAP);
                      ^

ERROR: spaces required around that '=' (ctx:WxV)
#866: FILE: drivers/net/atl1e/atl1e_ethtool.c:171:
+       regs_buff[1]  =3D AT_READ_REG(hw, REG_SPI_FLASH_CTRL);
                      ^

ERROR: spaces required around that '=' (ctx:WxV)
#867: FILE: drivers/net/atl1e/atl1e_ethtool.c:172:
+       regs_buff[2]  =3D AT_READ_REG(hw, REG_SPI_FLASH_CONFIG);
                      ^

ERROR: spaces required around that '=' (ctx:WxV)
#868: FILE: drivers/net/atl1e/atl1e_ethtool.c:173:
+       regs_buff[3]  =3D AT_READ_REG(hw, REG_TWSI_CTRL);
                      ^

ERROR: spaces required around that '=' (ctx:WxV)
#869: FILE: drivers/net/atl1e/atl1e_ethtool.c:174:
+       regs_buff[4]  =3D AT_READ_REG(hw, REG_PCIE_DEV_MISC_CTRL);
                      ^

ERROR: spaces required around that '=' (ctx:WxV)
#870: FILE: drivers/net/atl1e/atl1e_ethtool.c:175:
+       regs_buff[5]  =3D AT_READ_REG(hw, REG_MASTER_CTRL);
                      ^

ERROR: spaces required around that '=' (ctx:WxV)
#871: FILE: drivers/net/atl1e/atl1e_ethtool.c:176:
+       regs_buff[6]  =3D AT_READ_REG(hw, REG_MANUAL_TIMER_INIT);
                      ^

ERROR: spaces required around that '=' (ctx:WxV)
#872: FILE: drivers/net/atl1e/atl1e_ethtool.c:177:
+       regs_buff[7]  =3D AT_READ_REG(hw, REG_IRQ_MODU_TIMER_INIT);
                      ^

ERROR: spaces required around that '=' (ctx:WxV)
#873: FILE: drivers/net/atl1e/atl1e_ethtool.c:178:
+       regs_buff[8]  =3D AT_READ_REG(hw, REG_GPHY_CTRL);
                      ^

ERROR: spaces required around that '=' (ctx:WxV)
#874: FILE: drivers/net/atl1e/atl1e_ethtool.c:179:
+       regs_buff[9]  =3D AT_READ_REG(hw, REG_CMBDISDMA_TIMER);
                      ^

ERROR: spaces required around that '=' (ctx:WxV)
#875: FILE: drivers/net/atl1e/atl1e_ethtool.c:180:
+       regs_buff[10] =3D AT_READ_REG(hw, REG_IDLE_STATUS);
                      ^

ERROR: spaces required around that '=' (ctx:WxV)
#876: FILE: drivers/net/atl1e/atl1e_ethtool.c:181:
+       regs_buff[11] =3D AT_READ_REG(hw, REG_MDIO_CTRL);
                      ^

ERROR: spaces required around that '=' (ctx:WxV)
#877: FILE: drivers/net/atl1e/atl1e_ethtool.c:182:
+       regs_buff[12] =3D AT_READ_REG(hw, REG_SERDES_LOCK);
                      ^

ERROR: spaces required around that '=' (ctx:WxV)
#878: FILE: drivers/net/atl1e/atl1e_ethtool.c:183:
+       regs_buff[13] =3D AT_READ_REG(hw, REG_MAC_CTRL);
                      ^

ERROR: spaces required around that '=' (ctx:WxV)
#879: FILE: drivers/net/atl1e/atl1e_ethtool.c:184:
+       regs_buff[14] =3D AT_READ_REG(hw, REG_MAC_IPG_IFG);
                      ^

ERROR: spaces required around that '=' (ctx:WxV)
#880: FILE: drivers/net/atl1e/atl1e_ethtool.c:185:
+       regs_buff[15] =3D AT_READ_REG(hw, REG_MAC_STA_ADDR);
                      ^

ERROR: spaces required around that '=' (ctx:WxV)
#881: FILE: drivers/net/atl1e/atl1e_ethtool.c:186:
+       regs_buff[16] =3D AT_READ_REG(hw, REG_MAC_STA_ADDR+4);
                      ^

ERROR: spaces required around that '=' (ctx:WxV)
#882: FILE: drivers/net/atl1e/atl1e_ethtool.c:187:
+       regs_buff[17] =3D AT_READ_REG(hw, REG_RX_HASH_TABLE);
                      ^

ERROR: spaces required around that '=' (ctx:WxV)
#883: FILE: drivers/net/atl1e/atl1e_ethtool.c:188:
+       regs_buff[18] =3D AT_READ_REG(hw, REG_RX_HASH_TABLE+4);
                      ^

ERROR: spaces required around that '=' (ctx:WxV)
#884: FILE: drivers/net/atl1e/atl1e_ethtool.c:189:
+       regs_buff[19] =3D AT_READ_REG(hw, REG_MAC_HALF_DUPLX_CTRL);
                      ^

ERROR: spaces required around that '=' (ctx:WxV)
#885: FILE: drivers/net/atl1e/atl1e_ethtool.c:190:
+       regs_buff[20] =3D AT_READ_REG(hw, REG_MTU);
                      ^

ERROR: spaces required around that '=' (ctx:WxV)
#886: FILE: drivers/net/atl1e/atl1e_ethtool.c:191:
+       regs_buff[21] =3D AT_READ_REG(hw, REG_WOL_CTRL);
                      ^

ERROR: spaces required around that '=' (ctx:WxV)
#887: FILE: drivers/net/atl1e/atl1e_ethtool.c:192:
+       regs_buff[22] =3D AT_READ_REG(hw, REG_SRAM_TRD_ADDR);
                      ^

ERROR: spaces required around that '=' (ctx:WxV)
#888: FILE: drivers/net/atl1e/atl1e_ethtool.c:193:
+       regs_buff[23] =3D AT_READ_REG(hw, REG_SRAM_TRD_LEN);
                      ^

ERROR: spaces required around that '=' (ctx:WxV)
#889: FILE: drivers/net/atl1e/atl1e_ethtool.c:194:
+       regs_buff[24] =3D AT_READ_REG(hw, REG_SRAM_RXF_ADDR);
                      ^

ERROR: spaces required around that '=' (ctx:WxV)
#890: FILE: drivers/net/atl1e/atl1e_ethtool.c:195:
+       regs_buff[25] =3D AT_READ_REG(hw, REG_SRAM_RXF_LEN);
                      ^

ERROR: spaces required around that '=' (ctx:WxV)
#891: FILE: drivers/net/atl1e/atl1e_ethtool.c:196:
+       regs_buff[26] =3D AT_READ_REG(hw, REG_SRAM_TXF_ADDR);
                      ^

ERROR: spaces required around that '=' (ctx:WxV)
#892: FILE: drivers/net/atl1e/atl1e_ethtool.c:197:
+       regs_buff[27] =3D AT_READ_REG(hw, REG_SRAM_TXF_LEN);
                      ^

ERROR: spaces required around that '=' (ctx:WxV)
#893: FILE: drivers/net/atl1e/atl1e_ethtool.c:198:
+       regs_buff[28] =3D AT_READ_REG(hw, REG_SRAM_TCPH_ADDR);
                      ^

ERROR: spaces required around that '=' (ctx:WxV)
#894: FILE: drivers/net/atl1e/atl1e_ethtool.c:199:
+       regs_buff[29] =3D AT_READ_REG(hw, REG_SRAM_PKTH_ADDR);
                      ^

WARNING: space prohibited between function name and open parenthesis '('
#897: FILE: drivers/net/atl1e/atl1e_ethtool.c:202:
+       regs_buff[73] =3D (u32)phy_data;

ERROR: spaces required around that '=' (ctx:WxV)
#897: FILE: drivers/net/atl1e/atl1e_ethtool.c:202:
+       regs_buff[73] =3D (u32)phy_data;
                      ^

WARNING: space prohibited between function name and open parenthesis '('
#899: FILE: drivers/net/atl1e/atl1e_ethtool.c:204:
+       regs_buff[74] =3D (u32)phy_data;

ERROR: spaces required around that '=' (ctx:WxV)
#899: FILE: drivers/net/atl1e/atl1e_ethtool.c:204:
+       regs_buff[74] =3D (u32)phy_data;
                      ^

ERROR: spaces required around that '=' (ctx:WxV)
#904: FILE: drivers/net/atl1e/atl1e_ethtool.c:209:
+       struct atl1e_adapter *adapter =3D netdev_priv(netdev);
                                      ^

ERROR: code indent should use tabs where possible
#907: FILE: drivers/net/atl1e/atl1e_ethtool.c:212:
+               return AT_EEPROM_LEN;$

ERROR: code indent should use tabs where possible
#909: FILE: drivers/net/atl1e/atl1e_ethtool.c:214:
+               return 0;$

ERROR: code indent should use tabs where possible
#913: FILE: drivers/net/atl1e/atl1e_ethtool.c:218:
+               struct ethtool_eeprom *eeprom, u8 *bytes)$

ERROR: spaces required around that '=' (ctx:WxV)
#915: FILE: drivers/net/atl1e/atl1e_ethtool.c:220:
+       struct atl1e_adapter *adapter =3D netdev_priv(netdev);
                                      ^

ERROR: spaces required around that '=' (ctx:WxV)
#916: FILE: drivers/net/atl1e/atl1e_ethtool.c:221:
+       struct atl1e_hw *hw =3D &adapter->hw;
                            ^

ERROR: need consistent spacing around '&' (ctx:WxV)
#916: FILE: drivers/net/atl1e/atl1e_ethtool.c:221:
+       struct atl1e_hw *hw =3D &adapter->hw;
                                ^

ERROR: spaces required around that '=' (ctx:WxV)
#919: FILE: drivers/net/atl1e/atl1e_ethtool.c:224:
+       int ret_val =3D 0;
                    ^

ERROR: spaces required around that '=' (ctx:WxV)
#922: FILE: drivers/net/atl1e/atl1e_ethtool.c:227:
+       if (eeprom->len =3D=3D 0)
                        ^

ERROR: spaces required around that '=' (ctx:VxV)
#922: FILE: drivers/net/atl1e/atl1e_ethtool.c:227:
+       if (eeprom->len =3D=3D 0)
                           ^

ERROR: do not use assignment in if condition
#922: FILE: drivers/net/atl1e/atl1e_ethtool.c:227:
+       if (eeprom->len =3D=3D 0)

ERROR: code indent should use tabs where possible
#923: FILE: drivers/net/atl1e/atl1e_ethtool.c:228:
+               return -EINVAL;$

ERROR: code indent should use tabs where possible
#926: FILE: drivers/net/atl1e/atl1e_ethtool.c:231:
+               return -EINVAL;$

ERROR: spaces required around that '=' (ctx:WxV)
#928: FILE: drivers/net/atl1e/atl1e_ethtool.c:233:
+       eeprom->magic =3D hw->vendor_id | (hw->device_id << 16);
                      ^

ERROR: spaces required around that '=' (ctx:WxV)
#930: FILE: drivers/net/atl1e/atl1e_ethtool.c:235:
+       first_dword =3D eeprom->offset >> 2;
                    ^

WARNING: space prohibited between function name and open parenthesis '('
#931: FILE: drivers/net/atl1e/atl1e_ethtool.c:236:
+       last_dword =3D (eeprom->offset + eeprom->len - 1) >> 2;

ERROR: spaces required around that '=' (ctx:WxV)
#931: FILE: drivers/net/atl1e/atl1e_ethtool.c:236:
+       last_dword =3D (eeprom->offset + eeprom->len - 1) >> 2;
                   ^

ERROR: spaces required around that '=' (ctx:WxV)
#933: FILE: drivers/net/atl1e/atl1e_ethtool.c:238:
+       eeprom_buff =3D kmalloc(sizeof(u32) *
                    ^

ERROR: code indent should use tabs where possible
#934: FILE: drivers/net/atl1e/atl1e_ethtool.c:239:
+                       (last_dword - first_dword + 1), GFP_KERNEL);$

ERROR: spaces required around that '=' (ctx:WxV)
#935: FILE: drivers/net/atl1e/atl1e_ethtool.c:240:
+       if (eeprom_buff =3D=3D NULL)
                        ^

ERROR: spaces required around that '=' (ctx:VxV)
#935: FILE: drivers/net/atl1e/atl1e_ethtool.c:240:
+       if (eeprom_buff =3D=3D NULL)
                           ^

ERROR: do not use assignment in if condition
#935: FILE: drivers/net/atl1e/atl1e_ethtool.c:240:
+       if (eeprom_buff =3D=3D NULL)

ERROR: code indent should use tabs where possible
#936: FILE: drivers/net/atl1e/atl1e_ethtool.c:241:
+               return -ENOMEM;$

ERROR: spaces required around that '=' (ctx:WxV)
#938: FILE: drivers/net/atl1e/atl1e_ethtool.c:243:
+       for (i =3D first_dword; i < last_dword; i++) {
               ^

ERROR: code indent should use tabs where possible
#939: FILE: drivers/net/atl1e/atl1e_ethtool.c:244:
+               if (!atl1e_read_eeprom(hw, i * 4, &(eeprom_buff[i-first_dwo=$

ERROR: spaces required around that '=' (ctx:VxE)
#939: FILE: drivers/net/atl1e/atl1e_ethtool.c:244:
+               if (!atl1e_read_eeprom(hw, i * 4, &(eeprom_buff[i-first_dwo=
                                                                           ^

ERROR: do not use assignment in if condition
#939: FILE: drivers/net/atl1e/atl1e_ethtool.c:244:
+               if (!atl1e_read_eeprom(hw, i * 4, &(eeprom_buff[i-first_dwo=

ERROR: code indent should use tabs where possible
#941: FILE: drivers/net/atl1e/atl1e_ethtool.c:245:
+                       kfree(eeprom_buff);$

ERROR: code indent should use tabs where possible
#942: FILE: drivers/net/atl1e/atl1e_ethtool.c:246:
+                       return -EIO;$

ERROR: code indent should use tabs where possible
#943: FILE: drivers/net/atl1e/atl1e_ethtool.c:247:
+               }$

ERROR: code indent should use tabs where possible
#947: FILE: drivers/net/atl1e/atl1e_ethtool.c:251:
+                       eeprom->len);$

ERROR: code indent should use tabs where possible
#954: FILE: drivers/net/atl1e/atl1e_ethtool.c:258:
+                           struct ethtool_eeprom *eeprom, u8 *bytes)$

ERROR: spaces required around that '=' (ctx:WxV)
#956: FILE: drivers/net/atl1e/atl1e_ethtool.c:260:
+       struct atl1e_adapter *adapter =3D netdev_priv(netdev);
                                      ^

ERROR: spaces required around that '=' (ctx:WxV)
#957: FILE: drivers/net/atl1e/atl1e_ethtool.c:261:
+       struct atl1e_hw *hw =3D &adapter->hw;
                            ^

ERROR: need consistent spacing around '&' (ctx:WxV)
#957: FILE: drivers/net/atl1e/atl1e_ethtool.c:261:
+       struct atl1e_hw *hw =3D &adapter->hw;
                                ^

ERROR: spaces required around that '=' (ctx:WxV)
#961: FILE: drivers/net/atl1e/atl1e_ethtool.c:265:
+       int ret_val =3D 0;
                    ^

ERROR: spaces required around that '=' (ctx:WxV)
#964: FILE: drivers/net/atl1e/atl1e_ethtool.c:268:
+       if (eeprom->len =3D=3D 0)
                        ^

ERROR: spaces required around that '=' (ctx:VxV)
#964: FILE: drivers/net/atl1e/atl1e_ethtool.c:268:
+       if (eeprom->len =3D=3D 0)
                           ^

ERROR: do not use assignment in if condition
#964: FILE: drivers/net/atl1e/atl1e_ethtool.c:268:
+       if (eeprom->len =3D=3D 0)

ERROR: code indent should use tabs where possible
#965: FILE: drivers/net/atl1e/atl1e_ethtool.c:269:
+               return -EOPNOTSUPP;$

WARNING: space prohibited between function name and open parenthesis '('
#967: FILE: drivers/net/atl1e/atl1e_ethtool.c:271:
+       if (eeprom->magic !=3D (hw->vendor_id | (hw->device_id << 16)))

ERROR: spaces required around that '!=' (ctx:WxV)
#967: FILE: drivers/net/atl1e/atl1e_ethtool.c:271:
+       if (eeprom->magic !=3D (hw->vendor_id | (hw->device_id << 16)))
                          ^

ERROR: code indent should use tabs where possible
#968: FILE: drivers/net/atl1e/atl1e_ethtool.c:272:
+               return -EINVAL;$

ERROR: spaces required around that '=' (ctx:WxV)
#970: FILE: drivers/net/atl1e/atl1e_ethtool.c:274:
+       first_dword =3D eeprom->offset >> 2;
                    ^

WARNING: space prohibited between function name and open parenthesis '('
#971: FILE: drivers/net/atl1e/atl1e_ethtool.c:275:
+       last_dword =3D (eeprom->offset + eeprom->len - 1) >> 2;

ERROR: spaces required around that '=' (ctx:WxV)
#971: FILE: drivers/net/atl1e/atl1e_ethtool.c:275:
+       last_dword =3D (eeprom->offset + eeprom->len - 1) >> 2;
                   ^

ERROR: spaces required around that '=' (ctx:WxV)
#972: FILE: drivers/net/atl1e/atl1e_ethtool.c:276:
+       eeprom_buff =3D kmalloc(AT_EEPROM_LEN, GFP_KERNEL);
                    ^

ERROR: spaces required around that '=' (ctx:WxV)
#973: FILE: drivers/net/atl1e/atl1e_ethtool.c:277:
+       if (eeprom_buff =3D=3D NULL)
                        ^

ERROR: spaces required around that '=' (ctx:VxV)
#973: FILE: drivers/net/atl1e/atl1e_ethtool.c:277:
+       if (eeprom_buff =3D=3D NULL)
                           ^

ERROR: do not use assignment in if condition
#973: FILE: drivers/net/atl1e/atl1e_ethtool.c:277:
+       if (eeprom_buff =3D=3D NULL)

ERROR: code indent should use tabs where possible
#974: FILE: drivers/net/atl1e/atl1e_ethtool.c:278:
+               return -ENOMEM;$

WARNING: space prohibited between function name and open parenthesis '('
#976: FILE: drivers/net/atl1e/atl1e_ethtool.c:280:
+       ptr =3D (u32 *)eeprom_buff;

ERROR: spaces required around that '=' (ctx:WxV)
#976: FILE: drivers/net/atl1e/atl1e_ethtool.c:280:
+       ptr =3D (u32 *)eeprom_buff;
            ^

ERROR: code indent should use tabs where possible
#979: FILE: drivers/net/atl1e/atl1e_ethtool.c:283:
+               /* need read/modify/write of first changed EEPROM word */$

ERROR: code indent should use tabs where possible
#980: FILE: drivers/net/atl1e/atl1e_ethtool.c:284:
+               /* only the second byte of the word is being modified */$

ERROR: code indent should use tabs where possible
#981: FILE: drivers/net/atl1e/atl1e_ethtool.c:285:
+               if (!atl1e_read_eeprom(hw, first_dword * 4, &(eeprom_buff[0=$

ERROR: "foo * bar" should be "foo *bar"
#981: FILE: drivers/net/atl1e/atl1e_ethtool.c:285:
+               if (!atl1e_read_eeprom(hw, first_dword * 4, &(eeprom_buff[0=

ERROR: spaces required around that '=' (ctx:VxE)
#981: FILE: drivers/net/atl1e/atl1e_ethtool.c:285:
+               if (!atl1e_read_eeprom(hw, first_dword * 4, &(eeprom_buff[0=
                                                                           ^

ERROR: do not use assignment in if condition
#981: FILE: drivers/net/atl1e/atl1e_ethtool.c:285:
+               if (!atl1e_read_eeprom(hw, first_dword * 4, &(eeprom_buff[0=

ERROR: code indent should use tabs where possible
#983: FILE: drivers/net/atl1e/atl1e_ethtool.c:286:
+                       ret_val =3D -EIO;$

ERROR: spaces required around that '=' (ctx:WxV)
#983: FILE: drivers/net/atl1e/atl1e_ethtool.c:286:
+                       ret_val =3D -EIO;
                                ^

ERROR: need consistent spacing around '-' (ctx:WxV)
#983: FILE: drivers/net/atl1e/atl1e_ethtool.c:286:
+                       ret_val =3D -EIO;
                                    ^

ERROR: code indent should use tabs where possible
#984: FILE: drivers/net/atl1e/atl1e_ethtool.c:287:
+                       goto out;$

ERROR: code indent should use tabs where possible
#985: FILE: drivers/net/atl1e/atl1e_ethtool.c:288:
+               }$

ERROR: code indent should use tabs where possible
#986: FILE: drivers/net/atl1e/atl1e_ethtool.c:289:
+               ptr++;$

ERROR: code indent should use tabs where possible
#989: FILE: drivers/net/atl1e/atl1e_ethtool.c:292:
+               /* need read/modify/write of last changed EEPROM word */$

ERROR: code indent should use tabs where possible
#990: FILE: drivers/net/atl1e/atl1e_ethtool.c:293:
+               /* only the first byte of the word is being modified */$

ERROR: code indent should use tabs where possible
#992: FILE: drivers/net/atl1e/atl1e_ethtool.c:295:
+               if (!atl1e_read_eeprom(hw, last_dword * 4,$

ERROR: "foo * bar" should be "foo *bar"
#992: FILE: drivers/net/atl1e/atl1e_ethtool.c:295:
+               if (!atl1e_read_eeprom(hw, last_dword * 4,

ERROR: trailing statements should be on next line
#992: FILE: drivers/net/atl1e/atl1e_ethtool.c:295:
+               if (!atl1e_read_eeprom(hw, last_dword * 4,

ERROR: code indent should use tabs where possible
#993: FILE: drivers/net/atl1e/atl1e_ethtool.c:296:
+                               &(eeprom_buff[last_dword - first_dword]))) =$

ERROR: code indent should use tabs where possible
#995: FILE: drivers/net/atl1e/atl1e_ethtool.c:297:
+                       ret_val =3D -EIO;$

ERROR: spaces required around that '=' (ctx:WxV)
#995: FILE: drivers/net/atl1e/atl1e_ethtool.c:297:
+                       ret_val =3D -EIO;
                                ^

ERROR: need consistent spacing around '-' (ctx:WxV)
#995: FILE: drivers/net/atl1e/atl1e_ethtool.c:297:
+                       ret_val =3D -EIO;
                                    ^

ERROR: code indent should use tabs where possible
#996: FILE: drivers/net/atl1e/atl1e_ethtool.c:298:
+                       goto out;$

ERROR: code indent should use tabs where possible
#997: FILE: drivers/net/atl1e/atl1e_ethtool.c:299:
+               }$

ERROR: spaces required around that '=' (ctx:WxV)
#1003: FILE: drivers/net/atl1e/atl1e_ethtool.c:305:
+       for (i =3D 0; i < last_dword - first_dword + 1; i++) {
               ^

ERROR: code indent should use tabs where possible
#1004: FILE: drivers/net/atl1e/atl1e_ethtool.c:306:
+               if (!atl1e_write_eeprom(hw, ((first_dword + i) * 4),$

ERROR: code indent should use tabs where possible
#1005: FILE: drivers/net/atl1e/atl1e_ethtool.c:307:
+                                 eeprom_buff[i])) {$

ERROR: code indent should use tabs where possible
#1006: FILE: drivers/net/atl1e/atl1e_ethtool.c:308:
+                       ret_val =3D -EIO;$

ERROR: spaces required around that '=' (ctx:WxV)
#1006: FILE: drivers/net/atl1e/atl1e_ethtool.c:308:
+                       ret_val =3D -EIO;
                                ^

ERROR: need consistent spacing around '-' (ctx:WxV)
#1006: FILE: drivers/net/atl1e/atl1e_ethtool.c:308:
+                       ret_val =3D -EIO;
                                    ^

ERROR: code indent should use tabs where possible
#1007: FILE: drivers/net/atl1e/atl1e_ethtool.c:309:
+                       goto out;$

ERROR: code indent should use tabs where possible
#1008: FILE: drivers/net/atl1e/atl1e_ethtool.c:310:
+               }$

ERROR: code indent should use tabs where possible
#1016: FILE: drivers/net/atl1e/atl1e_ethtool.c:318:
+               struct ethtool_drvinfo *drvinfo)$

ERROR: spaces required around that '=' (ctx:WxV)
#1018: FILE: drivers/net/atl1e/atl1e_ethtool.c:320:
+       struct atl1e_adapter *adapter =3D netdev_priv(netdev);
                                      ^

ERROR: spaces required around that '=' (ctx:WxV)
#1024: FILE: drivers/net/atl1e/atl1e_ethtool.c:326:
+       drvinfo->n_stats =3D 0;
                         ^

ERROR: spaces required around that '=' (ctx:WxV)
#1025: FILE: drivers/net/atl1e/atl1e_ethtool.c:327:
+       drvinfo->testinfo_len =3D 0;
                              ^

ERROR: spaces required around that '=' (ctx:WxV)
#1026: FILE: drivers/net/atl1e/atl1e_ethtool.c:328:
+       drvinfo->regdump_len =3D atl1e_get_regs_len(netdev);
                             ^

ERROR: spaces required around that '=' (ctx:WxV)
#1027: FILE: drivers/net/atl1e/atl1e_ethtool.c:329:
+       drvinfo->eedump_len =3D atl1e_get_eeprom_len(netdev);
                            ^

ERROR: code indent should use tabs where possible
#1031: FILE: drivers/net/atl1e/atl1e_ethtool.c:333:
+                         struct ethtool_wolinfo *wol)$

ERROR: spaces required around that '=' (ctx:WxV)
#1033: FILE: drivers/net/atl1e/atl1e_ethtool.c:335:
+       struct atl1e_adapter *adapter =3D netdev_priv(netdev);
                                      ^

ERROR: spaces required around that '=' (ctx:WxV)
#1035: FILE: drivers/net/atl1e/atl1e_ethtool.c:337:
+       wol->supported =3D WAKE_MAGIC | WAKE_PHY;
                       ^

ERROR: spaces required around that '=' (ctx:WxV)
#1036: FILE: drivers/net/atl1e/atl1e_ethtool.c:338:
+       wol->wolopts =3D 0;
                     ^

ERROR: code indent should use tabs where possible
#1039: FILE: drivers/net/atl1e/atl1e_ethtool.c:341:
+               wol->wolopts |=3D WAKE_UCAST;$

ERROR: spaces required around that '|=' (ctx:WxV)
#1039: FILE: drivers/net/atl1e/atl1e_ethtool.c:341:
+               wol->wolopts |=3D WAKE_UCAST;
                             ^

ERROR: code indent should use tabs where possible
#1041: FILE: drivers/net/atl1e/atl1e_ethtool.c:343:
+               wol->wolopts |=3D WAKE_MCAST;$

ERROR: spaces required around that '|=' (ctx:WxV)
#1041: FILE: drivers/net/atl1e/atl1e_ethtool.c:343:
+               wol->wolopts |=3D WAKE_MCAST;
                             ^

ERROR: code indent should use tabs where possible
#1043: FILE: drivers/net/atl1e/atl1e_ethtool.c:345:
+               wol->wolopts |=3D WAKE_BCAST;$

ERROR: spaces required around that '|=' (ctx:WxV)
#1043: FILE: drivers/net/atl1e/atl1e_ethtool.c:345:
+               wol->wolopts |=3D WAKE_BCAST;
                             ^

ERROR: code indent should use tabs where possible
#1045: FILE: drivers/net/atl1e/atl1e_ethtool.c:347:
+               wol->wolopts |=3D WAKE_MAGIC;$

ERROR: spaces required around that '|=' (ctx:WxV)
#1045: FILE: drivers/net/atl1e/atl1e_ethtool.c:347:
+               wol->wolopts |=3D WAKE_MAGIC;
                             ^

ERROR: code indent should use tabs where possible
#1047: FILE: drivers/net/atl1e/atl1e_ethtool.c:349:
+               wol->wolopts |=3D WAKE_PHY;$

ERROR: spaces required around that '|=' (ctx:WxV)
#1047: FILE: drivers/net/atl1e/atl1e_ethtool.c:349:
+               wol->wolopts |=3D WAKE_PHY;
                             ^

ERROR: spaces required around that '=' (ctx:VxE)
#1052: FILE: drivers/net/atl1e/atl1e_ethtool.c:354:
+static int atl1e_set_wol(struct net_device *netdev, struct ethtool_wolinfo=
                                                                           ^

ERROR: spaces required around that '=' (ctx:WxV)
#1055: FILE: drivers/net/atl1e/atl1e_ethtool.c:357:
+       struct atl1e_adapter *adapter =3D netdev_priv(netdev);
                                      ^

ERROR: code indent should use tabs where possible
#1058: FILE: drivers/net/atl1e/atl1e_ethtool.c:360:
+                           WAKE_MCAST | WAKE_BCAST | WAKE_MCAST))$

ERROR: code indent should use tabs where possible
#1059: FILE: drivers/net/atl1e/atl1e_ethtool.c:361:
+               return -EOPNOTSUPP;$

ERROR: spaces required around that '=' (ctx:WxV)
#1061: FILE: drivers/net/atl1e/atl1e_ethtool.c:363:
+       adapter->wol =3D 0;
                     ^

ERROR: code indent should use tabs where possible
#1064: FILE: drivers/net/atl1e/atl1e_ethtool.c:366:
+               adapter->wol |=3D AT_WUFC_MAG;$

ERROR: spaces required around that '|=' (ctx:WxV)
#1064: FILE: drivers/net/atl1e/atl1e_ethtool.c:366:
+               adapter->wol |=3D AT_WUFC_MAG;
                             ^

ERROR: code indent should use tabs where possible
#1066: FILE: drivers/net/atl1e/atl1e_ethtool.c:368:
+               adapter->wol |=3D AT_WUFC_LNKC;$

ERROR: spaces required around that '|=' (ctx:WxV)
#1066: FILE: drivers/net/atl1e/atl1e_ethtool.c:368:
+               adapter->wol |=3D AT_WUFC_LNKC;
                             ^

ERROR: spaces required around that '=' (ctx:WxV)
#1073: FILE: drivers/net/atl1e/atl1e_ethtool.c:375:
+       struct atl1e_adapter *adapter =3D netdev_priv(netdev);
                                      ^

ERROR: code indent should use tabs where possible
#1075: FILE: drivers/net/atl1e/atl1e_ethtool.c:377:
+               atl1e_reinit_locked(adapter);$

ERROR: spaces required around that '=' (ctx:WxV)
#1079: FILE: drivers/net/atl1e/atl1e_ethtool.c:381:
+static struct ethtool_ops atl1e_ethtool_ops =3D {
                                             ^

ERROR: spaces required around that '=' (ctx:WxV)
#1080: FILE: drivers/net/atl1e/atl1e_ethtool.c:382:
+       .get_settings           =3D atl1e_get_settings,
                                ^

ERROR: spaces required around that '=' (ctx:WxV)
#1081: FILE: drivers/net/atl1e/atl1e_ethtool.c:383:
+       .set_settings           =3D atl1e_set_settings,
                                ^

ERROR: spaces required around that '=' (ctx:WxV)
#1082: FILE: drivers/net/atl1e/atl1e_ethtool.c:384:
+       .get_drvinfo            =3D atl1e_get_drvinfo,
                                ^

ERROR: spaces required around that '=' (ctx:WxV)
#1083: FILE: drivers/net/atl1e/atl1e_ethtool.c:385:
+       .get_regs_len           =3D atl1e_get_regs_len,
                                ^

ERROR: spaces required around that '=' (ctx:WxV)
#1084: FILE: drivers/net/atl1e/atl1e_ethtool.c:386:
+       .get_regs               =3D atl1e_get_regs,
                                ^

ERROR: spaces required around that '=' (ctx:WxV)
#1085: FILE: drivers/net/atl1e/atl1e_ethtool.c:387:
+       .get_wol                =3D atl1e_get_wol,
                                ^

ERROR: spaces required around that '=' (ctx:WxV)
#1086: FILE: drivers/net/atl1e/atl1e_ethtool.c:388:
+       .set_wol                =3D atl1e_set_wol,
                                ^

ERROR: spaces required around that '=' (ctx:WxV)
#1087: FILE: drivers/net/atl1e/atl1e_ethtool.c:389:
+       .get_msglevel           =3D atl1e_get_msglevel,
                                ^

ERROR: spaces required around that '=' (ctx:WxV)
#1088: FILE: drivers/net/atl1e/atl1e_ethtool.c:390:
+       .set_msglevel           =3D atl1e_set_msglevel,
                                ^

ERROR: spaces required around that '=' (ctx:WxV)
#1089: FILE: drivers/net/atl1e/atl1e_ethtool.c:391:
+       .nway_reset             =3D atl1e_nway_reset,
                                ^

ERROR: spaces required around that '=' (ctx:WxV)
#1090: FILE: drivers/net/atl1e/atl1e_ethtool.c:392:
+       .get_link               =3D ethtool_op_get_link,
                                ^

ERROR: spaces required around that '=' (ctx:WxV)
#1091: FILE: drivers/net/atl1e/atl1e_ethtool.c:393:
+       .get_eeprom_len         =3D atl1e_get_eeprom_len,
                                ^

ERROR: spaces required around that '=' (ctx:WxV)
#1092: FILE: drivers/net/atl1e/atl1e_ethtool.c:394:
+       .get_eeprom             =3D atl1e_get_eeprom,
                                ^

ERROR: spaces required around that '=' (ctx:WxV)
#1093: FILE: drivers/net/atl1e/atl1e_ethtool.c:395:
+       .set_eeprom             =3D atl1e_set_eeprom,
                                ^

ERROR: spaces required around that '=' (ctx:WxV)
#1094: FILE: drivers/net/atl1e/atl1e_ethtool.c:396:
+       .get_tx_csum            =3D atl1e_get_tx_csum,
                                ^

ERROR: spaces required around that '=' (ctx:WxV)
#1095: FILE: drivers/net/atl1e/atl1e_ethtool.c:397:
+       .get_sg                 =3D ethtool_op_get_sg,
                                ^

ERROR: spaces required around that '=' (ctx:WxV)
#1096: FILE: drivers/net/atl1e/atl1e_ethtool.c:398:
+       .set_sg                 =3D ethtool_op_set_sg,
                                ^

ERROR: spaces required around that '=' (ctx:WxV)
#1098: FILE: drivers/net/atl1e/atl1e_ethtool.c:400:
+       .get_tso                =3D ethtool_op_get_tso,
                                ^

ERROR: spaces required around that '=' (ctx:WxV)
#1152: FILE: drivers/net/atl1e/atl1e_hw.c:37:
+       value =3D AT_READ_REG(hw, REG_SPI_FLASH_CTRL);
              ^

ERROR: code indent should use tabs where possible
#1154: FILE: drivers/net/atl1e/atl1e_hw.c:39:
+               value &=3D ~SPI_FLASH_CTRL_EN_VPD;$

ERROR: spaces required around that '&=' (ctx:WxV)
#1154: FILE: drivers/net/atl1e/atl1e_hw.c:39:
+               value &=3D ~SPI_FLASH_CTRL_EN_VPD;
                      ^

ERROR: code indent should use tabs where possible
#1155: FILE: drivers/net/atl1e/atl1e_hw.c:40:
+               AT_WRITE_REG(hw, REG_SPI_FLASH_CTRL, value);$

ERROR: spaces required around that '=' (ctx:WxV)
#1157: FILE: drivers/net/atl1e/atl1e_hw.c:42:
+       value =3D AT_READ_REGW(hw, REG_PCIE_CAP_LIST);
              ^

ERROR: spaces required around that '=' (ctx:WxV)
#1158: FILE: drivers/net/atl1e/atl1e_hw.c:43:
+       return ((value & 0xFF00) =3D=3D 0x6C00) ? 0 : 1;
                                 ^

ERROR: spaces required around that '=' (ctx:VxV)
#1158: FILE: drivers/net/atl1e/atl1e_hw.c:43:
+       return ((value & 0xFF00) =3D=3D 0x6C00) ? 0 : 1;
                                    ^

ERROR: code indent should use tabs where possible
#1165: FILE: drivers/net/atl1e/atl1e_hw.c:50:
+        * 00-0B-6A-F6-00-DC$

ERROR: code indent should use tabs where possible
#1166: FILE: drivers/net/atl1e/atl1e_hw.c:51:
+        * 0:  6AF600DC 1: 000B$

ERROR: code indent should use tabs where possible
#1167: FILE: drivers/net/atl1e/atl1e_hw.c:52:
+        * low dword$

ERROR: code indent should use tabs where possible
#1168: FILE: drivers/net/atl1e/atl1e_hw.c:53:
+        */$

WARNING: space prohibited between function name and open parenthesis '('
#1169: FILE: drivers/net/atl1e/atl1e_hw.c:54:
+       value =3D (((u32)hw->mac_addr[2]) << 24) |

ERROR: spaces required around that '=' (ctx:WxV)
#1169: FILE: drivers/net/atl1e/atl1e_hw.c:54:
+       value =3D (((u32)hw->mac_addr[2]) << 24) |
              ^

ERROR: code indent should use tabs where possible
#1170: FILE: drivers/net/atl1e/atl1e_hw.c:55:
+               (((u32)hw->mac_addr[3]) << 16) |$

ERROR: code indent should use tabs where possible
#1171: FILE: drivers/net/atl1e/atl1e_hw.c:56:
+               (((u32)hw->mac_addr[4]) << 8)  |$

ERROR: code indent should use tabs where possible
#1172: FILE: drivers/net/atl1e/atl1e_hw.c:57:
+               (((u32)hw->mac_addr[5])) ;$

WARNING: space prohibited between function name and open parenthesis '('
#1175: FILE: drivers/net/atl1e/atl1e_hw.c:60:
+       value =3D (((u32)hw->mac_addr[0]) << 8) |

ERROR: spaces required around that '=' (ctx:WxV)
#1175: FILE: drivers/net/atl1e/atl1e_hw.c:60:
+       value =3D (((u32)hw->mac_addr[0]) << 8) |
              ^

ERROR: code indent should use tabs where possible
#1176: FILE: drivers/net/atl1e/atl1e_hw.c:61:
+               (((u32)hw->mac_addr[1])) ;$

ERROR: code indent should use tabs where possible
#1192: FILE: drivers/net/atl1e/atl1e_hw.c:77:
+               return 0;$

ERROR: spaces required around that '=' (ctx:WxV)
#1195: FILE: drivers/net/atl1e/atl1e_hw.c:80:
+       addr[0] =3D addr[1] =3D 0;
                ^

ERROR: spaces required around that '=' (ctx:WxV)
#1195: FILE: drivers/net/atl1e/atl1e_hw.c:80:
+       addr[0] =3D addr[1] =3D 0;
                            ^

ERROR: code indent should use tabs where possible
#1198: FILE: drivers/net/atl1e/atl1e_hw.c:83:
+               /* eeprom exist */$

ERROR: code indent should use tabs where possible
#1199: FILE: drivers/net/atl1e/atl1e_hw.c:84:
+               twsi_ctrl_data =3D AT_READ_REG(hw, REG_TWSI_CTRL);$

ERROR: spaces required around that '=' (ctx:WxV)
#1199: FILE: drivers/net/atl1e/atl1e_hw.c:84:
+               twsi_ctrl_data =3D AT_READ_REG(hw, REG_TWSI_CTRL);
                               ^

ERROR: code indent should use tabs where possible
#1200: FILE: drivers/net/atl1e/atl1e_hw.c:85:
+               twsi_ctrl_data |=3D TWSI_CTRL_SW_LDSTART;$

ERROR: spaces required around that '|=' (ctx:WxV)
#1200: FILE: drivers/net/atl1e/atl1e_hw.c:85:
+               twsi_ctrl_data |=3D TWSI_CTRL_SW_LDSTART;
                               ^

ERROR: code indent should use tabs where possible
#1201: FILE: drivers/net/atl1e/atl1e_hw.c:86:
+               AT_WRITE_REG(hw, REG_TWSI_CTRL, twsi_ctrl_data);$

ERROR: code indent should use tabs where possible
#1202: FILE: drivers/net/atl1e/atl1e_hw.c:87:
+               for (i =3D 0; i < AT_TWSI_EEPROM_TIMEOUT; i++) {$

ERROR: spaces required around that '=' (ctx:WxV)
#1202: FILE: drivers/net/atl1e/atl1e_hw.c:87:
+               for (i =3D 0; i < AT_TWSI_EEPROM_TIMEOUT; i++) {
                       ^

ERROR: code indent should use tabs where possible
#1203: FILE: drivers/net/atl1e/atl1e_hw.c:88:
+                       msleep(10);$

ERROR: code indent should use tabs where possible
#1204: FILE: drivers/net/atl1e/atl1e_hw.c:89:
+                       twsi_ctrl_data =3D AT_READ_REG(hw, REG_TWSI_CTRL);$

ERROR: spaces required around that '=' (ctx:WxV)
#1204: FILE: drivers/net/atl1e/atl1e_hw.c:89:
+                       twsi_ctrl_data =3D AT_READ_REG(hw, REG_TWSI_CTRL);
                                       ^

ERROR: code indent should use tabs where possible
#1205: FILE: drivers/net/atl1e/atl1e_hw.c:90:
+                       if ((twsi_ctrl_data & TWSI_CTRL_SW_LDSTART) =3D=3D =$

ERROR: spaces required around that '=' (ctx:WxV)
#1205: FILE: drivers/net/atl1e/atl1e_hw.c:90:
+                       if ((twsi_ctrl_data & TWSI_CTRL_SW_LDSTART) =3D=3D =
                                                                    ^

ERROR: spaces required around that '=' (ctx:VxV)
#1205: FILE: drivers/net/atl1e/atl1e_hw.c:90:
+                       if ((twsi_ctrl_data & TWSI_CTRL_SW_LDSTART) =3D=3D =
                                                                       ^

ERROR: do not use assignment in if condition
#1205: FILE: drivers/net/atl1e/atl1e_hw.c:90:
+                       if ((twsi_ctrl_data & TWSI_CTRL_SW_LDSTART) =3D=3D =

ERROR: code indent should use tabs where possible
#1207: FILE: drivers/net/atl1e/atl1e_hw.c:91:
+                               break;$

ERROR: code indent should use tabs where possible
#1208: FILE: drivers/net/atl1e/atl1e_hw.c:92:
+               }$

ERROR: code indent should use tabs where possible
#1209: FILE: drivers/net/atl1e/atl1e_hw.c:93:
+               if (i >=3D AT_TWSI_EEPROM_TIMEOUT)$

ERROR: spaces required around that '>=' (ctx:WxV)
#1209: FILE: drivers/net/atl1e/atl1e_hw.c:93:
+               if (i >=3D AT_TWSI_EEPROM_TIMEOUT)
                      ^

ERROR: code indent should use tabs where possible
#1210: FILE: drivers/net/atl1e/atl1e_hw.c:94:
+                       return AT_ERR_TIMEOUT;$

ERROR: spaces required around that '=' (ctx:WxV)
#1214: FILE: drivers/net/atl1e/atl1e_hw.c:98:
+       addr[0] =3D AT_READ_REG(hw, REG_MAC_STA_ADDR);
                ^

ERROR: spaces required around that '=' (ctx:WxV)
#1215: FILE: drivers/net/atl1e/atl1e_hw.c:99:
+       addr[1] =3D AT_READ_REG(hw, REG_MAC_STA_ADDR + 4);
                ^

ERROR: spaces required around that '=' (ctx:WxV)
#1216: FILE: drivers/net/atl1e/atl1e_hw.c:100:
+       *(u32 *) &eth_addr[2] =3D swab32(addr[0]);
                              ^

ERROR: spaces required around that '=' (ctx:WxV)
#1217: FILE: drivers/net/atl1e/atl1e_hw.c:101:
+       *(u16 *) &eth_addr[0] =3D swab16(*(u16 *)&addr[1]);
                              ^

ERROR: code indent should use tabs where possible
#1220: FILE: drivers/net/atl1e/atl1e_hw.c:104:
+               memcpy(hw->perm_mac_addr, eth_addr, ETH_ALEN);$

ERROR: code indent should use tabs where possible
#1221: FILE: drivers/net/atl1e/atl1e_hw.c:105:
+               return 0;$

ERROR: code indent should use tabs where possible
#1238: FILE: drivers/net/atl1e/atl1e_hw.c:122:
+               return false; /* address do not align */$

WARNING: space prohibited between function name and open parenthesis '('
#1241: FILE: drivers/net/atl1e/atl1e_hw.c:125:
+       control =3D (offset & VPD_CAP_VPD_ADDR_MASK) << VPD_CAP_VPD_ADDR_SH=

ERROR: spaces required around that '=' (ctx:WxV)
#1241: FILE: drivers/net/atl1e/atl1e_hw.c:125:
+       control =3D (offset & VPD_CAP_VPD_ADDR_MASK) << VPD_CAP_VPD_ADDR_SH=
                ^

ERROR: spaces required around that '=' (ctx:VxE)
#1241: FILE: drivers/net/atl1e/atl1e_hw.c:125:
+       control =3D (offset & VPD_CAP_VPD_ADDR_MASK) << VPD_CAP_VPD_ADDR_SH=
                                                                           ^

ERROR: spaces required around that '=' (ctx:WxV)
#1245: FILE: drivers/net/atl1e/atl1e_hw.c:128:
+       for (i =3D 0; i < 10; i++) {
               ^

ERROR: code indent should use tabs where possible
#1246: FILE: drivers/net/atl1e/atl1e_hw.c:129:
+               msleep(2);$

ERROR: code indent should use tabs where possible
#1247: FILE: drivers/net/atl1e/atl1e_hw.c:130:
+               control =3D AT_READ_REG(hw, REG_VPD_CAP);$

ERROR: spaces required around that '=' (ctx:WxV)
#1247: FILE: drivers/net/atl1e/atl1e_hw.c:130:
+               control =3D AT_READ_REG(hw, REG_VPD_CAP);
                        ^

ERROR: code indent should use tabs where possible
#1248: FILE: drivers/net/atl1e/atl1e_hw.c:131:
+               if (control & VPD_CAP_VPD_FLAG)$

ERROR: code indent should use tabs where possible
#1249: FILE: drivers/net/atl1e/atl1e_hw.c:132:
+                       break;$

ERROR: code indent should use tabs where possible
#1252: FILE: drivers/net/atl1e/atl1e_hw.c:135:
+               *p_value =3D AT_READ_REG(hw, REG_VPD_DATA);$

ERROR: spaces required around that '=' (ctx:WxV)
#1252: FILE: drivers/net/atl1e/atl1e_hw.c:135:
+               *p_value =3D AT_READ_REG(hw, REG_VPD_DATA);
                         ^

ERROR: code indent should use tabs where possible
#1253: FILE: drivers/net/atl1e/atl1e_hw.c:136:
+               return true;$

ERROR: code indent should use tabs where possible
#1261: FILE: drivers/net/atl1e/atl1e_hw.c:144:
+                       GPHY_CTRL_PW_WOL_DIS | GPHY_CTRL_EXT_RESET);$

ERROR: spaces required around that '=' (ctx:WxV)
#1271: FILE: drivers/net/atl1e/atl1e_hw.c:154:
+       int err =3D 0;
                ^

ERROR: spaces required around that '=' (ctx:WxV)
#1273: FILE: drivers/net/atl1e/atl1e_hw.c:156:
+       err =3D atl1e_get_permanent_address(hw);
            ^

ERROR: code indent should use tabs where possible
#1275: FILE: drivers/net/atl1e/atl1e_hw.c:158:
+               return AT_ERR_EEPROM;$

ERROR: spaces required around that '=' (ctx:WxV)
#1291: FILE: drivers/net/atl1e/atl1e_hw.c:174:
+       u32 value =3D 0;
                  ^

ERROR: spaces required around that '=' (ctx:WxV)
#1294: FILE: drivers/net/atl1e/atl1e_hw.c:177:
+       crc32 =3D ether_crc_le(6, mc_addr);
              ^

ERROR: spaces required around that '=' (ctx:WxV)
#1295: FILE: drivers/net/atl1e/atl1e_hw.c:178:
+       crc32 =3D ~crc32;
              ^

ERROR: spaces required around that '=' (ctx:WxV)
#1296: FILE: drivers/net/atl1e/atl1e_hw.c:179:
+       for (i =3D 0; i < 32; i++)
               ^

ERROR: code indent should use tabs where possible
#1297: FILE: drivers/net/atl1e/atl1e_hw.c:180:
+               value |=3D (((crc32 >> i) & 1) << (31 - i));$

WARNING: space prohibited between function name and open parenthesis '('
#1297: FILE: drivers/net/atl1e/atl1e_hw.c:180:
+               value |=3D (((crc32 >> i) & 1) << (31 - i));

ERROR: spaces required around that '|=' (ctx:WxV)
#1297: FILE: drivers/net/atl1e/atl1e_hw.c:180:
+               value |=3D (((crc32 >> i) & 1) << (31 - i));
                      ^

ERROR: code indent should use tabs where possible
#1313: FILE: drivers/net/atl1e/atl1e_hw.c:196:
+        * The HASH Table  is a register array of 2 32-bit registers.$

ERROR: code indent should use tabs where possible
#1314: FILE: drivers/net/atl1e/atl1e_hw.c:197:
+        * It is treated like an array of 64 bits.  We want to set$

ERROR: code indent should use tabs where possible
#1315: FILE: drivers/net/atl1e/atl1e_hw.c:198:
+        * bit BitArray[hash_value]. So we figure out what register$

ERROR: code indent should use tabs where possible
#1316: FILE: drivers/net/atl1e/atl1e_hw.c:199:
+        * the bit is in, read it, OR in the new bit, then write$

ERROR: code indent should use tabs where possible
#1317: FILE: drivers/net/atl1e/atl1e_hw.c:200:
+        * back the new value.  The register is determined by the$

ERROR: code indent should use tabs where possible
#1318: FILE: drivers/net/atl1e/atl1e_hw.c:201:
+        * upper 7 bits of the hash value and the bit within that$

ERROR: code indent should use tabs where possible
#1319: FILE: drivers/net/atl1e/atl1e_hw.c:202:
+        * register are determined by the lower 5 bits of the value.$

ERROR: code indent should use tabs where possible
#1320: FILE: drivers/net/atl1e/atl1e_hw.c:203:
+        */$

WARNING: space prohibited between function name and open parenthesis '('
#1321: FILE: drivers/net/atl1e/atl1e_hw.c:204:
+       hash_reg =3D (hash_value >> 31) & 0x1;

ERROR: spaces required around that '=' (ctx:WxV)
#1321: FILE: drivers/net/atl1e/atl1e_hw.c:204:
+       hash_reg =3D (hash_value >> 31) & 0x1;
                 ^

WARNING: space prohibited between function name and open parenthesis '('
#1322: FILE: drivers/net/atl1e/atl1e_hw.c:205:
+       hash_bit =3D (hash_value >> 26) & 0x1F;

ERROR: spaces required around that '=' (ctx:WxV)
#1322: FILE: drivers/net/atl1e/atl1e_hw.c:205:
+       hash_bit =3D (hash_value >> 26) & 0x1F;
                 ^

ERROR: spaces required around that '=' (ctx:WxV)
#1324: FILE: drivers/net/atl1e/atl1e_hw.c:207:
+       mta =3D AT_READ_REG_ARRAY(hw, REG_RX_HASH_TABLE, hash_reg);
            ^

WARNING: space prohibited between function name and open parenthesis '('
#1326: FILE: drivers/net/atl1e/atl1e_hw.c:209:
+       mta |=3D (1 << hash_bit);

ERROR: spaces required around that '|=' (ctx:WxV)
#1326: FILE: drivers/net/atl1e/atl1e_hw.c:209:
+       mta |=3D (1 << hash_bit);
            ^

WARNING: space prohibited between function name and open parenthesis '('
#1340: FILE: drivers/net/atl1e/atl1e_hw.c:223:
+       val =3D ((u32)(reg_addr & MDIO_REG_ADDR_MASK)) << MDIO_REG_ADDR_SHI=

ERROR: spaces required around that '=' (ctx:WxV)
#1340: FILE: drivers/net/atl1e/atl1e_hw.c:223:
+       val =3D ((u32)(reg_addr & MDIO_REG_ADDR_MASK)) << MDIO_REG_ADDR_SHI=
            ^

ERROR: spaces required around that '=' (ctx:VxE)
#1340: FILE: drivers/net/atl1e/atl1e_hw.c:223:
+       val =3D ((u32)(reg_addr & MDIO_REG_ADDR_MASK)) << MDIO_REG_ADDR_SHI=
                                                                           ^

ERROR: code indent should use tabs where possible
#1342: FILE: drivers/net/atl1e/atl1e_hw.c:224:
+               MDIO_START | MDIO_SUP_PREAMBLE | MDIO_RW |$

ERROR: code indent should use tabs where possible
#1343: FILE: drivers/net/atl1e/atl1e_hw.c:225:
+               MDIO_CLK_25_4 << MDIO_CLK_SEL_SHIFT;$

ERROR: spaces required around that '=' (ctx:WxV)
#1349: FILE: drivers/net/atl1e/atl1e_hw.c:231:
+       for (i =3D 0; i < MDIO_WAIT_TIMES; i++) {
               ^

ERROR: code indent should use tabs where possible
#1350: FILE: drivers/net/atl1e/atl1e_hw.c:232:
+               udelay(2);$

ERROR: code indent should use tabs where possible
#1351: FILE: drivers/net/atl1e/atl1e_hw.c:233:
+               val =3D AT_READ_REG(hw, REG_MDIO_CTRL);$

ERROR: spaces required around that '=' (ctx:WxV)
#1351: FILE: drivers/net/atl1e/atl1e_hw.c:233:
+               val =3D AT_READ_REG(hw, REG_MDIO_CTRL);
                    ^

ERROR: code indent should use tabs where possible
#1352: FILE: drivers/net/atl1e/atl1e_hw.c:234:
+               if (!(val & (MDIO_START | MDIO_BUSY)))$

ERROR: code indent should use tabs where possible
#1353: FILE: drivers/net/atl1e/atl1e_hw.c:235:
+                       break;$

ERROR: code indent should use tabs where possible
#1354: FILE: drivers/net/atl1e/atl1e_hw.c:236:
+               wmb();$

ERROR: code indent should use tabs where possible
#1357: FILE: drivers/net/atl1e/atl1e_hw.c:239:
+               *phy_data =3D (u16)val;$

WARNING: space prohibited between function name and open parenthesis '('
#1357: FILE: drivers/net/atl1e/atl1e_hw.c:239:
+               *phy_data =3D (u16)val;

ERROR: spaces required around that '=' (ctx:WxV)
#1357: FILE: drivers/net/atl1e/atl1e_hw.c:239:
+               *phy_data =3D (u16)val;
                          ^

ERROR: code indent should use tabs where possible
#1358: FILE: drivers/net/atl1e/atl1e_hw.c:240:
+               return 0;$

WARNING: space prohibited between function name and open parenthesis '('
#1375: FILE: drivers/net/atl1e/atl1e_hw.c:257:
+       val =3D ((u32)(phy_data & MDIO_DATA_MASK)) << MDIO_DATA_SHIFT |

ERROR: spaces required around that '=' (ctx:WxV)
#1375: FILE: drivers/net/atl1e/atl1e_hw.c:257:
+       val =3D ((u32)(phy_data & MDIO_DATA_MASK)) << MDIO_DATA_SHIFT |
            ^

ERROR: code indent should use tabs where possible
#1376: FILE: drivers/net/atl1e/atl1e_hw.c:258:
+              (reg_addr&MDIO_REG_ADDR_MASK) << MDIO_REG_ADDR_SHIFT |$

ERROR: code indent should use tabs where possible
#1377: FILE: drivers/net/atl1e/atl1e_hw.c:259:
+              MDIO_SUP_PREAMBLE |$

ERROR: code indent should use tabs where possible
#1378: FILE: drivers/net/atl1e/atl1e_hw.c:260:
+              MDIO_START |$

ERROR: code indent should use tabs where possible
#1379: FILE: drivers/net/atl1e/atl1e_hw.c:261:
+              MDIO_CLK_25_4 << MDIO_CLK_SEL_SHIFT;$

ERROR: spaces required around that '=' (ctx:WxV)
#1384: FILE: drivers/net/atl1e/atl1e_hw.c:266:
+       for (i =3D 0; i < MDIO_WAIT_TIMES; i++) {
               ^

ERROR: code indent should use tabs where possible
#1385: FILE: drivers/net/atl1e/atl1e_hw.c:267:
+               udelay(2);$

ERROR: code indent should use tabs where possible
#1386: FILE: drivers/net/atl1e/atl1e_hw.c:268:
+               val =3D AT_READ_REG(hw, REG_MDIO_CTRL);$

ERROR: spaces required around that '=' (ctx:WxV)
#1386: FILE: drivers/net/atl1e/atl1e_hw.c:268:
+               val =3D AT_READ_REG(hw, REG_MDIO_CTRL);
                    ^

ERROR: code indent should use tabs where possible
#1387: FILE: drivers/net/atl1e/atl1e_hw.c:269:
+               if (!(val & (MDIO_START | MDIO_BUSY)))$

ERROR: code indent should use tabs where possible
#1388: FILE: drivers/net/atl1e/atl1e_hw.c:270:
+                       break;$

ERROR: code indent should use tabs where possible
#1389: FILE: drivers/net/atl1e/atl1e_hw.c:271:
+               wmb();$

ERROR: code indent should use tabs where possible
#1393: FILE: drivers/net/atl1e/atl1e_hw.c:275:
+               return 0;$

ERROR: code indent should use tabs where possible
#1405: FILE: drivers/net/atl1e/atl1e_hw.c:287:
+          value =3D LTSSM_TEST_MODE_DEF;$

ERROR: code indent should use tabs where possible
#1406: FILE: drivers/net/atl1e/atl1e_hw.c:288:
+          AT_WRITE_REG(hw, REG_LTSSM_TEST_MODE, value);$

ERROR: code indent should use tabs where possible
#1407: FILE: drivers/net/atl1e/atl1e_hw.c:289:
+        */$

ERROR: spaces required around that '=' (ctx:WxV)
#1410: FILE: drivers/net/atl1e/atl1e_hw.c:292:
+       value =3D AT_READ_REG(hw, 0x1008);
              ^

ERROR: spaces required around that '|=' (ctx:WxV)
#1411: FILE: drivers/net/atl1e/atl1e_hw.c:293:
+       value |=3D 0x8000;
              ^

ERROR: spaces required around that '!=' (ctx:WxV)
#1425: FILE: drivers/net/atl1e/atl1e_hw.c:307:
+       if (0 !=3D hw->mii_autoneg_adv_reg)
              ^

ERROR: code indent should use tabs where possible
#1426: FILE: drivers/net/atl1e/atl1e_hw.c:308:
+               return 0;$

ERROR: spaces required around that '=' (ctx:WxV)
#1428: FILE: drivers/net/atl1e/atl1e_hw.c:310:
+       mii_autoneg_adv_reg =3D MII_AR_DEFAULT_CAP_MASK;
                            ^

ERROR: spaces required around that '=' (ctx:WxV)
#1429: FILE: drivers/net/atl1e/atl1e_hw.c:311:
+       mii_1000t_ctrl_reg  =3D MII_AT001_CR_1000T_DEFAULT_CAP_MASK;
                            ^

ERROR: code indent should use tabs where possible
#1432: FILE: drivers/net/atl1e/atl1e_hw.c:314:
+        * Need to parse autoneg_advertised  and set up$

ERROR: code indent should use tabs where possible
#1433: FILE: drivers/net/atl1e/atl1e_hw.c:315:
+        * the appropriate PHY registers.  First we will parse for$

ERROR: code indent should use tabs where possible
#1434: FILE: drivers/net/atl1e/atl1e_hw.c:316:
+        * autoneg_advertised software override.  Since we can advertise$

ERROR: code indent should use tabs where possible
#1435: FILE: drivers/net/atl1e/atl1e_hw.c:317:
+        * a plethora of combinations, we need to check each bit$

ERROR: code indent should use tabs where possible
#1436: FILE: drivers/net/atl1e/atl1e_hw.c:318:
+        * individually.$

ERROR: code indent should use tabs where possible
#1437: FILE: drivers/net/atl1e/atl1e_hw.c:319:
+        */$

ERROR: code indent should use tabs where possible
#1440: FILE: drivers/net/atl1e/atl1e_hw.c:322:
+        * First we clear all the 10/100 mb speed bits in the Auto-Neg$

ERROR: code indent should use tabs where possible
#1441: FILE: drivers/net/atl1e/atl1e_hw.c:323:
+        * Advertisement Register (Address 4) and the 1000 mb speed bits in$

ERROR: code indent should use tabs where possible
#1442: FILE: drivers/net/atl1e/atl1e_hw.c:324:
+        * the  1000Base-T control Register (Address 9).$

ERROR: code indent should use tabs where possible
#1443: FILE: drivers/net/atl1e/atl1e_hw.c:325:
+        */$

ERROR: spaces required around that '&=' (ctx:WxV)
#1444: FILE: drivers/net/atl1e/atl1e_hw.c:326:
+       mii_autoneg_adv_reg &=3D ~MII_AR_SPEED_MASK;
                            ^

ERROR: spaces required around that '&=' (ctx:WxV)
#1445: FILE: drivers/net/atl1e/atl1e_hw.c:327:
+       mii_1000t_ctrl_reg  &=3D ~MII_AT001_CR_1000T_SPEED_MASK;
                            ^

ERROR: code indent should use tabs where possible
#1448: FILE: drivers/net/atl1e/atl1e_hw.c:330:
+        * Need to parse MediaType and setup the$

ERROR: code indent should use tabs where possible
#1449: FILE: drivers/net/atl1e/atl1e_hw.c:331:
+        * appropriate PHY registers.$

ERROR: code indent should use tabs where possible
#1450: FILE: drivers/net/atl1e/atl1e_hw.c:332:
+        */$

ERROR: code indent should use tabs where possible
#1453: FILE: drivers/net/atl1e/atl1e_hw.c:335:
+               mii_autoneg_adv_reg |=3D (MII_AR_10T_HD_CAPS   |$

WARNING: space prohibited between function name and open parenthesis '('
#1453: FILE: drivers/net/atl1e/atl1e_hw.c:335:
+               mii_autoneg_adv_reg |=3D (MII_AR_10T_HD_CAPS   |

ERROR: spaces required around that '|=' (ctx:WxV)
#1453: FILE: drivers/net/atl1e/atl1e_hw.c:335:
+               mii_autoneg_adv_reg |=3D (MII_AR_10T_HD_CAPS   |
                                    ^

ERROR: code indent should use tabs where possible
#1454: FILE: drivers/net/atl1e/atl1e_hw.c:336:
+                                       MII_AR_10T_FD_CAPS   |$

ERROR: code indent should use tabs where possible
#1455: FILE: drivers/net/atl1e/atl1e_hw.c:337:
+                                       MII_AR_100TX_HD_CAPS |$

ERROR: code indent should use tabs where possible
#1456: FILE: drivers/net/atl1e/atl1e_hw.c:338:
+                                       MII_AR_100TX_FD_CAPS);$

ERROR: code indent should use tabs where possible
#1457: FILE: drivers/net/atl1e/atl1e_hw.c:339:
+               hw->autoneg_advertised =3D ADVERTISE_10_HALF  |$

ERROR: spaces required around that '=' (ctx:WxV)
#1457: FILE: drivers/net/atl1e/atl1e_hw.c:339:
+               hw->autoneg_advertised =3D ADVERTISE_10_HALF  |
                                       ^

ERROR: code indent should use tabs where possible
#1458: FILE: drivers/net/atl1e/atl1e_hw.c:340:
+                                        ADVERTISE_10_FULL  |$

ERROR: code indent should use tabs where possible
#1459: FILE: drivers/net/atl1e/atl1e_hw.c:341:
+                                        ADVERTISE_100_HALF |$

ERROR: code indent should use tabs where possible
#1460: FILE: drivers/net/atl1e/atl1e_hw.c:342:
+                                        ADVERTISE_100_FULL;$

ERROR: code indent should use tabs where possible
#1461: FILE: drivers/net/atl1e/atl1e_hw.c:343:
+               if (hw->nic_type =3D=3D athr_l1e) {$

ERROR: spaces required around that '=' (ctx:WxV)
#1461: FILE: drivers/net/atl1e/atl1e_hw.c:343:
+               if (hw->nic_type =3D=3D athr_l1e) {
                                 ^

ERROR: spaces required around that '=' (ctx:VxV)
#1461: FILE: drivers/net/atl1e/atl1e_hw.c:343:
+               if (hw->nic_type =3D=3D athr_l1e) {
                                    ^

ERROR: do not use assignment in if condition
#1461: FILE: drivers/net/atl1e/atl1e_hw.c:343:
+               if (hw->nic_type =3D=3D athr_l1e) {

ERROR: code indent should use tabs where possible
#1462: FILE: drivers/net/atl1e/atl1e_hw.c:344:
+                       mii_1000t_ctrl_reg |=3D$

ERROR: spaces required around that '|=' (ctx:WxV)
#1462: FILE: drivers/net/atl1e/atl1e_hw.c:344:
+                       mii_1000t_ctrl_reg |=3D
                                           ^

ERROR: code indent should use tabs where possible
#1463: FILE: drivers/net/atl1e/atl1e_hw.c:345:
+                               MII_AT001_CR_1000T_FD_CAPS;$

ERROR: code indent should use tabs where possible
#1464: FILE: drivers/net/atl1e/atl1e_hw.c:346:
+                       hw->autoneg_advertised |=3D ADVERTISE_1000_FULL;$

ERROR: spaces required around that '|=' (ctx:WxV)
#1464: FILE: drivers/net/atl1e/atl1e_hw.c:346:
+                       hw->autoneg_advertised |=3D ADVERTISE_1000_FULL;
                                               ^

ERROR: code indent should use tabs where possible
#1465: FILE: drivers/net/atl1e/atl1e_hw.c:347:
+               }$

ERROR: code indent should use tabs where possible
#1466: FILE: drivers/net/atl1e/atl1e_hw.c:348:
+               break;$

ERROR: code indent should use tabs where possible
#1469: FILE: drivers/net/atl1e/atl1e_hw.c:351:
+               mii_autoneg_adv_reg   |=3D MII_AR_100TX_FD_CAPS;$

ERROR: spaces required around that '|=' (ctx:WxV)
#1469: FILE: drivers/net/atl1e/atl1e_hw.c:351:
+               mii_autoneg_adv_reg   |=3D MII_AR_100TX_FD_CAPS;
                                      ^

ERROR: code indent should use tabs where possible
#1470: FILE: drivers/net/atl1e/atl1e_hw.c:352:
+               hw->autoneg_advertised =3D ADVERTISE_100_FULL;$

ERROR: spaces required around that '=' (ctx:WxV)
#1470: FILE: drivers/net/atl1e/atl1e_hw.c:352:
+               hw->autoneg_advertised =3D ADVERTISE_100_FULL;
                                       ^

ERROR: code indent should use tabs where possible
#1471: FILE: drivers/net/atl1e/atl1e_hw.c:353:
+               break;$

ERROR: code indent should use tabs where possible
#1474: FILE: drivers/net/atl1e/atl1e_hw.c:356:
+               mii_autoneg_adv_reg   |=3D MII_AR_100TX_HD_CAPS;$

ERROR: spaces required around that '|=' (ctx:WxV)
#1474: FILE: drivers/net/atl1e/atl1e_hw.c:356:
+               mii_autoneg_adv_reg   |=3D MII_AR_100TX_HD_CAPS;
                                      ^

ERROR: code indent should use tabs where possible
#1475: FILE: drivers/net/atl1e/atl1e_hw.c:357:
+               hw->autoneg_advertised =3D ADVERTISE_100_HALF;$

ERROR: spaces required around that '=' (ctx:WxV)
#1475: FILE: drivers/net/atl1e/atl1e_hw.c:357:
+               hw->autoneg_advertised =3D ADVERTISE_100_HALF;
                                       ^

ERROR: code indent should use tabs where possible
#1476: FILE: drivers/net/atl1e/atl1e_hw.c:358:
+               break;$

ERROR: code indent should use tabs where possible
#1479: FILE: drivers/net/atl1e/atl1e_hw.c:361:
+               mii_autoneg_adv_reg   |=3D MII_AR_10T_FD_CAPS;$

ERROR: spaces required around that '|=' (ctx:WxV)
#1479: FILE: drivers/net/atl1e/atl1e_hw.c:361:
+               mii_autoneg_adv_reg   |=3D MII_AR_10T_FD_CAPS;
                                      ^

ERROR: code indent should use tabs where possible
#1480: FILE: drivers/net/atl1e/atl1e_hw.c:362:
+               hw->autoneg_advertised =3D ADVERTISE_10_FULL;$

ERROR: spaces required around that '=' (ctx:WxV)
#1480: FILE: drivers/net/atl1e/atl1e_hw.c:362:
+               hw->autoneg_advertised =3D ADVERTISE_10_FULL;
                                       ^

ERROR: code indent should use tabs where possible
#1481: FILE: drivers/net/atl1e/atl1e_hw.c:363:
+               break;$

ERROR: code indent should use tabs where possible
#1484: FILE: drivers/net/atl1e/atl1e_hw.c:366:
+               mii_autoneg_adv_reg   |=3D MII_AR_10T_HD_CAPS;$

ERROR: spaces required around that '|=' (ctx:WxV)
#1484: FILE: drivers/net/atl1e/atl1e_hw.c:366:
+               mii_autoneg_adv_reg   |=3D MII_AR_10T_HD_CAPS;
                                      ^

ERROR: code indent should use tabs where possible
#1485: FILE: drivers/net/atl1e/atl1e_hw.c:367:
+               hw->autoneg_advertised =3D ADVERTISE_10_HALF;$

ERROR: spaces required around that '=' (ctx:WxV)
#1485: FILE: drivers/net/atl1e/atl1e_hw.c:367:
+               hw->autoneg_advertised =3D ADVERTISE_10_HALF;
                                       ^

ERROR: code indent should use tabs where possible
#1486: FILE: drivers/net/atl1e/atl1e_hw.c:368:
+               break;$

WARNING: space prohibited between function name and open parenthesis '('
#1490: FILE: drivers/net/atl1e/atl1e_hw.c:372:
+       mii_autoneg_adv_reg |=3D (MII_AR_ASM_DIR | MII_AR_PAUSE);

ERROR: spaces required around that '|=' (ctx:WxV)
#1490: FILE: drivers/net/atl1e/atl1e_hw.c:372:
+       mii_autoneg_adv_reg |=3D (MII_AR_ASM_DIR | MII_AR_PAUSE);
                            ^

ERROR: spaces required around that '=' (ctx:WxV)
#1492: FILE: drivers/net/atl1e/atl1e_hw.c:374:
+       hw->mii_autoneg_adv_reg =3D mii_autoneg_adv_reg;
                                ^

ERROR: spaces required around that '=' (ctx:WxV)
#1493: FILE: drivers/net/atl1e/atl1e_hw.c:375:
+       hw->mii_1000t_ctrl_reg  =3D mii_1000t_ctrl_reg;
                                ^

ERROR: spaces required around that '=' (ctx:WxV)
#1495: FILE: drivers/net/atl1e/atl1e_hw.c:377:
+       ret_val =3D atl1e_write_phy_reg(hw, MII_ADVERTISE, mii_autoneg_adv_=
                ^

ERROR: spaces required around that '=' (ctx:VxE)
#1495: FILE: drivers/net/atl1e/atl1e_hw.c:377:
+       ret_val =3D atl1e_write_phy_reg(hw, MII_ADVERTISE, mii_autoneg_adv_=
                                                                           ^

ERROR: code indent should use tabs where possible
#1498: FILE: drivers/net/atl1e/atl1e_hw.c:379:
+               return ret_val;$

ERROR: spaces required around that '=' (ctx:WxV)
#1500: FILE: drivers/net/atl1e/atl1e_hw.c:381:
+       if (hw->nic_type =3D=3D athr_l1e || hw->nic_type =3D=3D athr_l2e_re=
                         ^

ERROR: spaces required around that '=' (ctx:VxV)
#1500: FILE: drivers/net/atl1e/atl1e_hw.c:381:
+       if (hw->nic_type =3D=3D athr_l1e || hw->nic_type =3D=3D athr_l2e_re=
                            ^

ERROR: spaces required around that '=' (ctx:WxV)
#1500: FILE: drivers/net/atl1e/atl1e_hw.c:381:
+       if (hw->nic_type =3D=3D athr_l1e || hw->nic_type =3D=3D athr_l2e_re=
                                                         ^

ERROR: spaces required around that '=' (ctx:VxV)
#1500: FILE: drivers/net/atl1e/atl1e_hw.c:381:
+       if (hw->nic_type =3D=3D athr_l1e || hw->nic_type =3D=3D athr_l2e_re=
                                                            ^

ERROR: spaces required around that '=' (ctx:VxE)
#1500: FILE: drivers/net/atl1e/atl1e_hw.c:381:
+       if (hw->nic_type =3D=3D athr_l1e || hw->nic_type =3D=3D athr_l2e_re=
                                                                           ^

ERROR: do not use assignment in if condition
#1500: FILE: drivers/net/atl1e/atl1e_hw.c:381:
+       if (hw->nic_type =3D=3D athr_l1e || hw->nic_type =3D=3D athr_l2e_re=

ERROR: code indent should use tabs where possible
#1502: FILE: drivers/net/atl1e/atl1e_hw.c:382:
+               ret_val =3D atl1e_write_phy_reg(hw, MII_AT001_CR,$

ERROR: spaces required around that '=' (ctx:WxV)
#1502: FILE: drivers/net/atl1e/atl1e_hw.c:382:
+               ret_val =3D atl1e_write_phy_reg(hw, MII_AT001_CR,
                        ^

ERROR: code indent should use tabs where possible
#1503: FILE: drivers/net/atl1e/atl1e_hw.c:383:
+                                          mii_1000t_ctrl_reg);$

ERROR: code indent should use tabs where possible
#1504: FILE: drivers/net/atl1e/atl1e_hw.c:384:
+               if (ret_val)$

ERROR: code indent should use tabs where possible
#1505: FILE: drivers/net/atl1e/atl1e_hw.c:385:
+                       return ret_val;$

WARNING: space prohibited between function name and open parenthesis '('
#1521: FILE: drivers/net/atl1e/atl1e_hw.c:401:
+       struct atl1e_adapter *adapter =3D (struct atl1e_adapter *)hw->adapt=

ERROR: spaces required around that '=' (ctx:WxV)
#1521: FILE: drivers/net/atl1e/atl1e_hw.c:401:
+       struct atl1e_adapter *adapter =3D (struct atl1e_adapter *)hw->adapt=
                                      ^

ERROR: spaces required around that '=' (ctx:VxE)
#1521: FILE: drivers/net/atl1e/atl1e_hw.c:401:
+       struct atl1e_adapter *adapter =3D (struct atl1e_adapter *)hw->adapt=
                                                                           ^

ERROR: spaces required around that '=' (ctx:WxV)
#1523: FILE: drivers/net/atl1e/atl1e_hw.c:402:
+       struct pci_dev *pdev =3D adapter->pdev;
                             ^

ERROR: spaces required around that '=' (ctx:WxV)
#1527: FILE: drivers/net/atl1e/atl1e_hw.c:406:
+       phy_data =3D MII_CR_RESET | MII_CR_AUTO_NEG_EN | MII_CR_RESTART_AUT=
                 ^

ERROR: spaces required around that '=' (ctx:VxE)
#1527: FILE: drivers/net/atl1e/atl1e_hw.c:406:
+       phy_data =3D MII_CR_RESET | MII_CR_AUTO_NEG_EN | MII_CR_RESTART_AUT=
                                                                           ^

ERROR: spaces required around that '=' (ctx:WxV)
#1530: FILE: drivers/net/atl1e/atl1e_hw.c:408:
+       ret_val =3D atl1e_write_phy_reg(hw, MII_BMCR, phy_data);
                ^

ERROR: code indent should use tabs where possible
#1532: FILE: drivers/net/atl1e/atl1e_hw.c:410:
+               u32 val;$

ERROR: code indent should use tabs where possible
#1533: FILE: drivers/net/atl1e/atl1e_hw.c:411:
+               int i;$

ERROR: code indent should use tabs where possible
#1534: FILE: drivers/net/atl1e/atl1e_hw.c:412:
+               /**************************************$

ERROR: code indent should use tabs where possible
#1535: FILE: drivers/net/atl1e/atl1e_hw.c:413:
+                * pcie serdes link may be down !$

ERROR: code indent should use tabs where possible
#1536: FILE: drivers/net/atl1e/atl1e_hw.c:414:
+                **************************************/$

ERROR: code indent should use tabs where possible
#1537: FILE: drivers/net/atl1e/atl1e_hw.c:415:
+               for (i =3D 0; i < 25; i++) {$

ERROR: spaces required around that '=' (ctx:WxV)
#1537: FILE: drivers/net/atl1e/atl1e_hw.c:415:
+               for (i =3D 0; i < 25; i++) {
                       ^

ERROR: code indent should use tabs where possible
#1538: FILE: drivers/net/atl1e/atl1e_hw.c:416:
+                       msleep(1);$

ERROR: code indent should use tabs where possible
#1539: FILE: drivers/net/atl1e/atl1e_hw.c:417:
+                       val =3D AT_READ_REG(hw, REG_MDIO_CTRL);$

ERROR: spaces required around that '=' (ctx:WxV)
#1539: FILE: drivers/net/atl1e/atl1e_hw.c:417:
+                       val =3D AT_READ_REG(hw, REG_MDIO_CTRL);
                            ^

ERROR: code indent should use tabs where possible
#1540: FILE: drivers/net/atl1e/atl1e_hw.c:418:
+                       if (!(val & (MDIO_START | MDIO_BUSY)))$

ERROR: code indent should use tabs where possible
#1541: FILE: drivers/net/atl1e/atl1e_hw.c:419:
+                               break;$

ERROR: code indent should use tabs where possible
#1542: FILE: drivers/net/atl1e/atl1e_hw.c:420:
+               }$

ERROR: code indent should use tabs where possible
#1544: FILE: drivers/net/atl1e/atl1e_hw.c:422:
+               if (0 !=3D (val & (MDIO_START | MDIO_BUSY))) {$

WARNING: space prohibited between function name and open parenthesis '('
#1544: FILE: drivers/net/atl1e/atl1e_hw.c:422:
+               if (0 !=3D (val & (MDIO_START | MDIO_BUSY))) {

ERROR: spaces required around that '!=' (ctx:WxV)
#1544: FILE: drivers/net/atl1e/atl1e_hw.c:422:
+               if (0 !=3D (val & (MDIO_START | MDIO_BUSY))) {
                      ^

ERROR: code indent should use tabs where possible
#1545: FILE: drivers/net/atl1e/atl1e_hw.c:423:
+                       dev_err(&pdev->dev,$

ERROR: code indent should use tabs where possible
#1546: FILE: drivers/net/atl1e/atl1e_hw.c:424:
+                               "pcie linkdown at least for 25ms\n");$

ERROR: code indent should use tabs where possible
#1547: FILE: drivers/net/atl1e/atl1e_hw.c:425:
+                       return ret_val;$

ERROR: code indent should use tabs where possible
#1548: FILE: drivers/net/atl1e/atl1e_hw.c:426:
+               }$

ERROR: code indent should use tabs where possible
#1550: FILE: drivers/net/atl1e/atl1e_hw.c:428:
+               dev_err(&pdev->dev, "pcie linkup after %d ms\n", i);$

WARNING: space prohibited between function name and open parenthesis '('
#1557: FILE: drivers/net/atl1e/atl1e_hw.c:435:
+       struct atl1e_adapter *adapter =3D (struct atl1e_adapter *)hw->adapt=

ERROR: spaces required around that '=' (ctx:WxV)
#1557: FILE: drivers/net/atl1e/atl1e_hw.c:435:
+       struct atl1e_adapter *adapter =3D (struct atl1e_adapter *)hw->adapt=
                                      ^

ERROR: spaces required around that '=' (ctx:VxE)
#1557: FILE: drivers/net/atl1e/atl1e_hw.c:435:
+       struct atl1e_adapter *adapter =3D (struct atl1e_adapter *)hw->adapt=
                                                                           ^

ERROR: spaces required around that '=' (ctx:WxV)
#1559: FILE: drivers/net/atl1e/atl1e_hw.c:436:
+       struct pci_dev *pdev =3D adapter->pdev;
                             ^

ERROR: code indent should use tabs where possible
#1564: FILE: drivers/net/atl1e/atl1e_hw.c:441:
+               if (hw->re_autoneg) {$

ERROR: code indent should use tabs where possible
#1565: FILE: drivers/net/atl1e/atl1e_hw.c:442:
+                       hw->re_autoneg =3D false;$

ERROR: spaces required around that '=' (ctx:WxV)
#1565: FILE: drivers/net/atl1e/atl1e_hw.c:442:
+                       hw->re_autoneg =3D false;
                                       ^

ERROR: code indent should use tabs where possible
#1566: FILE: drivers/net/atl1e/atl1e_hw.c:443:
+                       return atl1e_restart_autoneg(hw);$

ERROR: code indent should use tabs where possible
#1567: FILE: drivers/net/atl1e/atl1e_hw.c:444:
+               }$

ERROR: code indent should use tabs where possible
#1568: FILE: drivers/net/atl1e/atl1e_hw.c:445:
+               return 0;$

ERROR: code indent should use tabs where possible
#1575: FILE: drivers/net/atl1e/atl1e_hw.c:452:
+                     GPHY_CTRL_EXT_RESET);$

ERROR: spaces required around that '=' (ctx:WxV)
#1580: FILE: drivers/net/atl1e/atl1e_hw.c:457:
+       ret_val =3D atl1e_write_phy_reg(hw, MII_DBG_ADDR, 0xB);
                ^

ERROR: code indent should use tabs where possible
#1582: FILE: drivers/net/atl1e/atl1e_hw.c:459:
+               return ret_val;$

ERROR: spaces required around that '=' (ctx:WxV)
#1583: FILE: drivers/net/atl1e/atl1e_hw.c:460:
+       ret_val =3D atl1e_write_phy_reg(hw, MII_DBG_DATA, 0xBC00);
                ^

ERROR: code indent should use tabs where possible
#1585: FILE: drivers/net/atl1e/atl1e_hw.c:462:
+               return ret_val;$

ERROR: spaces required around that '=' (ctx:WxV)
#1587: FILE: drivers/net/atl1e/atl1e_hw.c:464:
+       ret_val =3D atl1e_write_phy_reg(hw, MII_DBG_ADDR, 0);
                ^

ERROR: code indent should use tabs where possible
#1589: FILE: drivers/net/atl1e/atl1e_hw.c:466:
+               return ret_val;$

ERROR: spaces required around that '=' (ctx:WxV)
#1590: FILE: drivers/net/atl1e/atl1e_hw.c:467:
+       phy_val =3D 0x02ef;
                ^

ERROR: spaces required around that '=' (ctx:WxV)
#1593: FILE: drivers/net/atl1e/atl1e_hw.c:470:
+       ret_val =3D atl1e_write_phy_reg(hw, MII_DBG_DATA, phy_val);
                ^

ERROR: code indent should use tabs where possible
#1595: FILE: drivers/net/atl1e/atl1e_hw.c:472:
+               return ret_val;$

ERROR: spaces required around that '=' (ctx:WxV)
#1597: FILE: drivers/net/atl1e/atl1e_hw.c:474:
+       ret_val =3D atl1e_write_phy_reg(hw, MII_DBG_ADDR, 0x12);
                ^

ERROR: code indent should use tabs where possible
#1599: FILE: drivers/net/atl1e/atl1e_hw.c:476:
+               return ret_val;$

ERROR: spaces required around that '=' (ctx:WxV)
#1600: FILE: drivers/net/atl1e/atl1e_hw.c:477:
+       ret_val =3D atl1e_write_phy_reg(hw, MII_DBG_DATA, 0x4C04);
                ^

ERROR: code indent should use tabs where possible
#1602: FILE: drivers/net/atl1e/atl1e_hw.c:479:
+               return ret_val;$

ERROR: spaces required around that '=' (ctx:WxV)
#1604: FILE: drivers/net/atl1e/atl1e_hw.c:481:
+       ret_val =3D atl1e_write_phy_reg(hw, MII_DBG_ADDR, 0x4);
                ^

ERROR: code indent should use tabs where possible
#1606: FILE: drivers/net/atl1e/atl1e_hw.c:483:
+               return ret_val;$

ERROR: spaces required around that '=' (ctx:WxV)
#1607: FILE: drivers/net/atl1e/atl1e_hw.c:484:
+       ret_val =3D atl1e_write_phy_reg(hw, MII_DBG_DATA, 0x8BBB);
                ^

ERROR: code indent should use tabs where possible
#1609: FILE: drivers/net/atl1e/atl1e_hw.c:486:
+               return ret_val;$

ERROR: spaces required around that '=' (ctx:WxV)
#1611: FILE: drivers/net/atl1e/atl1e_hw.c:488:
+       ret_val =3D atl1e_write_phy_reg(hw, MII_DBG_ADDR, 0x5);
                ^

ERROR: code indent should use tabs where possible
#1613: FILE: drivers/net/atl1e/atl1e_hw.c:490:
+               return ret_val;$

ERROR: spaces required around that '=' (ctx:WxV)
#1614: FILE: drivers/net/atl1e/atl1e_hw.c:491:
+       ret_val =3D atl1e_write_phy_reg(hw, MII_DBG_DATA, 0x2C46);
                ^

ERROR: code indent should use tabs where possible
#1616: FILE: drivers/net/atl1e/atl1e_hw.c:493:
+               return ret_val;$

ERROR: spaces required around that '=' (ctx:WxV)
#1621: FILE: drivers/net/atl1e/atl1e_hw.c:498:
+       ret_val =3D atl1e_write_phy_reg(hw, MII_INT_CTRL, 0xC00);
                ^

ERROR: code indent should use tabs where possible
#1623: FILE: drivers/net/atl1e/atl1e_hw.c:500:
+               dev_err(&pdev->dev, "Error enable PHY linkChange Interrupt\=$

ERROR: code indent should use tabs where possible
#1625: FILE: drivers/net/atl1e/atl1e_hw.c:501:
+               return ret_val;$

ERROR: spaces required around that '=' (ctx:WxV)
#1628: FILE: drivers/net/atl1e/atl1e_hw.c:504:
+       ret_val =3D atl1e_phy_setup_autoneg_adv(hw);
                ^

ERROR: code indent should use tabs where possible
#1630: FILE: drivers/net/atl1e/atl1e_hw.c:506:
+               dev_err(&pdev->dev, "Error Setting up Auto-Negotiation\n");$

ERROR: code indent should use tabs where possible
#1631: FILE: drivers/net/atl1e/atl1e_hw.c:507:
+               return ret_val;$

ERROR: spaces required around that '=' (ctx:WxV)
#1635: FILE: drivers/net/atl1e/atl1e_hw.c:511:
+       ret_val =3D atl1e_phy_commit(hw);
                ^

ERROR: code indent should use tabs where possible
#1637: FILE: drivers/net/atl1e/atl1e_hw.c:513:
+               dev_err(&pdev->dev, "Error Resetting the phy");$

ERROR: code indent should use tabs where possible
#1638: FILE: drivers/net/atl1e/atl1e_hw.c:514:
+               return ret_val;$

ERROR: spaces required around that '=' (ctx:WxV)
#1641: FILE: drivers/net/atl1e/atl1e_hw.c:517:
+       hw->phy_configured =3D true;
                           ^

WARNING: space prohibited between function name and open parenthesis '('
#1653: FILE: drivers/net/atl1e/atl1e_hw.c:529:
+       struct atl1e_adapter *adapter =3D (struct atl1e_adapter *)hw->adapt=

ERROR: spaces required around that '=' (ctx:WxV)
#1653: FILE: drivers/net/atl1e/atl1e_hw.c:529:
+       struct atl1e_adapter *adapter =3D (struct atl1e_adapter *)hw->adapt=
                                      ^

ERROR: spaces required around that '=' (ctx:VxE)
#1653: FILE: drivers/net/atl1e/atl1e_hw.c:529:
+       struct atl1e_adapter *adapter =3D (struct atl1e_adapter *)hw->adapt=
                                                                           ^

ERROR: spaces required around that '=' (ctx:WxV)
#1655: FILE: drivers/net/atl1e/atl1e_hw.c:530:
+       struct pci_dev *pdev =3D adapter->pdev;
                             ^

ERROR: spaces required around that '=' (ctx:WxV)
#1657: FILE: drivers/net/atl1e/atl1e_hw.c:532:
+       u32 idle_status_data =3D 0;
                             ^

ERROR: spaces required around that '=' (ctx:WxV)
#1658: FILE: drivers/net/atl1e/atl1e_hw.c:533:
+       u16 pci_cfg_cmd_word =3D 0;
                             ^

ERROR: spaces required around that '=' (ctx:WxV)
#1659: FILE: drivers/net/atl1e/atl1e_hw.c:534:
+       int timeout =3D 0;
                    ^

ERROR: code indent should use tabs where possible
#1664: FILE: drivers/net/atl1e/atl1e_hw.c:539:
+                               CMD_MEMORY_SPACE | CMD_BUS_MASTER))$

ERROR: code indent should use tabs where possible
#1665: FILE: drivers/net/atl1e/atl1e_hw.c:540:
+                       !=3D (CMD_IO_SPACE | CMD_MEMORY_SPACE | CMD_BUS_MAS=$

WARNING: space prohibited between function name and open parenthesis '('
#1665: FILE: drivers/net/atl1e/atl1e_hw.c:540:
+                       !=3D (CMD_IO_SPACE | CMD_MEMORY_SPACE | CMD_BUS_MAS=

ERROR: spaces required around that '!=' (ctx:ExV)
#1665: FILE: drivers/net/atl1e/atl1e_hw.c:540:
+                       !=3D (CMD_IO_SPACE | CMD_MEMORY_SPACE | CMD_BUS_MAS=
                        ^

ERROR: spaces required around that '=' (ctx:VxE)
#1665: FILE: drivers/net/atl1e/atl1e_hw.c:540:
+                       !=3D (CMD_IO_SPACE | CMD_MEMORY_SPACE | CMD_BUS_MAS=
                                                                           ^

ERROR: code indent should use tabs where possible
#1667: FILE: drivers/net/atl1e/atl1e_hw.c:541:
+               pci_cfg_cmd_word |=3D (CMD_IO_SPACE |$

WARNING: space prohibited between function name and open parenthesis '('
#1667: FILE: drivers/net/atl1e/atl1e_hw.c:541:
+               pci_cfg_cmd_word |=3D (CMD_IO_SPACE |

ERROR: spaces required around that '|=' (ctx:WxV)
#1667: FILE: drivers/net/atl1e/atl1e_hw.c:541:
+               pci_cfg_cmd_word |=3D (CMD_IO_SPACE |
                                 ^

ERROR: code indent should use tabs where possible
#1668: FILE: drivers/net/atl1e/atl1e_hw.c:542:
+                                    CMD_MEMORY_SPACE | CMD_BUS_MASTER);$

ERROR: code indent should use tabs where possible
#1669: FILE: drivers/net/atl1e/atl1e_hw.c:543:
+               pci_write_config_word(pdev, PCI_REG_COMMAND, pci_cfg_cmd_wo=$

ERROR: spaces required around that '=' (ctx:VxE)
#1669: FILE: drivers/net/atl1e/atl1e_hw.c:543:
+               pci_write_config_word(pdev, PCI_REG_COMMAND, pci_cfg_cmd_wo=
                                                                           ^

ERROR: code indent should use tabs where possible
#1674: FILE: drivers/net/atl1e/atl1e_hw.c:547:
+        * Issue Soft Reset to the MAC.  This will reset the chip's$

ERROR: code indent should use tabs where possible
#1675: FILE: drivers/net/atl1e/atl1e_hw.c:548:
+        * transmit, receive, DMA.  It will not effect$

ERROR: code indent should use tabs where possible
#1676: FILE: drivers/net/atl1e/atl1e_hw.c:549:
+        * the current PCI configuration.  The global reset bit is self-$

ERROR: code indent should use tabs where possible
#1677: FILE: drivers/net/atl1e/atl1e_hw.c:550:
+        * clearing, and should clear within a microsecond.$

ERROR: code indent should use tabs where possible
#1678: FILE: drivers/net/atl1e/atl1e_hw.c:551:
+        */$

ERROR: code indent should use tabs where possible
#1680: FILE: drivers/net/atl1e/atl1e_hw.c:553:
+                       MASTER_CTRL_LED_MODE | MASTER_CTRL_SOFT_RST);$

ERROR: spaces required around that '=' (ctx:WxV)
#1685: FILE: drivers/net/atl1e/atl1e_hw.c:558:
+       for (timeout =3D 0; timeout < AT_HW_MAX_IDLE_DELAY; timeout++) {
                     ^

ERROR: code indent should use tabs where possible
#1686: FILE: drivers/net/atl1e/atl1e_hw.c:559:
+               idle_status_data =3D AT_READ_REG(hw, REG_IDLE_STATUS);$

ERROR: spaces required around that '=' (ctx:WxV)
#1686: FILE: drivers/net/atl1e/atl1e_hw.c:559:
+               idle_status_data =3D AT_READ_REG(hw, REG_IDLE_STATUS);
                                 ^

ERROR: code indent should use tabs where possible
#1687: FILE: drivers/net/atl1e/atl1e_hw.c:560:
+               if (idle_status_data =3D=3D 0)$

ERROR: spaces required around that '=' (ctx:WxV)
#1687: FILE: drivers/net/atl1e/atl1e_hw.c:560:
+               if (idle_status_data =3D=3D 0)
                                     ^

ERROR: spaces required around that '=' (ctx:VxV)
#1687: FILE: drivers/net/atl1e/atl1e_hw.c:560:
+               if (idle_status_data =3D=3D 0)
                                        ^

ERROR: do not use assignment in if condition
#1687: FILE: drivers/net/atl1e/atl1e_hw.c:560:
+               if (idle_status_data =3D=3D 0)

ERROR: code indent should use tabs where possible
#1688: FILE: drivers/net/atl1e/atl1e_hw.c:561:
+                       break;$

ERROR: code indent should use tabs where possible
#1689: FILE: drivers/net/atl1e/atl1e_hw.c:562:
+               msleep(1);$

ERROR: code indent should use tabs where possible
#1690: FILE: drivers/net/atl1e/atl1e_hw.c:563:
+               cpu_relax();$

ERROR: spaces required around that '>=' (ctx:WxV)
#1693: FILE: drivers/net/atl1e/atl1e_hw.c:566:
+       if (timeout >=3D AT_HW_MAX_IDLE_DELAY) {
                    ^

ERROR: code indent should use tabs where possible
#1694: FILE: drivers/net/atl1e/atl1e_hw.c:567:
+               dev_err(&pdev->dev,$

ERROR: code indent should use tabs where possible
#1695: FILE: drivers/net/atl1e/atl1e_hw.c:568:
+                       "MAC state machine cann't be idle since"$

ERROR: code indent should use tabs where possible
#1696: FILE: drivers/net/atl1e/atl1e_hw.c:569:
+                       " disabled for 10ms second\n");$

ERROR: code indent should use tabs where possible
#1697: FILE: drivers/net/atl1e/atl1e_hw.c:570:
+               return AT_ERR_TIMEOUT;$

ERROR: spaces required around that '=' (ctx:WxV)
#1715: FILE: drivers/net/atl1e/atl1e_hw.c:588:
+       s32 ret_val =3D 0;
                    ^

ERROR: spaces required around that '=' (ctx:WxV)
#1724: FILE: drivers/net/atl1e/atl1e_hw.c:597:
+       ret_val =3D atl1e_phy_init(hw);
                ^

ERROR: spaces required around that '=' (ctx:VxE)
#1736: FILE: drivers/net/atl1e/atl1e_hw.c:609:
+int atl1e_get_speed_and_duplex(struct atl1e_hw *hw, u16 *speed, u16 *duple=
                                                                           ^

ERROR: that open brace { should be on the previous line
#1738: FILE: drivers/net/atl1e/atl1e_hw.c:610:
+int atl1e_get_speed_and_duplex(struct atl1e_hw *hw, u16 *speed, u16 *duple=
+{

ERROR: spaces required around that '=' (ctx:WxV)
#1743: FILE: drivers/net/atl1e/atl1e_hw.c:615:
+       err =3D atl1e_read_phy_reg(hw, MII_AT001_PSSR, &phy_data);
            ^

ERROR: code indent should use tabs where possible
#1745: FILE: drivers/net/atl1e/atl1e_hw.c:617:
+               return err;$

ERROR: code indent should use tabs where possible
#1748: FILE: drivers/net/atl1e/atl1e_hw.c:620:
+               return AT_ERR_PHY_RES;$

ERROR: code indent should use tabs where possible
#1752: FILE: drivers/net/atl1e/atl1e_hw.c:624:
+               *speed =3D SPEED_1000;$

ERROR: spaces required around that '=' (ctx:WxV)
#1752: FILE: drivers/net/atl1e/atl1e_hw.c:624:
+               *speed =3D SPEED_1000;
                       ^

ERROR: code indent should use tabs where possible
#1753: FILE: drivers/net/atl1e/atl1e_hw.c:625:
+               break;$

ERROR: code indent should use tabs where possible
#1755: FILE: drivers/net/atl1e/atl1e_hw.c:627:
+               *speed =3D SPEED_100;$

ERROR: spaces required around that '=' (ctx:WxV)
#1755: FILE: drivers/net/atl1e/atl1e_hw.c:627:
+               *speed =3D SPEED_100;
                       ^

ERROR: code indent should use tabs where possible
#1756: FILE: drivers/net/atl1e/atl1e_hw.c:628:
+               break;$

ERROR: code indent should use tabs where possible
#1758: FILE: drivers/net/atl1e/atl1e_hw.c:630:
+               *speed =3D SPEED_10;$

ERROR: spaces required around that '=' (ctx:WxV)
#1758: FILE: drivers/net/atl1e/atl1e_hw.c:630:
+               *speed =3D SPEED_10;
                       ^

ERROR: code indent should use tabs where possible
#1759: FILE: drivers/net/atl1e/atl1e_hw.c:631:
+               break;$

ERROR: code indent should use tabs where possible
#1761: FILE: drivers/net/atl1e/atl1e_hw.c:633:
+               return AT_ERR_PHY_SPEED;$

ERROR: code indent should use tabs where possible
#1762: FILE: drivers/net/atl1e/atl1e_hw.c:634:
+               break;$

ERROR: code indent should use tabs where possible
#1766: FILE: drivers/net/atl1e/atl1e_hw.c:638:
+               *duplex =3D FULL_DUPLEX;$

ERROR: spaces required around that '=' (ctx:WxV)
#1766: FILE: drivers/net/atl1e/atl1e_hw.c:638:
+               *duplex =3D FULL_DUPLEX;
                        ^

ERROR: code indent should use tabs where possible
#1768: FILE: drivers/net/atl1e/atl1e_hw.c:640:
+               *duplex =3D HALF_DUPLEX;$

ERROR: spaces required around that '=' (ctx:WxV)
#1768: FILE: drivers/net/atl1e/atl1e_hw.c:640:
+               *duplex =3D HALF_DUPLEX;
                        ^

ERROR: spaces required around that '=' (ctx:WxV)
#1775: FILE: drivers/net/atl1e/atl1e_hw.c:647:
+       int err =3D 0;
                ^

ERROR: spaces required around that '=' (ctx:WxV)
#1777: FILE: drivers/net/atl1e/atl1e_hw.c:649:
+       err =3D atl1e_write_phy_reg(hw, MII_ADVERTISE, hw->mii_autoneg_adv_=
            ^

ERROR: spaces required around that '=' (ctx:VxE)
#1777: FILE: drivers/net/atl1e/atl1e_hw.c:649:
+       err =3D atl1e_write_phy_reg(hw, MII_ADVERTISE, hw->mii_autoneg_adv_=
                                                                           ^

ERROR: code indent should use tabs where possible
#1780: FILE: drivers/net/atl1e/atl1e_hw.c:651:
+               return err;$

ERROR: spaces required around that '=' (ctx:WxV)
#1782: FILE: drivers/net/atl1e/atl1e_hw.c:653:
+       if (hw->nic_type =3D=3D athr_l1e || hw->nic_type =3D=3D athr_l2e_re=
                         ^

ERROR: spaces required around that '=' (ctx:VxV)
#1782: FILE: drivers/net/atl1e/atl1e_hw.c:653:
+       if (hw->nic_type =3D=3D athr_l1e || hw->nic_type =3D=3D athr_l2e_re=
                            ^

ERROR: spaces required around that '=' (ctx:WxV)
#1782: FILE: drivers/net/atl1e/atl1e_hw.c:653:
+       if (hw->nic_type =3D=3D athr_l1e || hw->nic_type =3D=3D athr_l2e_re=
                                                         ^

ERROR: spaces required around that '=' (ctx:VxV)
#1782: FILE: drivers/net/atl1e/atl1e_hw.c:653:
+       if (hw->nic_type =3D=3D athr_l1e || hw->nic_type =3D=3D athr_l2e_re=
                                                            ^

ERROR: spaces required around that '=' (ctx:VxE)
#1782: FILE: drivers/net/atl1e/atl1e_hw.c:653:
+       if (hw->nic_type =3D=3D athr_l1e || hw->nic_type =3D=3D athr_l2e_re=
                                                                           ^

ERROR: do not use assignment in if condition
#1782: FILE: drivers/net/atl1e/atl1e_hw.c:653:
+       if (hw->nic_type =3D=3D athr_l1e || hw->nic_type =3D=3D athr_l2e_re=

ERROR: code indent should use tabs where possible
#1784: FILE: drivers/net/atl1e/atl1e_hw.c:654:
+               err =3D atl1e_write_phy_reg(hw, MII_AT001_CR,$

ERROR: spaces required around that '=' (ctx:WxV)
#1784: FILE: drivers/net/atl1e/atl1e_hw.c:654:
+               err =3D atl1e_write_phy_reg(hw, MII_AT001_CR,
                    ^

ERROR: code indent should use tabs where possible
#1785: FILE: drivers/net/atl1e/atl1e_hw.c:655:
+                                      hw->mii_1000t_ctrl_reg);$

ERROR: code indent should use tabs where possible
#1786: FILE: drivers/net/atl1e/atl1e_hw.c:656:
+               if (err)$

ERROR: code indent should use tabs where possible
#1787: FILE: drivers/net/atl1e/atl1e_hw.c:657:
+                       return err;$

ERROR: spaces required around that '=' (ctx:WxV)
#1790: FILE: drivers/net/atl1e/atl1e_hw.c:660:
+       err =3D atl1e_write_phy_reg(hw, MII_BMCR,
            ^

ERROR: code indent should use tabs where possible
#1791: FILE: drivers/net/atl1e/atl1e_hw.c:661:
+                       MII_CR_RESET | MII_CR_AUTO_NEG_EN |$

ERROR: code indent should use tabs where possible
#1792: FILE: drivers/net/atl1e/atl1e_hw.c:662:
+                       MII_CR_RESTART_AUTO_NEG);$

ERROR: spaces required around that '=' (ctx:VxE)
#1842: FILE: drivers/net/atl1e/atl1e_hw.h:37:
+s32 atl1e_get_speed_and_duplex(struct atl1e_hw *hw, u16 *speed, u16 *duple=
                                                                           ^

ERROR: code indent should use tabs where possible
#2006: FILE: drivers/net/atl1e/atl1e_hw.h:200:
+               GPHY_CTRL_PHY_PLL_ON    |\$

ERROR: code indent should use tabs where possible
#2007: FILE: drivers/net/atl1e/atl1e_hw.h:201:
+               GPHY_CTRL_SEL_ANA_RST   |\$

ERROR: code indent should use tabs where possible
#2008: FILE: drivers/net/atl1e/atl1e_hw.h:202:
+               GPHY_CTRL_HIB_PULSE     |\$

ERROR: code indent should use tabs where possible
#2009: FILE: drivers/net/atl1e/atl1e_hw.h:203:
+               GPHY_CTRL_HIB_EN)$

ERROR: code indent should use tabs where possible
#2012: FILE: drivers/net/atl1e/atl1e_hw.h:206:
+               GPHY_CTRL_PHY_PLL_ON    |\$

ERROR: code indent should use tabs where possible
#2013: FILE: drivers/net/atl1e/atl1e_hw.h:207:
+               GPHY_CTRL_SEL_ANA_RST   |\$

ERROR: code indent should use tabs where possible
#2014: FILE: drivers/net/atl1e/atl1e_hw.h:208:
+               GPHY_CTRL_HIB_PULSE     |\$

ERROR: code indent should use tabs where possible
#2015: FILE: drivers/net/atl1e/atl1e_hw.h:209:
+               GPHY_CTRL_HIB_EN        |\$

ERROR: code indent should use tabs where possible
#2016: FILE: drivers/net/atl1e/atl1e_hw.h:210:
+               GPHY_CTRL_PWDOWN_HW     |\$

ERROR: code indent should use tabs where possible
#2017: FILE: drivers/net/atl1e/atl1e_hw.h:211:
+               GPHY_CTRL_PCLK_SEL_DIS  |\$

ERROR: code indent should use tabs where possible
#2018: FILE: drivers/net/atl1e/atl1e_hw.h:212:
+               GPHY_CTRL_PHY_IDDQ)$

ERROR: code indent should use tabs where possible
#2456: FILE: drivers/net/atl1e/atl1e_hw.h:591:
+               ISR_SMB         |\$

ERROR: code indent should use tabs where possible
#2457: FILE: drivers/net/atl1e/atl1e_hw.h:592:
+               ISR_TXF_UN      |\$

ERROR: code indent should use tabs where possible
#2458: FILE: drivers/net/atl1e/atl1e_hw.h:593:
+               ISR_HW_RXF_OV   |\$

ERROR: code indent should use tabs where possible
#2459: FILE: drivers/net/atl1e/atl1e_hw.h:594:
+               ISR_HOST_RXF0_OV|\$

ERROR: code indent should use tabs where possible
#2460: FILE: drivers/net/atl1e/atl1e_hw.h:595:
+               ISR_MANUAL      |\$

ERROR: code indent should use tabs where possible
#2461: FILE: drivers/net/atl1e/atl1e_hw.h:596:
+               ISR_GPHY        |\$

ERROR: code indent should use tabs where possible
#2462: FILE: drivers/net/atl1e/atl1e_hw.h:597:
+               ISR_GPHY_LPW    |\$

ERROR: code indent should use tabs where possible
#2463: FILE: drivers/net/atl1e/atl1e_hw.h:598:
+               ISR_DMAR_TO_RST |\$

ERROR: code indent should use tabs where possible
#2464: FILE: drivers/net/atl1e/atl1e_hw.h:599:
+               ISR_DMAW_TO_RST |\$

ERROR: code indent should use tabs where possible
#2465: FILE: drivers/net/atl1e/atl1e_hw.h:600:
+               ISR_PHY_LINKDOWN|\$

ERROR: code indent should use tabs where possible
#2466: FILE: drivers/net/atl1e/atl1e_hw.h:601:
+               ISR_RX_PKT      |\$

ERROR: code indent should use tabs where possible
#2467: FILE: drivers/net/atl1e/atl1e_hw.h:602:
+               ISR_TX_PKT)$

ERROR: code indent should use tabs where possible
#2699: FILE: drivers/net/atl1e/atl1e_hw.h:778:
+                                                        * 0=3DCLK125 toggl=$

ERROR: code indent should use tabs where possible
#2701: FILE: drivers/net/atl1e/atl1e_hw.h:779:
+                                                        */$

ERROR: code indent should use tabs where possible
#2709: FILE: drivers/net/atl1e/atl1e_hw.h:784:
+                                                        *  100BASE-TX/10BA=$

ERROR: code indent should use tabs where possible
#2711: FILE: drivers/net/atl1e/atl1e_hw.h:785:
+                                                        *  MDI Mode$

ERROR: code indent should use tabs where possible
#2712: FILE: drivers/net/atl1e/atl1e_hw.h:786:
+                                                        */$

ERROR: code indent should use tabs where possible
#2715: FILE: drivers/net/atl1e/atl1e_hw.h:788:
+                                                        * all speeds.$

ERROR: code indent should use tabs where possible
#2716: FILE: drivers/net/atl1e/atl1e_hw.h:789:
+                                                        */$

ERROR: space required before that '*' (ctx:OxW)
#2722: 
+/* 1=3D5-Bit interface in 100BASE-TX
  ^

ERROR: space prohibited after that '*' (ctx:OxW)
#2722: 
+/* 1=3D5-Bit interface in 100BASE-TX
  ^

ERROR: spaces required around that '=' (ctx:VxV)
#2722: 
+/* 1=3D5-Bit interface in 100BASE-TX
     ^

ERROR: spaces required around that '=' (ctx:VxV)
#2723: 
+ * 0=3DMII interface in 100BASE-TX */
     ^

ERROR: need consistent spacing around '*' (ctx:WxO)
#2723: 
+ * 0=3DMII interface in 100BASE-TX */
                                    ^

ERROR: need consistent spacing around '/' (ctx:WxO)
#2724: 
+#define MII_AT001_PSCR_SCRAMBLER_DISABLE        0x0200  /* 1=3DScrambler d=
                                                         ^

ERROR: space required before that '*' (ctx:OxW)
#2724: 
+#define MII_AT001_PSCR_SCRAMBLER_DISABLE        0x0200  /* 1=3DScrambler d=
                                                          ^

ERROR: space prohibited after that '*' (ctx:OxW)
#2724: 
+#define MII_AT001_PSCR_SCRAMBLER_DISABLE        0x0200  /* 1=3DScrambler d=
                                                          ^

ERROR: spaces required around that '=' (ctx:VxV)
#2724: 
+#define MII_AT001_PSCR_SCRAMBLER_DISABLE        0x0200  /* 1=3DScrambler d=
                                                             ^

ERROR: spaces required around that '=' (ctx:VxE)
#2724: 
+#define MII_AT001_PSCR_SCRAMBLER_DISABLE        0x0200  /* 1=3DScrambler d=
                                                                           ^

ERROR: need consistent spacing around '/' (ctx:WxO)
#2726: 
+#define MII_AT001_PSCR_FORCE_LINK_GOOD          0x0400  /* 1=3DForce link =
                                                         ^

ERROR: space required before that '*' (ctx:OxW)
#2726: 
+#define MII_AT001_PSCR_FORCE_LINK_GOOD          0x0400  /* 1=3DForce link =
                                                          ^

ERROR: space prohibited after that '*' (ctx:OxW)
#2726: 
+#define MII_AT001_PSCR_FORCE_LINK_GOOD          0x0400  /* 1=3DForce link =
                                                          ^

ERROR: spaces required around that '=' (ctx:VxV)
#2726: 
+#define MII_AT001_PSCR_FORCE_LINK_GOOD          0x0400  /* 1=3DForce link =
                                                             ^

ERROR: need consistent spacing around '/' (ctx:WxO)
#2728: 
+#define MII_AT001_PSCR_ASSERT_CRS_ON_TX         0x0800  /* 1=3DAssert CRS =
                                                         ^

ERROR: space required before that '*' (ctx:OxW)
#2728: 
+#define MII_AT001_PSCR_ASSERT_CRS_ON_TX         0x0800  /* 1=3DAssert CRS =
                                                          ^

ERROR: space prohibited after that '*' (ctx:OxW)
#2728: 
+#define MII_AT001_PSCR_ASSERT_CRS_ON_TX         0x0800  /* 1=3DAssert CRS =
                                                          ^

ERROR: spaces required around that '=' (ctx:VxV)
#2728: 
+#define MII_AT001_PSCR_ASSERT_CRS_ON_TX         0x0800  /* 1=3DAssert CRS =
                                                             ^

ERROR: space required before that '*' (ctx:OxW)
#2733: 
+/* AT001 PHY Specific Status Register */
  ^

ERROR: space prohibited after that '*' (ctx:OxW)
#2733: 
+/* AT001 PHY Specific Status Register */
  ^

ERROR: need consistent spacing around '*' (ctx:WxO)
#2733: 
+/* AT001 PHY Specific Status Register */
                                       ^

ERROR: need consistent spacing around '/' (ctx:WxO)
#2734: 
+#define MII_AT001_PSSR_SPD_DPLX_RESOLVED        0x0800  /* 1=3DSpeed & Dup=
                                                         ^

ERROR: space required before that '*' (ctx:OxW)
#2734: 
+#define MII_AT001_PSSR_SPD_DPLX_RESOLVED        0x0800  /* 1=3DSpeed & Dup=
                                                          ^

ERROR: space prohibited after that '*' (ctx:OxW)
#2734: 
+#define MII_AT001_PSSR_SPD_DPLX_RESOLVED        0x0800  /* 1=3DSpeed & Dup=
                                                          ^

ERROR: spaces required around that '=' (ctx:VxV)
#2734: 
+#define MII_AT001_PSSR_SPD_DPLX_RESOLVED        0x0800  /* 1=3DSpeed & Dup=
                                                             ^

ERROR: spaces required around that '=' (ctx:VxE)
#2734: 
+#define MII_AT001_PSSR_SPD_DPLX_RESOLVED        0x0800  /* 1=3DSpeed & Dup=
                                                                           ^

ERROR: need consistent spacing around '/' (ctx:WxO)
#2736: 
+#define MII_AT001_PSSR_DPLX                     0x2000  /* 1=3DDuplex 0=3D=
                                                         ^

ERROR: space required before that '*' (ctx:OxW)
#2736: 
+#define MII_AT001_PSSR_DPLX                     0x2000  /* 1=3DDuplex 0=3D=
                                                          ^

ERROR: space prohibited after that '*' (ctx:OxW)
#2736: 
+#define MII_AT001_PSSR_DPLX                     0x2000  /* 1=3DDuplex 0=3D=
                                                          ^

ERROR: spaces required around that '=' (ctx:VxV)
#2736: 
+#define MII_AT001_PSSR_DPLX                     0x2000  /* 1=3DDuplex 0=3D=
                                                             ^

ERROR: spaces required around that '=' (ctx:VxV)
#2736: 
+#define MII_AT001_PSSR_DPLX                     0x2000  /* 1=3DDuplex 0=3D=
                                                                        ^

ERROR: spaces required around that '=' (ctx:VxE)
#2736: 
+#define MII_AT001_PSSR_DPLX                     0x2000  /* 1=3DDuplex 0=3D=
                                                                           ^

ERROR: need consistent spacing around '/' (ctx:WxO)
#2738: 
+#define MII_AT001_PSSR_SPEED                    0xC000  /* Speed, bits 14:=
                                                         ^

ERROR: space required before that '*' (ctx:OxW)
#2738: 
+#define MII_AT001_PSSR_SPEED                    0xC000  /* Speed, bits 14:=
                                                          ^

ERROR: space prohibited after that '*' (ctx:OxW)
#2738: 
+#define MII_AT001_PSSR_SPEED                    0xC000  /* Speed, bits 14:=
                                                          ^

ERROR: spaces required around that '=' (ctx:VxE)
#2738: 
+#define MII_AT001_PSSR_SPEED                    0xC000  /* Speed, bits 14:=
                                                                           ^

ERROR: need consistent spacing around '/' (ctx:WxO)
#2740: 
+#define MII_AT001_PSSR_10MBS                    0x0000  /* 00=3D10Mbs */
                                                         ^

ERROR: space required before that '*' (ctx:OxW)
#2740: 
+#define MII_AT001_PSSR_10MBS                    0x0000  /* 00=3D10Mbs */
                                                          ^

ERROR: space prohibited after that '*' (ctx:OxW)
#2740: 
+#define MII_AT001_PSSR_10MBS                    0x0000  /* 00=3D10Mbs */
                                                          ^

ERROR: spaces required around that '=' (ctx:VxV)
#2740: 
+#define MII_AT001_PSSR_10MBS                    0x0000  /* 00=3D10Mbs */
                                                              ^

ERROR: need consistent spacing around '*' (ctx:WxO)
#2740: 
+#define MII_AT001_PSSR_10MBS                    0x0000  /* 00=3D10Mbs */
                                                                       ^

ERROR: need consistent spacing around '/' (ctx:WxO)
#2741: 
+#define MII_AT001_PSSR_100MBS                   0x4000  /* 01=3D100Mbs */
                                                         ^

ERROR: space required before that '*' (ctx:OxW)
#2741: 
+#define MII_AT001_PSSR_100MBS                   0x4000  /* 01=3D100Mbs */
                                                          ^

ERROR: space prohibited after that '*' (ctx:OxW)
#2741: 
+#define MII_AT001_PSSR_100MBS                   0x4000  /* 01=3D100Mbs */
                                                          ^

ERROR: spaces required around that '=' (ctx:VxV)
#2741: 
+#define MII_AT001_PSSR_100MBS                   0x4000  /* 01=3D100Mbs */
                                                              ^

ERROR: need consistent spacing around '*' (ctx:WxO)
#2741: 
+#define MII_AT001_PSSR_100MBS                   0x4000  /* 01=3D100Mbs */
                                                                        ^

ERROR: need consistent spacing around '/' (ctx:WxO)
#2742: 
+#define MII_AT001_PSSR_1000MBS                  0x8000  /* 10=3D1000Mbs */
                                                         ^

ERROR: space required before that '*' (ctx:OxW)
#2742: 
+#define MII_AT001_PSSR_1000MBS                  0x8000  /* 10=3D1000Mbs */
                                                          ^

ERROR: space prohibited after that '*' (ctx:OxW)
#2742: 
+#define MII_AT001_PSSR_1000MBS                  0x8000  /* 10=3D1000Mbs */
                                                          ^

ERROR: spaces required around that '=' (ctx:VxV)
#2742: 
+#define MII_AT001_PSSR_1000MBS                  0x8000  /* 10=3D1000Mbs */
                                                              ^

ERROR: need consistent spacing around '*' (ctx:WxO)
#2742: 
+#define MII_AT001_PSSR_1000MBS                  0x8000  /* 10=3D1000Mbs */
                                                                         ^

ERROR: need consistent spacing around '/' (ctx:WxO)
#2744: 
+#endif /*_ATHL1E_HW_H_*/
        ^

ERROR: space required before that '*' (ctx:OxV)
#2744: 
+#endif /*_ATHL1E_HW_H_*/
         ^

ERROR: spaces required around that '=' (ctx:WxV)
#2782: FILE: drivers/net/atl1e/atl1e_main.c:27:
+char atl1e_driver_name[] =3D "ATL1E";
                          ^

ERROR: spaces required around that '=' (ctx:WxV)
#2783: FILE: drivers/net/atl1e/atl1e_main.c:28:
+char atl1e_driver_version[] =3D DRV_VERSION;
                             ^

ERROR: spaces required around that '=' (ctx:WxV)
#2794: FILE: drivers/net/atl1e/atl1e_main.c:39:
+static struct pci_device_id atl1e_pci_tbl[] =3D {
                                             ^

ERROR: code indent should use tabs where possible
#2857: FILE: drivers/net/atl1e/atl1e_main.c:99:
+               AT_WRITE_REG(&adapter->hw, REG_ISR, 0);$

ERROR: code indent should use tabs where possible
#2858: FILE: drivers/net/atl1e/atl1e_main.c:100:
+               AT_WRITE_REG(&adapter->hw, REG_IMR, IMR_NORMAL_MASK);$

ERROR: code indent should use tabs where possible
#2859: FILE: drivers/net/atl1e/atl1e_main.c:101:
+               AT_WRITE_FLUSH(&adapter->hw);$

WARNING: space prohibited between function name and open parenthesis '('
#2893: FILE: drivers/net/atl1e/atl1e_main.c:135:
+       struct atl1e_adapter *adapter =3D (struct atl1e_adapter *) data;

ERROR: spaces required around that '=' (ctx:WxV)
#2893: FILE: drivers/net/atl1e/atl1e_main.c:135:
+       struct atl1e_adapter *adapter =3D (struct atl1e_adapter *) data;
                                      ^

ERROR: spaces required around that '=' (ctx:WxV)
#2894: FILE: drivers/net/atl1e/atl1e_main.c:136:
+       struct atl1e_hw *hw =3D &adapter->hw;
                            ^

ERROR: need consistent spacing around '&' (ctx:WxV)
#2894: FILE: drivers/net/atl1e/atl1e_main.c:136:
+       struct atl1e_hw *hw =3D &adapter->hw;
                                ^

ERROR: code indent should use tabs where possible
#2907: FILE: drivers/net/atl1e/atl1e_main.c:149:
+               msleep(1);$

ERROR: spaces required around that '=' (ctx:WxV)
#2916: FILE: drivers/net/atl1e/atl1e_main.c:158:
+       adapter =3D container_of(work, struct atl1e_adapter, reset_task);
                ^

ERROR: spaces required around that '=' (ctx:WxV)
#2923: FILE: drivers/net/atl1e/atl1e_main.c:165:
+       struct atl1e_hw *hw =3D &adapter->hw;
                            ^

ERROR: need consistent spacing around '&' (ctx:WxV)
#2923: FILE: drivers/net/atl1e/atl1e_main.c:165:
+       struct atl1e_hw *hw =3D &adapter->hw;
                                ^

ERROR: spaces required around that '=' (ctx:WxV)
#2924: FILE: drivers/net/atl1e/atl1e_main.c:166:
+       struct net_device *netdev =3D adapter->netdev;
                                  ^

ERROR: spaces required around that '=' (ctx:WxV)
#2925: FILE: drivers/net/atl1e/atl1e_main.c:167:
+       struct pci_dev    *pdev   =3D adapter->pdev;
                                  ^

ERROR: spaces required around that '=' (ctx:WxV)
#2926: FILE: drivers/net/atl1e/atl1e_main.c:168:
+       int err =3D 0;
                ^

ERROR: spaces required around that '=' (ctx:WxV)
#2932: FILE: drivers/net/atl1e/atl1e_main.c:174:
+       if ((phy_data & BMSR_LSTATUS) =3D=3D 0) {
                                      ^

ERROR: spaces required around that '=' (ctx:VxV)
#2932: FILE: drivers/net/atl1e/atl1e_main.c:174:
+       if ((phy_data & BMSR_LSTATUS) =3D=3D 0) {
                                         ^

ERROR: do not use assignment in if condition
#2932: FILE: drivers/net/atl1e/atl1e_main.c:174:
+       if ((phy_data & BMSR_LSTATUS) =3D=3D 0) {

ERROR: code indent should use tabs where possible
#2933: FILE: drivers/net/atl1e/atl1e_main.c:175:
+               /* link down */$

ERROR: code indent should use tabs where possible
#2934: FILE: drivers/net/atl1e/atl1e_main.c:176:
+               if (netif_carrier_ok(netdev)) { /* old link state: Up */$

ERROR: code indent should use tabs where possible
#2935: FILE: drivers/net/atl1e/atl1e_main.c:177:
+                       u32 value;$

ERROR: code indent should use tabs where possible
#2936: FILE: drivers/net/atl1e/atl1e_main.c:178:
+                       /* disable rx */$

ERROR: code indent should use tabs where possible
#2937: FILE: drivers/net/atl1e/atl1e_main.c:179:
+                       value =3D AT_READ_REG(hw, REG_MAC_CTRL);$

ERROR: spaces required around that '=' (ctx:WxV)
#2937: FILE: drivers/net/atl1e/atl1e_main.c:179:
+                       value =3D AT_READ_REG(hw, REG_MAC_CTRL);
                              ^

ERROR: code indent should use tabs where possible
#2938: FILE: drivers/net/atl1e/atl1e_main.c:180:
+                       value &=3D ~MAC_CTRL_RX_EN;$

ERROR: spaces required around that '&=' (ctx:WxV)
#2938: FILE: drivers/net/atl1e/atl1e_main.c:180:
+                       value &=3D ~MAC_CTRL_RX_EN;
                              ^

ERROR: code indent should use tabs where possible
#2939: FILE: drivers/net/atl1e/atl1e_main.c:181:
+                       AT_WRITE_REG(hw, REG_MAC_CTRL, value);$

ERROR: code indent should use tabs where possible
#2940: FILE: drivers/net/atl1e/atl1e_main.c:182:
+                       adapter->link_speed =3D SPEED_0;$

ERROR: spaces required around that '=' (ctx:WxV)
#2940: FILE: drivers/net/atl1e/atl1e_main.c:182:
+                       adapter->link_speed =3D SPEED_0;
                                            ^

ERROR: code indent should use tabs where possible
#2941: FILE: drivers/net/atl1e/atl1e_main.c:183:
+                       netif_carrier_off(netdev);$

ERROR: code indent should use tabs where possible
#2942: FILE: drivers/net/atl1e/atl1e_main.c:184:
+                       netif_stop_queue(netdev);$

ERROR: code indent should use tabs where possible
#2943: FILE: drivers/net/atl1e/atl1e_main.c:185:
+               }$

ERROR: code indent should use tabs where possible
#2945: FILE: drivers/net/atl1e/atl1e_main.c:187:
+               /* Link Up */$

ERROR: code indent should use tabs where possible
#2946: FILE: drivers/net/atl1e/atl1e_main.c:188:
+               err =3D atl1e_get_speed_and_duplex(hw, &speed, &duplex);$

ERROR: spaces required around that '=' (ctx:WxV)
#2946: FILE: drivers/net/atl1e/atl1e_main.c:188:
+               err =3D atl1e_get_speed_and_duplex(hw, &speed, &duplex);
                    ^

ERROR: code indent should use tabs where possible
#2947: FILE: drivers/net/atl1e/atl1e_main.c:189:
+               if (unlikely(err))$

ERROR: code indent should use tabs where possible
#2948: FILE: drivers/net/atl1e/atl1e_main.c:190:
+                       return err;$

ERROR: code indent should use tabs where possible
#2950: FILE: drivers/net/atl1e/atl1e_main.c:192:
+               /* link result is our setting */$

ERROR: code indent should use tabs where possible
#2951: FILE: drivers/net/atl1e/atl1e_main.c:193:
+               if (adapter->link_speed !=3D speed ||$

ERROR: spaces required around that '!=' (ctx:WxV)
#2951: FILE: drivers/net/atl1e/atl1e_main.c:193:
+               if (adapter->link_speed !=3D speed ||
                                        ^

ERROR: code indent should use tabs where possible
#2952: FILE: drivers/net/atl1e/atl1e_main.c:194:
+                   adapter->link_duplex !=3D duplex) {$

ERROR: spaces required around that '!=' (ctx:WxV)
#2952: FILE: drivers/net/atl1e/atl1e_main.c:194:
+                   adapter->link_duplex !=3D duplex) {
                                         ^

ERROR: code indent should use tabs where possible
#2953: FILE: drivers/net/atl1e/atl1e_main.c:195:
+                       adapter->link_speed  =3D speed;$

ERROR: spaces required around that '=' (ctx:WxV)
#2953: FILE: drivers/net/atl1e/atl1e_main.c:195:
+                       adapter->link_speed  =3D speed;
                                             ^

ERROR: code indent should use tabs where possible
#2954: FILE: drivers/net/atl1e/atl1e_main.c:196:
+                       adapter->link_duplex =3D duplex;$

ERROR: spaces required around that '=' (ctx:WxV)
#2954: FILE: drivers/net/atl1e/atl1e_main.c:196:
+                       adapter->link_duplex =3D duplex;
                                             ^

ERROR: code indent should use tabs where possible
#2955: FILE: drivers/net/atl1e/atl1e_main.c:197:
+                       atl1e_setup_mac_ctrl(adapter);$

ERROR: code indent should use tabs where possible
#2956: FILE: drivers/net/atl1e/atl1e_main.c:198:
+                       dev_info(&pdev->dev,$

ERROR: code indent should use tabs where possible
#2957: FILE: drivers/net/atl1e/atl1e_main.c:199:
+                               "%s: %s NIC Link is Up<%d Mbps %s>\n",$

ERROR: code indent should use tabs where possible
#2958: FILE: drivers/net/atl1e/atl1e_main.c:200:
+                               atl1e_driver_name, netdev->name,$

ERROR: code indent should use tabs where possible
#2959: FILE: drivers/net/atl1e/atl1e_main.c:201:
+                               adapter->link_speed,$

ERROR: code indent should use tabs where possible
#2960: FILE: drivers/net/atl1e/atl1e_main.c:202:
+                               adapter->link_duplex =3D=3D FULL_DUPLEX ?$

ERROR: spaces required around that '=' (ctx:WxV)
#2960: FILE: drivers/net/atl1e/atl1e_main.c:202:
+                               adapter->link_duplex =3D=3D FULL_DUPLEX ?
                                                     ^

ERROR: spaces required around that '=' (ctx:VxV)
#2960: FILE: drivers/net/atl1e/atl1e_main.c:202:
+                               adapter->link_duplex =3D=3D FULL_DUPLEX ?
                                                        ^

ERROR: code indent should use tabs where possible
#2961: FILE: drivers/net/atl1e/atl1e_main.c:203:
+                               "Full Duplex" : "Half Duplex");$

ERROR: code indent should use tabs where possible
#2962: FILE: drivers/net/atl1e/atl1e_main.c:204:
+               }$

ERROR: code indent should use tabs where possible
#2964: FILE: drivers/net/atl1e/atl1e_main.c:206:
+               if (!netif_carrier_ok(netdev)) {$

ERROR: code indent should use tabs where possible
#2965: FILE: drivers/net/atl1e/atl1e_main.c:207:
+                       /* Link down -> Up */$

ERROR: code indent should use tabs where possible
#2966: FILE: drivers/net/atl1e/atl1e_main.c:208:
+                       netif_carrier_on(netdev);$

ERROR: code indent should use tabs where possible
#2967: FILE: drivers/net/atl1e/atl1e_main.c:209:
+                       netif_wake_queue(netdev);$

ERROR: code indent should use tabs where possible
#2968: FILE: drivers/net/atl1e/atl1e_main.c:210:
+               }$

ERROR: spaces required around that '=' (ctx:WxV)
#2983: FILE: drivers/net/atl1e/atl1e_main.c:224:
+       adapter =3D container_of(work, struct atl1e_adapter, link_chg_task)=
                ^

ERROR: spaces required around that '=' (ctx:VxE)
#2983: FILE: drivers/net/atl1e/atl1e_main.c:224:
+       adapter =3D container_of(work, struct atl1e_adapter, link_chg_task)=
                                                                           ^

ERROR: spaces required around that '=' (ctx:WxV)
#2992: FILE: drivers/net/atl1e/atl1e_main.c:232:
+       struct net_device *netdev =3D adapter->netdev;
                                  ^

ERROR: spaces required around that '=' (ctx:WxV)
#2993: FILE: drivers/net/atl1e/atl1e_main.c:233:
+       struct pci_dev    *pdev   =3D adapter->pdev;
                                  ^

ERROR: spaces required around that '=' (ctx:WxV)
#2994: FILE: drivers/net/atl1e/atl1e_main.c:234:
+       u16 phy_data =3D 0;
                     ^

ERROR: spaces required around that '=' (ctx:WxV)
#2995: FILE: drivers/net/atl1e/atl1e_main.c:235:
+       u16 link_up =3D 0;
                    ^

ERROR: spaces required around that '=' (ctx:WxV)
#3001: FILE: drivers/net/atl1e/atl1e_main.c:241:
+       link_up =3D phy_data & BMSR_LSTATUS;
                ^

ERROR: code indent should use tabs where possible
#3004: FILE: drivers/net/atl1e/atl1e_main.c:244:
+               if (netif_carrier_ok(netdev)) {$

ERROR: code indent should use tabs where possible
#3005: FILE: drivers/net/atl1e/atl1e_main.c:245:
+                       /* old link state: Up */$

ERROR: code indent should use tabs where possible
#3006: FILE: drivers/net/atl1e/atl1e_main.c:246:
+                       dev_info(&pdev->dev, "%s: %s NIC Link is Down\n",$

ERROR: code indent should use tabs where possible
#3007: FILE: drivers/net/atl1e/atl1e_main.c:247:
+                                       atl1e_driver_name, netdev->name);$

ERROR: code indent should use tabs where possible
#3008: FILE: drivers/net/atl1e/atl1e_main.c:248:
+                       adapter->link_speed =3D SPEED_0;$

ERROR: spaces required around that '=' (ctx:WxV)
#3008: FILE: drivers/net/atl1e/atl1e_main.c:248:
+                       adapter->link_speed =3D SPEED_0;
                                            ^

ERROR: code indent should use tabs where possible
#3009: FILE: drivers/net/atl1e/atl1e_main.c:249:
+                       netif_stop_queue(netdev);$

ERROR: code indent should use tabs where possible
#3010: FILE: drivers/net/atl1e/atl1e_main.c:250:
+               }$

ERROR: spaces required around that '=' (ctx:WxV)
#3032: FILE: drivers/net/atl1e/atl1e_main.c:272:
+       struct atl1e_adapter *adapter =3D netdev_priv(netdev);
                                      ^

ERROR: spaces required around that '=' (ctx:WxV)
#3049: FILE: drivers/net/atl1e/atl1e_main.c:289:
+       struct atl1e_adapter *adapter =3D netdev_priv(netdev);
                                      ^

ERROR: spaces required around that '=' (ctx:WxV)
#3050: FILE: drivers/net/atl1e/atl1e_main.c:290:
+       struct atl1e_hw *hw =3D &adapter->hw;
                            ^

ERROR: need consistent spacing around '&' (ctx:WxV)
#3050: FILE: drivers/net/atl1e/atl1e_main.c:290:
+       struct atl1e_hw *hw =3D &adapter->hw;
                                ^

ERROR: spaces required around that '=' (ctx:WxV)
#3052: FILE: drivers/net/atl1e/atl1e_main.c:292:
+       u32 mac_ctrl_data =3D 0;
                          ^

ERROR: spaces required around that '=' (ctx:WxV)
#3056: FILE: drivers/net/atl1e/atl1e_main.c:296:
+       mac_ctrl_data =3D AT_READ_REG(hw, REG_MAC_CTRL);
                      ^

ERROR: code indent should use tabs where possible
#3059: FILE: drivers/net/atl1e/atl1e_main.c:299:
+               mac_ctrl_data |=3D MAC_CTRL_PROMIS_EN;$

ERROR: spaces required around that '|=' (ctx:WxV)
#3059: FILE: drivers/net/atl1e/atl1e_main.c:299:
+               mac_ctrl_data |=3D MAC_CTRL_PROMIS_EN;
                              ^

ERROR: code indent should use tabs where possible
#3061: FILE: drivers/net/atl1e/atl1e_main.c:301:
+               mac_ctrl_data |=3D MAC_CTRL_MC_ALL_EN;$

ERROR: spaces required around that '|=' (ctx:WxV)
#3061: FILE: drivers/net/atl1e/atl1e_main.c:301:
+               mac_ctrl_data |=3D MAC_CTRL_MC_ALL_EN;
                              ^

ERROR: code indent should use tabs where possible
#3062: FILE: drivers/net/atl1e/atl1e_main.c:302:
+               mac_ctrl_data &=3D ~MAC_CTRL_PROMIS_EN;$

ERROR: spaces required around that '&=' (ctx:WxV)
#3062: FILE: drivers/net/atl1e/atl1e_main.c:302:
+               mac_ctrl_data &=3D ~MAC_CTRL_PROMIS_EN;
                              ^

ERROR: code indent should use tabs where possible
#3064: FILE: drivers/net/atl1e/atl1e_main.c:304:
+               mac_ctrl_data &=3D ~(MAC_CTRL_PROMIS_EN | MAC_CTRL_MC_ALL_E=$

ERROR: spaces required around that '&=' (ctx:WxV)
#3064: FILE: drivers/net/atl1e/atl1e_main.c:304:
+               mac_ctrl_data &=3D ~(MAC_CTRL_PROMIS_EN | MAC_CTRL_MC_ALL_E=
                              ^

ERROR: spaces required around that '=' (ctx:VxE)
#3064: FILE: drivers/net/atl1e/atl1e_main.c:304:
+               mac_ctrl_data &=3D ~(MAC_CTRL_PROMIS_EN | MAC_CTRL_MC_ALL_E=
                                                                           ^

ERROR: spaces required around that '=' (ctx:WxV)
#3075: FILE: drivers/net/atl1e/atl1e_main.c:314:
+       for (mc_ptr =3D netdev->mc_list; mc_ptr; mc_ptr =3D mc_ptr->next) {
                    ^

ERROR: spaces required around that '=' (ctx:WxV)
#3075: FILE: drivers/net/atl1e/atl1e_main.c:314:
+       for (mc_ptr =3D netdev->mc_list; mc_ptr; mc_ptr =3D mc_ptr->next) {
                                                        ^

ERROR: code indent should use tabs where possible
#3076: FILE: drivers/net/atl1e/atl1e_main.c:315:
+               hash_value =3D atl1e_hash_mc_addr(hw, mc_ptr->dmi_addr);$

ERROR: spaces required around that '=' (ctx:WxV)
#3076: FILE: drivers/net/atl1e/atl1e_main.c:315:
+               hash_value =3D atl1e_hash_mc_addr(hw, mc_ptr->dmi_addr);
                           ^

ERROR: code indent should use tabs where possible
#3077: FILE: drivers/net/atl1e/atl1e_main.c:316:
+               atl1e_hash_set(hw, hash_value);$

ERROR: code indent should use tabs where possible
#3082: FILE: drivers/net/atl1e/atl1e_main.c:321:
+                                  struct vlan_group *grp)$

ERROR: spaces required around that '=' (ctx:WxV)
#3084: FILE: drivers/net/atl1e/atl1e_main.c:323:
+       struct atl1e_adapter *adapter =3D netdev_priv(netdev);
                                      ^

ERROR: spaces required around that '=' (ctx:WxV)
#3085: FILE: drivers/net/atl1e/atl1e_main.c:324:
+       struct pci_dev *pdev =3D adapter->pdev;
                             ^

ERROR: spaces required around that '=' (ctx:WxV)
#3086: FILE: drivers/net/atl1e/atl1e_main.c:325:
+       u32 mac_ctrl_data =3D 0;
                          ^

ERROR: spaces required around that '=' (ctx:WxV)
#3092: FILE: drivers/net/atl1e/atl1e_main.c:331:
+       adapter->vlgrp =3D grp;
                       ^

ERROR: spaces required around that '=' (ctx:WxV)
#3093: FILE: drivers/net/atl1e/atl1e_main.c:332:
+       mac_ctrl_data =3D AT_READ_REG(&adapter->hw, REG_MAC_CTRL);
                      ^

ERROR: code indent should use tabs where possible
#3096: FILE: drivers/net/atl1e/atl1e_main.c:335:
+               /* enable VLAN tag insert/strip */$

ERROR: code indent should use tabs where possible
#3097: FILE: drivers/net/atl1e/atl1e_main.c:336:
+               mac_ctrl_data |=3D MAC_CTRL_RMV_VLAN;$

ERROR: spaces required around that '|=' (ctx:WxV)
#3097: FILE: drivers/net/atl1e/atl1e_main.c:336:
+               mac_ctrl_data |=3D MAC_CTRL_RMV_VLAN;
                              ^

ERROR: code indent should use tabs where possible
#3099: FILE: drivers/net/atl1e/atl1e_main.c:338:
+               /* disable VLAN tag insert/strip */$

ERROR: code indent should use tabs where possible
#3100: FILE: drivers/net/atl1e/atl1e_main.c:339:
+               mac_ctrl_data &=3D ~MAC_CTRL_RMV_VLAN;$

ERROR: spaces required around that '&=' (ctx:WxV)
#3100: FILE: drivers/net/atl1e/atl1e_main.c:339:
+               mac_ctrl_data &=3D ~MAC_CTRL_RMV_VLAN;
                              ^

ERROR: spaces required around that '=' (ctx:WxV)
#3109: FILE: drivers/net/atl1e/atl1e_main.c:348:
+       struct pci_dev *pdev =3D adapter->pdev;
                             ^

ERROR: spaces required around that '=' (ctx:WxV)
#3123: FILE: drivers/net/atl1e/atl1e_main.c:362:
+       struct atl1e_adapter *adapter =3D netdev_priv(netdev);
                                      ^

ERROR: spaces required around that '=' (ctx:WxV)
#3124: FILE: drivers/net/atl1e/atl1e_main.c:363:
+       struct sockaddr *addr =3D p;
                              ^

ERROR: code indent should use tabs where possible
#3127: FILE: drivers/net/atl1e/atl1e_main.c:366:
+               return -EADDRNOTAVAIL;$

ERROR: code indent should use tabs where possible
#3130: FILE: drivers/net/atl1e/atl1e_main.c:369:
+               return -EBUSY;$

ERROR: spaces required around that '=' (ctx:WxV)
#3149: FILE: drivers/net/atl1e/atl1e_main.c:388:
+       struct atl1e_adapter *adapter =3D netdev_priv(netdev);
                                      ^

ERROR: spaces required around that '=' (ctx:WxV)
#3150: FILE: drivers/net/atl1e/atl1e_main.c:389:
+       int old_mtu   =3D netdev->mtu;
                      ^

ERROR: spaces required around that '=' (ctx:WxV)
#3151: FILE: drivers/net/atl1e/atl1e_main.c:390:
+       int max_frame =3D new_mtu + ETH_HLEN + ETH_FCS_LEN + VLAN_HLEN;
                      ^

ERROR: code indent should use tabs where possible
#3154: FILE: drivers/net/atl1e/atl1e_main.c:393:
+                       (max_frame > MAX_JUMBO_FRAME_SIZE)) {$

ERROR: code indent should use tabs where possible
#3155: FILE: drivers/net/atl1e/atl1e_main.c:394:
+               dev_warn(&adapter->pdev->dev, "invalid MTU setting\n");$

ERROR: code indent should use tabs where possible
#3156: FILE: drivers/net/atl1e/atl1e_main.c:395:
+               return -EINVAL;$

ERROR: spaces required around that '!=' (ctx:WxV)
#3159: FILE: drivers/net/atl1e/atl1e_main.c:398:
+       if (old_mtu !=3D new_mtu && netif_running(netdev)) {
                    ^

ERROR: code indent should use tabs where possible
#3160: FILE: drivers/net/atl1e/atl1e_main.c:399:
+               while (test_and_set_bit(__AT_RESETTING, &adapter->flags))$

ERROR: code indent should use tabs where possible
#3161: FILE: drivers/net/atl1e/atl1e_main.c:400:
+                       msleep(1);$

ERROR: code indent should use tabs where possible
#3162: FILE: drivers/net/atl1e/atl1e_main.c:401:
+               netdev->mtu =3D new_mtu;$

ERROR: spaces required around that '=' (ctx:WxV)
#3162: FILE: drivers/net/atl1e/atl1e_main.c:401:
+               netdev->mtu =3D new_mtu;
                            ^

ERROR: code indent should use tabs where possible
#3163: FILE: drivers/net/atl1e/atl1e_main.c:402:
+               adapter->hw.max_frame_size =3D new_mtu;$

ERROR: spaces required around that '=' (ctx:WxV)
#3163: FILE: drivers/net/atl1e/atl1e_main.c:402:
+               adapter->hw.max_frame_size =3D new_mtu;
                                           ^

ERROR: code indent should use tabs where possible
#3164: FILE: drivers/net/atl1e/atl1e_main.c:403:
+               adapter->hw.rx_jumbo_th =3D (max_frame + 7) >> 3;$

WARNING: space prohibited between function name and open parenthesis '('
#3164: FILE: drivers/net/atl1e/atl1e_main.c:403:
+               adapter->hw.rx_jumbo_th =3D (max_frame + 7) >> 3;

ERROR: spaces required around that '=' (ctx:WxV)
#3164: FILE: drivers/net/atl1e/atl1e_main.c:403:
+               adapter->hw.rx_jumbo_th =3D (max_frame + 7) >> 3;
                                        ^

ERROR: code indent should use tabs where possible
#3165: FILE: drivers/net/atl1e/atl1e_main.c:404:
+               atl1e_down(adapter);$

ERROR: code indent should use tabs where possible
#3166: FILE: drivers/net/atl1e/atl1e_main.c:405:
+               atl1e_up(adapter);$

ERROR: code indent should use tabs where possible
#3167: FILE: drivers/net/atl1e/atl1e_main.c:406:
+               clear_bit(__AT_RESETTING, &adapter->flags);$

ERROR: spaces required around that '=' (ctx:VxE)
#3175: FILE: drivers/net/atl1e/atl1e_main.c:414:
+static int atl1e_mdio_read(struct net_device *netdev, int phy_id, int reg_=
                                                                           ^

ERROR: that open brace { should be on the previous line
#3177: FILE: drivers/net/atl1e/atl1e_main.c:415:
+static int atl1e_mdio_read(struct net_device *netdev, int phy_id, int reg_=
+{

ERROR: spaces required around that '=' (ctx:WxV)
#3178: FILE: drivers/net/atl1e/atl1e_main.c:416:
+       struct atl1e_adapter *adapter =3D netdev_priv(netdev);
                                      ^

ERROR: spaces required around that '=' (ctx:VxE)
#3181: FILE: drivers/net/atl1e/atl1e_main.c:419:
+       atl1e_read_phy_reg(&adapter->hw, reg_num & MDIO_REG_ADDR_MASK, &res=
                                                                           ^

ERROR: code indent should use tabs where possible
#3187: FILE: drivers/net/atl1e/atl1e_main.c:424:
+                            int reg_num, int val)$

ERROR: spaces required around that '=' (ctx:WxV)
#3189: FILE: drivers/net/atl1e/atl1e_main.c:426:
+       struct atl1e_adapter *adapter =3D netdev_priv(netdev);
                                      ^

ERROR: spaces required around that '=' (ctx:VxE)
#3191: FILE: drivers/net/atl1e/atl1e_main.c:428:
+       atl1e_write_phy_reg(&adapter->hw, reg_num & MDIO_REG_ADDR_MASK, val=
                                                                           ^

ERROR: code indent should use tabs where possible
#3202: FILE: drivers/net/atl1e/atl1e_main.c:438:
+                          struct ifreq *ifr, int cmd)$

ERROR: spaces required around that '=' (ctx:WxV)
#3204: FILE: drivers/net/atl1e/atl1e_main.c:440:
+       struct atl1e_adapter *adapter =3D netdev_priv(netdev);
                                      ^

ERROR: spaces required around that '=' (ctx:WxV)
#3205: FILE: drivers/net/atl1e/atl1e_main.c:441:
+       struct pci_dev *pdev =3D adapter->pdev;
                             ^

ERROR: spaces required around that '=' (ctx:WxV)
#3206: FILE: drivers/net/atl1e/atl1e_main.c:442:
+       struct mii_ioctl_data *data =3D if_mii(ifr);
                                    ^

ERROR: spaces required around that '=' (ctx:WxV)
#3208: FILE: drivers/net/atl1e/atl1e_main.c:444:
+       int retval =3D 0;
                   ^

ERROR: code indent should use tabs where possible
#3211: FILE: drivers/net/atl1e/atl1e_main.c:447:
+               return -EINVAL;$

ERROR: code indent should use tabs where possible
#3216: FILE: drivers/net/atl1e/atl1e_main.c:452:
+               data->phy_id =3D 0;$

ERROR: spaces required around that '=' (ctx:WxV)
#3216: FILE: drivers/net/atl1e/atl1e_main.c:452:
+               data->phy_id =3D 0;
                             ^

ERROR: code indent should use tabs where possible
#3217: FILE: drivers/net/atl1e/atl1e_main.c:453:
+               break;$

ERROR: code indent should use tabs where possible
#3220: FILE: drivers/net/atl1e/atl1e_main.c:456:
+               if (!capable(CAP_NET_ADMIN)) {$

ERROR: code indent should use tabs where possible
#3221: FILE: drivers/net/atl1e/atl1e_main.c:457:
+                       retval =3D -EPERM;$

ERROR: spaces required around that '=' (ctx:WxV)
#3221: FILE: drivers/net/atl1e/atl1e_main.c:457:
+                       retval =3D -EPERM;
                               ^

ERROR: need consistent spacing around '-' (ctx:WxV)
#3221: FILE: drivers/net/atl1e/atl1e_main.c:457:
+                       retval =3D -EPERM;
                                   ^

ERROR: code indent should use tabs where possible
#3222: FILE: drivers/net/atl1e/atl1e_main.c:458:
+                       goto out;$

ERROR: code indent should use tabs where possible
#3223: FILE: drivers/net/atl1e/atl1e_main.c:459:
+               }$

ERROR: code indent should use tabs where possible
#3224: FILE: drivers/net/atl1e/atl1e_main.c:460:
+               if (atl1e_read_phy_reg(&adapter->hw, data->reg_num & 0x1F,$

ERROR: code indent should use tabs where possible
#3225: FILE: drivers/net/atl1e/atl1e_main.c:461:
+                                   &data->val_out)) {$

ERROR: code indent should use tabs where possible
#3226: FILE: drivers/net/atl1e/atl1e_main.c:462:
+                       retval =3D -EIO;$

ERROR: spaces required around that '=' (ctx:WxV)
#3226: FILE: drivers/net/atl1e/atl1e_main.c:462:
+                       retval =3D -EIO;
                               ^

ERROR: need consistent spacing around '-' (ctx:WxV)
#3226: FILE: drivers/net/atl1e/atl1e_main.c:462:
+                       retval =3D -EIO;
                                   ^

ERROR: code indent should use tabs where possible
#3227: FILE: drivers/net/atl1e/atl1e_main.c:463:
+                       goto out;$

ERROR: code indent should use tabs where possible
#3228: FILE: drivers/net/atl1e/atl1e_main.c:464:
+               }$

ERROR: code indent should use tabs where possible
#3229: FILE: drivers/net/atl1e/atl1e_main.c:465:
+               break;$

ERROR: code indent should use tabs where possible
#3232: FILE: drivers/net/atl1e/atl1e_main.c:468:
+               if (!capable(CAP_NET_ADMIN)) {$

ERROR: code indent should use tabs where possible
#3233: FILE: drivers/net/atl1e/atl1e_main.c:469:
+                       retval =3D -EPERM;$

ERROR: spaces required around that '=' (ctx:WxV)
#3233: FILE: drivers/net/atl1e/atl1e_main.c:469:
+                       retval =3D -EPERM;
                               ^

ERROR: need consistent spacing around '-' (ctx:WxV)
#3233: FILE: drivers/net/atl1e/atl1e_main.c:469:
+                       retval =3D -EPERM;
                                   ^

ERROR: code indent should use tabs where possible
#3234: FILE: drivers/net/atl1e/atl1e_main.c:470:
+                       goto out;$

ERROR: code indent should use tabs where possible
#3235: FILE: drivers/net/atl1e/atl1e_main.c:471:
+               }$

ERROR: code indent should use tabs where possible
#3236: FILE: drivers/net/atl1e/atl1e_main.c:472:
+               if (data->reg_num & ~(0x1F)) {$

ERROR: code indent should use tabs where possible
#3237: FILE: drivers/net/atl1e/atl1e_main.c:473:
+                       retval =3D -EFAULT;$

ERROR: spaces required around that '=' (ctx:WxV)
#3237: FILE: drivers/net/atl1e/atl1e_main.c:473:
+                       retval =3D -EFAULT;
                               ^

ERROR: need consistent spacing around '-' (ctx:WxV)
#3237: FILE: drivers/net/atl1e/atl1e_main.c:473:
+                       retval =3D -EFAULT;
                                   ^

ERROR: code indent should use tabs where possible
#3238: FILE: drivers/net/atl1e/atl1e_main.c:474:
+                       goto out;$

ERROR: code indent should use tabs where possible
#3239: FILE: drivers/net/atl1e/atl1e_main.c:475:
+               }$

ERROR: code indent should use tabs where possible
#3241: FILE: drivers/net/atl1e/atl1e_main.c:477:
+               dev_dbg(&pdev->dev, "<atl1e_mii_ioctl> write %x %x",$

ERROR: code indent should use tabs where possible
#3242: FILE: drivers/net/atl1e/atl1e_main.c:478:
+                               data->reg_num, data->val_in);$

ERROR: code indent should use tabs where possible
#3243: FILE: drivers/net/atl1e/atl1e_main.c:479:
+               if (atl1e_write_phy_reg(&adapter->hw,$

ERROR: code indent should use tabs where possible
#3244: FILE: drivers/net/atl1e/atl1e_main.c:480:
+                                    data->reg_num, data->val_in)) {$

ERROR: code indent should use tabs where possible
#3245: FILE: drivers/net/atl1e/atl1e_main.c:481:
+                       retval =3D -EIO;$

ERROR: spaces required around that '=' (ctx:WxV)
#3245: FILE: drivers/net/atl1e/atl1e_main.c:481:
+                       retval =3D -EIO;
                               ^

ERROR: need consistent spacing around '-' (ctx:WxV)
#3245: FILE: drivers/net/atl1e/atl1e_main.c:481:
+                       retval =3D -EIO;
                                   ^

ERROR: code indent should use tabs where possible
#3246: FILE: drivers/net/atl1e/atl1e_main.c:482:
+                       goto out;$

ERROR: code indent should use tabs where possible
#3247: FILE: drivers/net/atl1e/atl1e_main.c:483:
+               }$

ERROR: code indent should use tabs where possible
#3248: FILE: drivers/net/atl1e/atl1e_main.c:484:
+               break;$

ERROR: code indent should use tabs where possible
#3251: FILE: drivers/net/atl1e/atl1e_main.c:487:
+               retval =3D -EOPNOTSUPP;$

ERROR: spaces required around that '=' (ctx:WxV)
#3251: FILE: drivers/net/atl1e/atl1e_main.c:487:
+               retval =3D -EOPNOTSUPP;
                       ^

ERROR: need consistent spacing around '-' (ctx:WxV)
#3251: FILE: drivers/net/atl1e/atl1e_main.c:487:
+               retval =3D -EOPNOTSUPP;
                           ^

ERROR: code indent should use tabs where possible
#3252: FILE: drivers/net/atl1e/atl1e_main.c:488:
+               break;$

ERROR: spaces required around that '=' (ctx:VxE)
#3266: FILE: drivers/net/atl1e/atl1e_main.c:502:
+static int atl1e_ioctl(struct net_device *netdev, struct ifreq *ifr, int c=
                                                                           ^

ERROR: that open brace { should be on the previous line
#3268: FILE: drivers/net/atl1e/atl1e_main.c:503:
+static int atl1e_ioctl(struct net_device *netdev, struct ifreq *ifr, int c=
+{

ERROR: code indent should use tabs where possible
#3273: FILE: drivers/net/atl1e/atl1e_main.c:508:
+               return atl1e_mii_ioctl(netdev, ifr, cmd);$

ERROR: code indent should use tabs where possible
#3275: FILE: drivers/net/atl1e/atl1e_main.c:510:
+               return -EOPNOTSUPP;$

ERROR: spaces required around that '&=' (ctx:WxV)
#3284: FILE: drivers/net/atl1e/atl1e_main.c:519:
+       cmd &=3D ~(PCI_COMMAND_INTX_DISABLE | PCI_COMMAND_IO);
            ^

WARNING: space prohibited between function name and open parenthesis '('
#3285: FILE: drivers/net/atl1e/atl1e_main.c:520:
+       cmd |=3D  (PCI_COMMAND_MEMORY | PCI_COMMAND_MASTER);

ERROR: spaces required around that '|=' (ctx:WxV)
#3285: FILE: drivers/net/atl1e/atl1e_main.c:520:
+       cmd |=3D  (PCI_COMMAND_MEMORY | PCI_COMMAND_MASTER);
            ^

ERROR: code indent should use tabs where possible
#3289: FILE: drivers/net/atl1e/atl1e_main.c:524:
+        * some motherboards BIOS(PXE/EFI) driver may set PME$

ERROR: code indent should use tabs where possible
#3290: FILE: drivers/net/atl1e/atl1e_main.c:525:
+        * while they transfer control to OS (Windows/Linux)$

ERROR: code indent should use tabs where possible
#3291: FILE: drivers/net/atl1e/atl1e_main.c:526:
+        * so we should clear this bit before NIC work normally$

ERROR: code indent should use tabs where possible
#3292: FILE: drivers/net/atl1e/atl1e_main.c:527:
+        */$

ERROR: spaces required around that '=' (ctx:WxV)
#3318: FILE: drivers/net/atl1e/atl1e_main.c:552:
+       struct atl1e_hw *hw   =3D &adapter->hw;
                              ^

ERROR: need consistent spacing around '&' (ctx:WxV)
#3318: FILE: drivers/net/atl1e/atl1e_main.c:552:
+       struct atl1e_hw *hw   =3D &adapter->hw;
                                  ^

ERROR: spaces required around that '=' (ctx:WxV)
#3319: FILE: drivers/net/atl1e/atl1e_main.c:553:
+       struct pci_dev  *pdev =3D adapter->pdev;
                              ^

ERROR: spaces required around that '=' (ctx:WxV)
#3320: FILE: drivers/net/atl1e/atl1e_main.c:554:
+       u32 phy_status_data =3D 0;
                            ^

ERROR: spaces required around that '=' (ctx:WxV)
#3322: FILE: drivers/net/atl1e/atl1e_main.c:556:
+       adapter->wol =3D 0;
                     ^

ERROR: spaces required around that '=' (ctx:WxV)
#3323: FILE: drivers/net/atl1e/atl1e_main.c:557:
+       adapter->link_speed =3D SPEED_0;   /* hardware init */
                            ^

ERROR: spaces required around that '=' (ctx:WxV)
#3324: FILE: drivers/net/atl1e/atl1e_main.c:558:
+       adapter->link_duplex =3D FULL_DUPLEX;
                             ^

ERROR: spaces required around that '=' (ctx:WxV)
#3325: FILE: drivers/net/atl1e/atl1e_main.c:559:
+       adapter->num_rx_queues =3D 1;
                               ^

ERROR: spaces required around that '=' (ctx:WxV)
#3328: FILE: drivers/net/atl1e/atl1e_main.c:562:
+       hw->vendor_id =3D pdev->vendor;
                      ^

ERROR: spaces required around that '=' (ctx:WxV)
#3329: FILE: drivers/net/atl1e/atl1e_main.c:563:
+       hw->device_id =3D pdev->device;
                      ^

ERROR: spaces required around that '=' (ctx:WxV)
#3330: FILE: drivers/net/atl1e/atl1e_main.c:564:
+       hw->subsystem_vendor_id =3D pdev->subsystem_vendor;
                                ^

ERROR: spaces required around that '=' (ctx:WxV)
#3331: FILE: drivers/net/atl1e/atl1e_main.c:565:
+       hw->subsystem_id =3D pdev->subsystem_device;
                         ^

ERROR: spaces required around that '=' (ctx:WxV)
#3336: FILE: drivers/net/atl1e/atl1e_main.c:570:
+       phy_status_data =3D AT_READ_REG(hw, REG_PHY_STATUS);
                        ^

ERROR: spaces required around that '>=' (ctx:WxV)
#3338: FILE: drivers/net/atl1e/atl1e_main.c:572:
+       if (hw->revision_id >=3D 0xF0) {
                            ^

ERROR: code indent should use tabs where possible
#3339: FILE: drivers/net/atl1e/atl1e_main.c:573:
+               hw->nic_type =3D athr_l2e_revB;$

ERROR: spaces required around that '=' (ctx:WxV)
#3339: FILE: drivers/net/atl1e/atl1e_main.c:573:
+               hw->nic_type =3D athr_l2e_revB;
                             ^

ERROR: code indent should use tabs where possible
#3341: FILE: drivers/net/atl1e/atl1e_main.c:575:
+               if (phy_status_data & PHY_STATUS_100M)$

ERROR: code indent should use tabs where possible
#3342: FILE: drivers/net/atl1e/atl1e_main.c:576:
+                       hw->nic_type =3D athr_l1e;$

ERROR: spaces required around that '=' (ctx:WxV)
#3342: FILE: drivers/net/atl1e/atl1e_main.c:576:
+                       hw->nic_type =3D athr_l1e;
                                     ^

ERROR: code indent should use tabs where possible
#3343: FILE: drivers/net/atl1e/atl1e_main.c:577:
+               else$

ERROR: code indent should use tabs where possible
#3344: FILE: drivers/net/atl1e/atl1e_main.c:578:
+                       hw->nic_type =3D athr_l2e_revA;$

ERROR: spaces required around that '=' (ctx:WxV)
#3344: FILE: drivers/net/atl1e/atl1e_main.c:578:
+                       hw->nic_type =3D athr_l2e_revA;
                                     ^

ERROR: spaces required around that '=' (ctx:WxV)
#3347: FILE: drivers/net/atl1e/atl1e_main.c:581:
+       phy_status_data =3D AT_READ_REG(hw, REG_PHY_STATUS);
                        ^

ERROR: code indent should use tabs where possible
#3350: FILE: drivers/net/atl1e/atl1e_main.c:584:
+               hw->emi_ca =3D true;$

ERROR: spaces required around that '=' (ctx:WxV)
#3350: FILE: drivers/net/atl1e/atl1e_main.c:584:
+               hw->emi_ca =3D true;
                           ^

ERROR: code indent should use tabs where possible
#3352: FILE: drivers/net/atl1e/atl1e_main.c:586:
+               hw->emi_ca =3D false;$

ERROR: spaces required around that '=' (ctx:WxV)
#3352: FILE: drivers/net/atl1e/atl1e_main.c:586:
+               hw->emi_ca =3D false;
                           ^

ERROR: spaces required around that '=' (ctx:WxV)
#3354: FILE: drivers/net/atl1e/atl1e_main.c:588:
+       hw->phy_configured =3D false;
                           ^

ERROR: spaces required around that '=' (ctx:WxV)
#3355: FILE: drivers/net/atl1e/atl1e_main.c:589:
+       hw->preamble_len =3D 7;
                         ^

ERROR: spaces required around that '=' (ctx:WxV)
#3356: FILE: drivers/net/atl1e/atl1e_main.c:590:
+       hw->max_frame_size =3D adapter->netdev->mtu;
                           ^

WARNING: space prohibited between function name and open parenthesis '('
#3357: FILE: drivers/net/atl1e/atl1e_main.c:591:
+       hw->rx_jumbo_th =3D (hw->max_frame_size + ETH_HLEN +

ERROR: spaces required around that '=' (ctx:WxV)
#3357: FILE: drivers/net/atl1e/atl1e_main.c:591:
+       hw->rx_jumbo_th =3D (hw->max_frame_size + ETH_HLEN +
                        ^

ERROR: code indent should use tabs where possible
#3358: FILE: drivers/net/atl1e/atl1e_main.c:592:
+                               VLAN_HLEN + ETH_FCS_LEN + 7) >> 3;$

ERROR: spaces required around that '=' (ctx:WxV)
#3360: FILE: drivers/net/atl1e/atl1e_main.c:594:
+       hw->rrs_type =3D atl1e_rrs_disable;
                     ^

ERROR: spaces required around that '=' (ctx:WxV)
#3361: FILE: drivers/net/atl1e/atl1e_main.c:595:
+       hw->indirect_tab =3D 0;
                         ^

ERROR: spaces required around that '=' (ctx:WxV)
#3362: FILE: drivers/net/atl1e/atl1e_main.c:596:
+       hw->base_cpu =3D 0;
                     ^

ERROR: spaces required around that '=' (ctx:WxV)
#3366: FILE: drivers/net/atl1e/atl1e_main.c:600:
+       hw->ict =3D 50000;                 /* 100ms */
                ^

ERROR: spaces required around that '=' (ctx:WxV)
#3367: FILE: drivers/net/atl1e/atl1e_main.c:601:
+       hw->smb_timer =3D 200000;          /* 200ms  */
                      ^

ERROR: spaces required around that '=' (ctx:WxV)
#3368: FILE: drivers/net/atl1e/atl1e_main.c:602:
+       hw->tpd_burst =3D 5;
                      ^

ERROR: spaces required around that '=' (ctx:WxV)
#3369: FILE: drivers/net/atl1e/atl1e_main.c:603:
+       hw->rrd_thresh =3D 1;
                       ^

ERROR: spaces required around that '=' (ctx:WxV)
#3370: FILE: drivers/net/atl1e/atl1e_main.c:604:
+       hw->tpd_thresh =3D adapter->tx_ring.count / 2;
                       ^

ERROR: spaces required around that '=' (ctx:WxV)
#3371: FILE: drivers/net/atl1e/atl1e_main.c:605:
+       hw->rx_count_down =3D 4;  /* 2us resolution */
                          ^

ERROR: "foo * bar" should be "foo *bar"
#3372: FILE: drivers/net/atl1e/atl1e_main.c:606:
+       hw->tx_count_down =3D hw->imt * 4 / 3;

ERROR: spaces required around that '=' (ctx:WxV)
#3372: FILE: drivers/net/atl1e/atl1e_main.c:606:
+       hw->tx_count_down =3D hw->imt * 4 / 3;
                          ^

ERROR: spaces required around that '=' (ctx:WxV)
#3373: FILE: drivers/net/atl1e/atl1e_main.c:607:
+       hw->dmar_block =3D atl1e_dma_req_1024;
                       ^

ERROR: spaces required around that '=' (ctx:WxV)
#3374: FILE: drivers/net/atl1e/atl1e_main.c:608:
+       hw->dmaw_block =3D atl1e_dma_req_1024;
                       ^

ERROR: spaces required around that '=' (ctx:WxV)
#3375: FILE: drivers/net/atl1e/atl1e_main.c:609:
+       hw->dmar_dly_cnt =3D 15;
                         ^

ERROR: spaces required around that '=' (ctx:WxV)
#3376: FILE: drivers/net/atl1e/atl1e_main.c:610:
+       hw->dmaw_dly_cnt =3D 4;
                         ^

ERROR: code indent should use tabs where possible
#3379: FILE: drivers/net/atl1e/atl1e_main.c:613:
+               dev_err(&pdev->dev, "Unable to allocate memory for queues\n=$

ERROR: code indent should use tabs where possible
#3381: FILE: drivers/net/atl1e/atl1e_main.c:614:
+               return -ENOMEM;$

WARNING: space prohibited between function name and open parenthesis '('
#3399: FILE: drivers/net/atl1e/atl1e_main.c:632:
+       struct atl1e_tx_ring *tx_ring =3D (struct atl1e_tx_ring *)

ERROR: spaces required around that '=' (ctx:WxV)
#3399: FILE: drivers/net/atl1e/atl1e_main.c:632:
+       struct atl1e_tx_ring *tx_ring =3D (struct atl1e_tx_ring *)
                                      ^

ERROR: code indent should use tabs where possible
#3400: FILE: drivers/net/atl1e/atl1e_main.c:633:
+                               &adapter->tx_ring;$

ERROR: spaces required around that '=' (ctx:WxV)
#3401: FILE: drivers/net/atl1e/atl1e_main.c:634:
+       struct atl1e_tx_buffer *tx_buffer =3D NULL;
                                          ^

ERROR: spaces required around that '=' (ctx:WxV)
#3402: FILE: drivers/net/atl1e/atl1e_main.c:635:
+       struct pci_dev *pdev =3D adapter->pdev;
                             ^

ERROR: spaces required around that '=' (ctx:WxV)
#3405: FILE: drivers/net/atl1e/atl1e_main.c:638:
+       if (tx_ring->desc =3D=3D NULL || tx_ring->tx_buffer =3D=3D NULL)
                          ^

ERROR: spaces required around that '=' (ctx:VxV)
#3405: FILE: drivers/net/atl1e/atl1e_main.c:638:
+       if (tx_ring->desc =3D=3D NULL || tx_ring->tx_buffer =3D=3D NULL)
                             ^

ERROR: spaces required around that '=' (ctx:WxV)
#3405: FILE: drivers/net/atl1e/atl1e_main.c:638:
+       if (tx_ring->desc =3D=3D NULL || tx_ring->tx_buffer =3D=3D NULL)
                                                            ^

ERROR: spaces required around that '=' (ctx:VxV)
#3405: FILE: drivers/net/atl1e/atl1e_main.c:638:
+       if (tx_ring->desc =3D=3D NULL || tx_ring->tx_buffer =3D=3D NULL)
                                                               ^

ERROR: do not use assignment in if condition
#3405: FILE: drivers/net/atl1e/atl1e_main.c:638:
+       if (tx_ring->desc =3D=3D NULL || tx_ring->tx_buffer =3D=3D NULL)

ERROR: code indent should use tabs where possible
#3406: FILE: drivers/net/atl1e/atl1e_main.c:639:
+               return;$

ERROR: spaces required around that '=' (ctx:WxV)
#3408: FILE: drivers/net/atl1e/atl1e_main.c:641:
+       ring_count =3D tx_ring->count;
                   ^

ERROR: spaces required around that '=' (ctx:WxV)
#3410: FILE: drivers/net/atl1e/atl1e_main.c:643:
+       for (index =3D 0; index < ring_count; index++) {
                   ^

ERROR: code indent should use tabs where possible
#3411: FILE: drivers/net/atl1e/atl1e_main.c:644:
+               tx_buffer =3D &tx_ring->tx_buffer[index];$

ERROR: spaces required around that '=' (ctx:WxV)
#3411: FILE: drivers/net/atl1e/atl1e_main.c:644:
+               tx_buffer =3D &tx_ring->tx_buffer[index];
                          ^

ERROR: need consistent spacing around '&' (ctx:WxV)
#3411: FILE: drivers/net/atl1e/atl1e_main.c:644:
+               tx_buffer =3D &tx_ring->tx_buffer[index];
                              ^

ERROR: code indent should use tabs where possible
#3412: FILE: drivers/net/atl1e/atl1e_main.c:645:
+               if (tx_buffer->dma) {$

ERROR: code indent should use tabs where possible
#3413: FILE: drivers/net/atl1e/atl1e_main.c:646:
+                       pci_unmap_page(pdev, tx_buffer->dma,$

ERROR: code indent should use tabs where possible
#3414: FILE: drivers/net/atl1e/atl1e_main.c:647:
+                                       tx_buffer->length, PCI_DMA_TODEVICE=$

ERROR: spaces required around that '=' (ctx:VxE)
#3414: FILE: drivers/net/atl1e/atl1e_main.c:647:
+                                       tx_buffer->length, PCI_DMA_TODEVICE=
                                                                           ^

ERROR: code indent should use tabs where possible
#3416: FILE: drivers/net/atl1e/atl1e_main.c:648:
+                       tx_buffer->dma =3D 0;$

ERROR: spaces required around that '=' (ctx:WxV)
#3416: FILE: drivers/net/atl1e/atl1e_main.c:648:
+                       tx_buffer->dma =3D 0;
                                       ^

ERROR: code indent should use tabs where possible
#3417: FILE: drivers/net/atl1e/atl1e_main.c:649:
+               }$

ERROR: spaces required around that '=' (ctx:WxV)
#3420: FILE: drivers/net/atl1e/atl1e_main.c:652:
+       for (index =3D 0; index < ring_count; index++) {
                   ^

ERROR: code indent should use tabs where possible
#3421: FILE: drivers/net/atl1e/atl1e_main.c:653:
+               tx_buffer =3D &tx_ring->tx_buffer[index];$

ERROR: spaces required around that '=' (ctx:WxV)
#3421: FILE: drivers/net/atl1e/atl1e_main.c:653:
+               tx_buffer =3D &tx_ring->tx_buffer[index];
                          ^

ERROR: need consistent spacing around '&' (ctx:WxV)
#3421: FILE: drivers/net/atl1e/atl1e_main.c:653:
+               tx_buffer =3D &tx_ring->tx_buffer[index];
                              ^

ERROR: code indent should use tabs where possible
#3422: FILE: drivers/net/atl1e/atl1e_main.c:654:
+               if (tx_buffer->skb) {$

ERROR: code indent should use tabs where possible
#3423: FILE: drivers/net/atl1e/atl1e_main.c:655:
+                       dev_kfree_skb_any(tx_buffer->skb);$

ERROR: code indent should use tabs where possible
#3424: FILE: drivers/net/atl1e/atl1e_main.c:656:
+                       tx_buffer->skb =3D NULL;$

ERROR: spaces required around that '=' (ctx:WxV)
#3424: FILE: drivers/net/atl1e/atl1e_main.c:656:
+                       tx_buffer->skb =3D NULL;
                                       ^

ERROR: code indent should use tabs where possible
#3425: FILE: drivers/net/atl1e/atl1e_main.c:657:
+               }$

ERROR: code indent should use tabs where possible
#3429: FILE: drivers/net/atl1e/atl1e_main.c:661:
+                               ring_count);$

ERROR: code indent should use tabs where possible
#3431: FILE: drivers/net/atl1e/atl1e_main.c:663:
+                               ring_count);$

ERROR: spaces required around that '=' (ctx:WxV)
#3440: FILE: drivers/net/atl1e/atl1e_main.c:672:
+       struct atl1e_rx_ring *rx_ring =3D
                                      ^

ERROR: code indent should use tabs where possible
#3441: FILE: drivers/net/atl1e/atl1e_main.c:673:
+               (struct atl1e_rx_ring *)&adapter->rx_ring;$

ERROR: spaces required around that '=' (ctx:WxV)
#3442: FILE: drivers/net/atl1e/atl1e_main.c:674:
+       struct atl1e_rx_page_desc *rx_page_desc =3D rx_ring->rx_page_desc;
                                                ^

ERROR: spaces required around that '=' (ctx:WxV)
#3446: FILE: drivers/net/atl1e/atl1e_main.c:678:
+       if (adapter->ring_vir_addr =3D=3D NULL)
                                   ^

ERROR: spaces required around that '=' (ctx:VxV)
#3446: FILE: drivers/net/atl1e/atl1e_main.c:678:
+       if (adapter->ring_vir_addr =3D=3D NULL)
                                      ^

ERROR: do not use assignment in if condition
#3446: FILE: drivers/net/atl1e/atl1e_main.c:678:
+       if (adapter->ring_vir_addr =3D=3D NULL)

ERROR: code indent should use tabs where possible
#3447: FILE: drivers/net/atl1e/atl1e_main.c:679:
+               return;$

ERROR: spaces required around that '=' (ctx:WxV)
#3449: FILE: drivers/net/atl1e/atl1e_main.c:681:
+       for (i =3D 0; i < adapter->num_rx_queues; i++) {
               ^

ERROR: code indent should use tabs where possible
#3450: FILE: drivers/net/atl1e/atl1e_main.c:682:
+               for (j =3D 0; j < AT_PAGE_NUM_PER_QUEUE; j++) {$

ERROR: spaces required around that '=' (ctx:WxV)
#3450: FILE: drivers/net/atl1e/atl1e_main.c:682:
+               for (j =3D 0; j < AT_PAGE_NUM_PER_QUEUE; j++) {
                       ^

ERROR: code indent should use tabs where possible
#3451: FILE: drivers/net/atl1e/atl1e_main.c:683:
+                       if (rx_page_desc[i].rx_page[j].addr !=3D NULL) {$

ERROR: spaces required around that '!=' (ctx:WxV)
#3451: FILE: drivers/net/atl1e/atl1e_main.c:683:
+                       if (rx_page_desc[i].rx_page[j].addr !=3D NULL) {
                                                            ^

ERROR: code indent should use tabs where possible
#3452: FILE: drivers/net/atl1e/atl1e_main.c:684:
+                               memset(rx_page_desc[i].rx_page[j].addr, 0,$

ERROR: code indent should use tabs where possible
#3453: FILE: drivers/net/atl1e/atl1e_main.c:685:
+                                               rx_ring->real_page_size);$

ERROR: code indent should use tabs where possible
#3454: FILE: drivers/net/atl1e/atl1e_main.c:686:
+                       }$

ERROR: code indent should use tabs where possible
#3455: FILE: drivers/net/atl1e/atl1e_main.c:687:
+               }$

ERROR: spaces required around that '=' (ctx:VxE)
#3459: FILE: drivers/net/atl1e/atl1e_main.c:691:
+static void atl1e_cal_ring_size(struct atl1e_adapter *adapter, u32 *ring_s=
                                                                           ^

ERROR: that open brace { should be on the previous line
#3461: FILE: drivers/net/atl1e/atl1e_main.c:692:
+static void atl1e_cal_ring_size(struct atl1e_adapter *adapter, u32 *ring_s=
+{

WARNING: space prohibited between function name and open parenthesis '('
#3462: FILE: drivers/net/atl1e/atl1e_main.c:693:
+       *ring_size =3D ((u32)(adapter->tx_ring.count *

ERROR: spaces required around that '=' (ctx:WxV)
#3462: FILE: drivers/net/atl1e/atl1e_main.c:693:
+       *ring_size =3D ((u32)(adapter->tx_ring.count *
                   ^

ERROR: code indent should use tabs where possible
#3463: FILE: drivers/net/atl1e/atl1e_main.c:694:
+                    sizeof(struct atl1e_tpd_desc) + 7$

ERROR: code indent should use tabs where possible
#3464: FILE: drivers/net/atl1e/atl1e_main.c:695:
+                       /* tx ring, qword align */$

ERROR: code indent should use tabs where possible
#3465: FILE: drivers/net/atl1e/atl1e_main.c:696:
+                    + adapter->rx_ring.real_page_size * AT_PAGE_NUM_PER_QU=$

ERROR: "foo * bar" should be "foo *bar"
#3465: FILE: drivers/net/atl1e/atl1e_main.c:696:
+                    + adapter->rx_ring.real_page_size * AT_PAGE_NUM_PER_QU=

ERROR: spaces required around that '=' (ctx:VxE)
#3465: FILE: drivers/net/atl1e/atl1e_main.c:696:
+                    + adapter->rx_ring.real_page_size * AT_PAGE_NUM_PER_QU=
                                                                           ^

ERROR: code indent should use tabs where possible
#3467: FILE: drivers/net/atl1e/atl1e_main.c:697:
+                       adapter->num_rx_queues + 31$

ERROR: code indent should use tabs where possible
#3468: FILE: drivers/net/atl1e/atl1e_main.c:698:
+                       /* rx ring,  32 bytes align */$

ERROR: code indent should use tabs where possible
#3469: FILE: drivers/net/atl1e/atl1e_main.c:699:
+                    + (1 + AT_PAGE_NUM_PER_QUEUE * adapter->num_rx_queues)=$

ERROR: "foo * bar" should be "foo *bar"
#3469: FILE: drivers/net/atl1e/atl1e_main.c:699:
+                    + (1 + AT_PAGE_NUM_PER_QUEUE * adapter->num_rx_queues)=

ERROR: spaces required around that '=' (ctx:VxE)
#3469: FILE: drivers/net/atl1e/atl1e_main.c:699:
+                    + (1 + AT_PAGE_NUM_PER_QUEUE * adapter->num_rx_queues)=
                                                                           ^

ERROR: code indent should use tabs where possible
#3471: FILE: drivers/net/atl1e/atl1e_main.c:701:
+                       sizeof(u32) + 3));$

ERROR: code indent should use tabs where possible
#3472: FILE: drivers/net/atl1e/atl1e_main.c:702:
+                       /* tx, rx cmd, dword align   */$

ERROR: spaces required around that '=' (ctx:WxV)
#3477: FILE: drivers/net/atl1e/atl1e_main.c:707:
+       struct atl1e_tx_ring *tx_ring =3D NULL;
                                      ^

ERROR: spaces required around that '=' (ctx:WxV)
#3478: FILE: drivers/net/atl1e/atl1e_main.c:708:
+       struct atl1e_rx_ring *rx_ring =3D NULL;
                                      ^

ERROR: spaces required around that '=' (ctx:WxV)
#3480: FILE: drivers/net/atl1e/atl1e_main.c:710:
+       tx_ring =3D &adapter->tx_ring;
                ^

ERROR: need consistent spacing around '&' (ctx:WxV)
#3480: FILE: drivers/net/atl1e/atl1e_main.c:710:
+       tx_ring =3D &adapter->tx_ring;
                    ^

ERROR: spaces required around that '=' (ctx:WxV)
#3481: FILE: drivers/net/atl1e/atl1e_main.c:711:
+       rx_ring =3D &adapter->rx_ring;
                ^

ERROR: need consistent spacing around '&' (ctx:WxV)
#3481: FILE: drivers/net/atl1e/atl1e_main.c:711:
+       rx_ring =3D &adapter->rx_ring;
                    ^

ERROR: spaces required around that '=' (ctx:WxV)
#3483: FILE: drivers/net/atl1e/atl1e_main.c:713:
+       rx_ring->real_page_size =3D adapter->rx_ring.page_size
                                ^

ERROR: code indent should use tabs where possible
#3484: FILE: drivers/net/atl1e/atl1e_main.c:714:
+                                + adapter->hw.max_frame_size$

ERROR: code indent should use tabs where possible
#3485: FILE: drivers/net/atl1e/atl1e_main.c:715:
+                                + ETH_HLEN + VLAN_HLEN$

ERROR: code indent should use tabs where possible
#3486: FILE: drivers/net/atl1e/atl1e_main.c:716:
+                                + ETH_FCS_LEN;$

ERROR: spaces required around that '=' (ctx:WxV)
#3487: FILE: drivers/net/atl1e/atl1e_main.c:717:
+       rx_ring->real_page_size =3D roundup(rx_ring->real_page_size, 32);
                                ^

ERROR: spaces required around that '=' (ctx:WxV)
#3490: FILE: drivers/net/atl1e/atl1e_main.c:720:
+       adapter->ring_vir_addr =3D NULL;
                               ^

ERROR: spaces required around that '=' (ctx:WxV)
#3491: FILE: drivers/net/atl1e/atl1e_main.c:721:
+       adapter->rx_ring.desc =3D NULL;
                              ^

ERROR: spaces required around that '=' (ctx:WxV)
#3502: FILE: drivers/net/atl1e/atl1e_main.c:732:
+       struct atl1e_tx_ring *tx_ring =3D NULL;
                                      ^

ERROR: spaces required around that '=' (ctx:WxV)
#3503: FILE: drivers/net/atl1e/atl1e_main.c:733:
+       struct atl1e_rx_ring *rx_ring =3D NULL;
                                      ^

ERROR: spaces required around that '=' (ctx:WxV)
#3504: FILE: drivers/net/atl1e/atl1e_main.c:734:
+       struct atl1e_rx_page_desc *rx_page_desc =3D NULL;
                                                ^

ERROR: spaces required around that '=' (ctx:WxV)
#3507: FILE: drivers/net/atl1e/atl1e_main.c:737:
+       tx_ring =3D &adapter->tx_ring;
                ^

ERROR: need consistent spacing around '&' (ctx:WxV)
#3507: FILE: drivers/net/atl1e/atl1e_main.c:737:
+       tx_ring =3D &adapter->tx_ring;
                    ^

ERROR: spaces required around that '=' (ctx:WxV)
#3508: FILE: drivers/net/atl1e/atl1e_main.c:738:
+       rx_ring =3D &adapter->rx_ring;
                ^

ERROR: need consistent spacing around '&' (ctx:WxV)
#3508: FILE: drivers/net/atl1e/atl1e_main.c:738:
+       rx_ring =3D &adapter->rx_ring;
                    ^

ERROR: spaces required around that '=' (ctx:WxV)
#3509: FILE: drivers/net/atl1e/atl1e_main.c:739:
+       rx_page_desc =3D rx_ring->rx_page_desc;
                     ^

ERROR: spaces required around that '=' (ctx:WxV)
#3511: FILE: drivers/net/atl1e/atl1e_main.c:741:
+       tx_ring->next_to_use =3D 0;
                             ^

ERROR: spaces required around that '=' (ctx:WxV)
#3514: FILE: drivers/net/atl1e/atl1e_main.c:744:
+       for (i =3D 0; i < adapter->num_rx_queues; i++) {
               ^

ERROR: code indent should use tabs where possible
#3515: FILE: drivers/net/atl1e/atl1e_main.c:745:
+               rx_page_desc[i].rx_using  =3D 0;$

ERROR: spaces required around that '=' (ctx:WxV)
#3515: FILE: drivers/net/atl1e/atl1e_main.c:745:
+               rx_page_desc[i].rx_using  =3D 0;
                                          ^

ERROR: code indent should use tabs where possible
#3516: FILE: drivers/net/atl1e/atl1e_main.c:746:
+               rx_page_desc[i].rx_nxseq =3D 0;$

ERROR: spaces required around that '=' (ctx:WxV)
#3516: FILE: drivers/net/atl1e/atl1e_main.c:746:
+               rx_page_desc[i].rx_nxseq =3D 0;
                                         ^

ERROR: code indent should use tabs where possible
#3517: FILE: drivers/net/atl1e/atl1e_main.c:747:
+               for (j =3D 0; j < AT_PAGE_NUM_PER_QUEUE; j++) {$

ERROR: spaces required around that '=' (ctx:WxV)
#3517: FILE: drivers/net/atl1e/atl1e_main.c:747:
+               for (j =3D 0; j < AT_PAGE_NUM_PER_QUEUE; j++) {
                       ^

ERROR: code indent should use tabs where possible
#3518: FILE: drivers/net/atl1e/atl1e_main.c:748:
+                       *rx_page_desc[i].rx_page[j].write_offset_addr =3D 0=$

ERROR: spaces required around that '=' (ctx:WxV)
#3518: FILE: drivers/net/atl1e/atl1e_main.c:748:
+                       *rx_page_desc[i].rx_page[j].write_offset_addr =3D 0=
                                                                      ^

ERROR: spaces required around that '=' (ctx:VxE)
#3518: FILE: drivers/net/atl1e/atl1e_main.c:748:
+                       *rx_page_desc[i].rx_page[j].write_offset_addr =3D 0=
                                                                           ^

ERROR: code indent should use tabs where possible
#3520: FILE: drivers/net/atl1e/atl1e_main.c:749:
+                       rx_page_desc[i].rx_page[j].read_offset =3D 0;$

ERROR: spaces required around that '=' (ctx:WxV)
#3520: FILE: drivers/net/atl1e/atl1e_main.c:749:
+                       rx_page_desc[i].rx_page[j].read_offset =3D 0;
                                                               ^

ERROR: code indent should use tabs where possible
#3521: FILE: drivers/net/atl1e/atl1e_main.c:750:
+               }$

ERROR: spaces required around that '=' (ctx:WxV)
#3533: FILE: drivers/net/atl1e/atl1e_main.c:762:
+       struct pci_dev *pdev =3D adapter->pdev;
                             ^

ERROR: code indent should use tabs where possible
#3539: FILE: drivers/net/atl1e/atl1e_main.c:768:
+               pci_free_consistent(pdev, adapter->ring_size,$

ERROR: code indent should use tabs where possible
#3540: FILE: drivers/net/atl1e/atl1e_main.c:769:
+                               adapter->ring_vir_addr, adapter->ring_dma);$

ERROR: code indent should use tabs where possible
#3541: FILE: drivers/net/atl1e/atl1e_main.c:770:
+               adapter->ring_vir_addr =3D NULL;$

ERROR: spaces required around that '=' (ctx:WxV)
#3541: FILE: drivers/net/atl1e/atl1e_main.c:770:
+               adapter->ring_vir_addr =3D NULL;
                                       ^

ERROR: code indent should use tabs where possible
#3545: FILE: drivers/net/atl1e/atl1e_main.c:774:
+               kfree(adapter->tx_ring.tx_buffer);$

WARNING: kfree(NULL) is safe this check is probabally not required
#3545: FILE: drivers/net/atl1e/atl1e_main.c:774:
+       if (adapter->tx_ring.tx_buffer) {
+               kfree(adapter->tx_ring.tx_buffer);

ERROR: code indent should use tabs where possible
#3546: FILE: drivers/net/atl1e/atl1e_main.c:775:
+               adapter->tx_ring.tx_buffer =3D NULL;$

ERROR: spaces required around that '=' (ctx:WxV)
#3546: FILE: drivers/net/atl1e/atl1e_main.c:775:
+               adapter->tx_ring.tx_buffer =3D NULL;
                                           ^

ERROR: spaces required around that '=' (ctx:WxV)
#3558: FILE: drivers/net/atl1e/atl1e_main.c:787:
+       struct pci_dev *pdev =3D adapter->pdev;
                             ^

ERROR: spaces required around that '=' (ctx:WxV)
#3563: FILE: drivers/net/atl1e/atl1e_main.c:792:
+       u32 offset =3D 0;
                   ^

ERROR: spaces required around that '=' (ctx:WxV)
#3564: FILE: drivers/net/atl1e/atl1e_main.c:793:
+       int err =3D 0;
                ^

ERROR: spaces required around that '!=' (ctx:WxV)
#3566: FILE: drivers/net/atl1e/atl1e_main.c:795:
+       if (adapter->ring_vir_addr !=3D NULL)
                                   ^

ERROR: code indent should use tabs where possible
#3567: FILE: drivers/net/atl1e/atl1e_main.c:796:
+               return 0; /* alloced already */$

ERROR: spaces required around that '=' (ctx:WxV)
#3569: FILE: drivers/net/atl1e/atl1e_main.c:798:
+       tx_ring =3D &adapter->tx_ring;
                ^

ERROR: need consistent spacing around '&' (ctx:WxV)
#3569: FILE: drivers/net/atl1e/atl1e_main.c:798:
+       tx_ring =3D &adapter->tx_ring;
                    ^

ERROR: spaces required around that '=' (ctx:WxV)
#3570: FILE: drivers/net/atl1e/atl1e_main.c:799:
+       rx_ring =3D &adapter->rx_ring;
                ^

ERROR: need consistent spacing around '&' (ctx:WxV)
#3570: FILE: drivers/net/atl1e/atl1e_main.c:799:
+       rx_ring =3D &adapter->rx_ring;
                    ^

ERROR: spaces required around that '=' (ctx:WxV)
#3574: FILE: drivers/net/atl1e/atl1e_main.c:803:
+       size =3D adapter->ring_size;
             ^

ERROR: spaces required around that '=' (ctx:WxV)
#3575: FILE: drivers/net/atl1e/atl1e_main.c:804:
+       adapter->ring_vir_addr =3D pci_alloc_consistent(pdev,
                               ^

ERROR: code indent should use tabs where possible
#3576: FILE: drivers/net/atl1e/atl1e_main.c:805:
+                       adapter->ring_size, &adapter->ring_dma);$

ERROR: spaces required around that '=' (ctx:WxV)
#3578: FILE: drivers/net/atl1e/atl1e_main.c:807:
+       if (adapter->ring_vir_addr =3D=3D NULL) {
                                   ^

ERROR: spaces required around that '=' (ctx:VxV)
#3578: FILE: drivers/net/atl1e/atl1e_main.c:807:
+       if (adapter->ring_vir_addr =3D=3D NULL) {
                                      ^

ERROR: do not use assignment in if condition
#3578: FILE: drivers/net/atl1e/atl1e_main.c:807:
+       if (adapter->ring_vir_addr =3D=3D NULL) {

ERROR: code indent should use tabs where possible
#3579: FILE: drivers/net/atl1e/atl1e_main.c:808:
+               dev_err(&pdev->dev, "pci_alloc_consistent failed, "$

ERROR: code indent should use tabs where possible
#3580: FILE: drivers/net/atl1e/atl1e_main.c:809:
+                                   "size =3D D%d", size);$

ERROR: code indent should use tabs where possible
#3581: FILE: drivers/net/atl1e/atl1e_main.c:810:
+               return -ENOMEM;$

ERROR: spaces required around that '=' (ctx:WxV)
#3586: FILE: drivers/net/atl1e/atl1e_main.c:815:
+       rx_page_desc =3D rx_ring->rx_page_desc;
                     ^

ERROR: spaces required around that '=' (ctx:WxV)
#3589: FILE: drivers/net/atl1e/atl1e_main.c:818:
+       tx_ring->dma =3D roundup(adapter->ring_dma, 8);
                     ^

ERROR: spaces required around that '=' (ctx:WxV)
#3590: FILE: drivers/net/atl1e/atl1e_main.c:819:
+       offset =3D tx_ring->dma - adapter->ring_dma;
               ^

WARNING: space prohibited between function name and open parenthesis '('
#3591: FILE: drivers/net/atl1e/atl1e_main.c:820:
+       tx_ring->desc =3D (struct atl1e_tpd_desc *)

ERROR: spaces required around that '=' (ctx:WxV)
#3591: FILE: drivers/net/atl1e/atl1e_main.c:820:
+       tx_ring->desc =3D (struct atl1e_tpd_desc *)
                      ^

ERROR: code indent should use tabs where possible
#3592: FILE: drivers/net/atl1e/atl1e_main.c:821:
+                       (adapter->ring_vir_addr + offset);$

ERROR: spaces required around that '=' (ctx:WxV)
#3593: FILE: drivers/net/atl1e/atl1e_main.c:822:
+       size =3D sizeof(struct atl1e_tx_buffer) * (tx_ring->count);
             ^

ERROR: spaces required around that '=' (ctx:WxV)
#3594: FILE: drivers/net/atl1e/atl1e_main.c:823:
+       tx_ring->tx_buffer =3D kzalloc(size, GFP_KERNEL);
                           ^

ERROR: spaces required around that '=' (ctx:WxV)
#3595: FILE: drivers/net/atl1e/atl1e_main.c:824:
+       if (tx_ring->tx_buffer =3D=3D NULL) {
                               ^

ERROR: spaces required around that '=' (ctx:VxV)
#3595: FILE: drivers/net/atl1e/atl1e_main.c:824:
+       if (tx_ring->tx_buffer =3D=3D NULL) {
                                  ^

ERROR: do not use assignment in if condition
#3595: FILE: drivers/net/atl1e/atl1e_main.c:824:
+       if (tx_ring->tx_buffer =3D=3D NULL) {

ERROR: code indent should use tabs where possible
#3596: FILE: drivers/net/atl1e/atl1e_main.c:825:
+               dev_err(&pdev->dev, "kzalloc failed , size =3D D%d", size);$

ERROR: code indent should use tabs where possible
#3597: FILE: drivers/net/atl1e/atl1e_main.c:826:
+               err =3D -ENOMEM;$

ERROR: spaces required around that '=' (ctx:WxV)
#3597: FILE: drivers/net/atl1e/atl1e_main.c:826:
+               err =3D -ENOMEM;
                    ^

ERROR: need consistent spacing around '-' (ctx:WxV)
#3597: FILE: drivers/net/atl1e/atl1e_main.c:826:
+               err =3D -ENOMEM;
                        ^

ERROR: code indent should use tabs where possible
#3598: FILE: drivers/net/atl1e/atl1e_main.c:827:
+               goto failed;$

WARNING: space prohibited between function name and open parenthesis '('
#3602: FILE: drivers/net/atl1e/atl1e_main.c:831:
+       offset +=3D (sizeof(struct atl1e_tpd_desc) * tx_ring->count);

ERROR: spaces required around that '+=' (ctx:WxV)
#3602: FILE: drivers/net/atl1e/atl1e_main.c:831:
+       offset +=3D (sizeof(struct atl1e_tpd_desc) * tx_ring->count);
               ^

ERROR: spaces required around that '=' (ctx:WxV)
#3603: FILE: drivers/net/atl1e/atl1e_main.c:832:
+       offset =3D roundup(offset, 32);
               ^

ERROR: spaces required around that '=' (ctx:WxV)
#3605: FILE: drivers/net/atl1e/atl1e_main.c:834:
+       for (i =3D 0; i < adapter->num_rx_queues; i++) {
               ^

ERROR: code indent should use tabs where possible
#3606: FILE: drivers/net/atl1e/atl1e_main.c:835:
+               for (j =3D 0; j < AT_PAGE_NUM_PER_QUEUE; j++) {$

ERROR: spaces required around that '=' (ctx:WxV)
#3606: FILE: drivers/net/atl1e/atl1e_main.c:835:
+               for (j =3D 0; j < AT_PAGE_NUM_PER_QUEUE; j++) {
                       ^

ERROR: code indent should use tabs where possible
#3607: FILE: drivers/net/atl1e/atl1e_main.c:836:
+                       rx_page_desc[i].rx_page[j].dma =3D$

ERROR: spaces required around that '=' (ctx:WxV)
#3607: FILE: drivers/net/atl1e/atl1e_main.c:836:
+                       rx_page_desc[i].rx_page[j].dma =3D
                                                       ^

ERROR: code indent should use tabs where possible
#3608: FILE: drivers/net/atl1e/atl1e_main.c:837:
+                               adapter->ring_dma + offset;$

ERROR: code indent should use tabs where possible
#3609: FILE: drivers/net/atl1e/atl1e_main.c:838:
+                       rx_page_desc[i].rx_page[j].addr =3D$

ERROR: spaces required around that '=' (ctx:WxV)
#3609: FILE: drivers/net/atl1e/atl1e_main.c:838:
+                       rx_page_desc[i].rx_page[j].addr =3D
                                                        ^

ERROR: code indent should use tabs where possible
#3610: FILE: drivers/net/atl1e/atl1e_main.c:839:
+                               adapter->ring_vir_addr + offset;$

ERROR: code indent should use tabs where possible
#3611: FILE: drivers/net/atl1e/atl1e_main.c:840:
+                       offset +=3D rx_ring->real_page_size;$

ERROR: spaces required around that '+=' (ctx:WxV)
#3611: FILE: drivers/net/atl1e/atl1e_main.c:840:
+                       offset +=3D rx_ring->real_page_size;
                               ^

ERROR: code indent should use tabs where possible
#3612: FILE: drivers/net/atl1e/atl1e_main.c:841:
+               }$

ERROR: spaces required around that '=' (ctx:WxV)
#3616: FILE: drivers/net/atl1e/atl1e_main.c:845:
+       tx_ring->cmb_dma =3D adapter->ring_dma + offset;
                         ^

WARNING: space prohibited between function name and open parenthesis '('
#3617: FILE: drivers/net/atl1e/atl1e_main.c:846:
+       tx_ring->cmb     =3D (u32 *)(adapter->ring_vir_addr + offset);

ERROR: spaces required around that '=' (ctx:WxV)
#3617: FILE: drivers/net/atl1e/atl1e_main.c:846:
+       tx_ring->cmb     =3D (u32 *)(adapter->ring_vir_addr + offset);
                         ^

ERROR: spaces required around that '+=' (ctx:WxV)
#3618: FILE: drivers/net/atl1e/atl1e_main.c:847:
+       offset +=3D sizeof(u32);
               ^

ERROR: spaces required around that '=' (ctx:WxV)
#3620: FILE: drivers/net/atl1e/atl1e_main.c:849:
+       for (i =3D 0; i < adapter->num_rx_queues; i++) {
               ^

ERROR: code indent should use tabs where possible
#3621: FILE: drivers/net/atl1e/atl1e_main.c:850:
+               for (j =3D 0; j < AT_PAGE_NUM_PER_QUEUE; j++) {$

ERROR: spaces required around that '=' (ctx:WxV)
#3621: FILE: drivers/net/atl1e/atl1e_main.c:850:
+               for (j =3D 0; j < AT_PAGE_NUM_PER_QUEUE; j++) {
                       ^

ERROR: code indent should use tabs where possible
#3622: FILE: drivers/net/atl1e/atl1e_main.c:851:
+                       rx_page_desc[i].rx_page[j].write_offset_dma =3D$

ERROR: spaces required around that '=' (ctx:WxV)
#3622: FILE: drivers/net/atl1e/atl1e_main.c:851:
+                       rx_page_desc[i].rx_page[j].write_offset_dma =3D
                                                                    ^

ERROR: code indent should use tabs where possible
#3623: FILE: drivers/net/atl1e/atl1e_main.c:852:
+                               adapter->ring_dma + offset;$

ERROR: code indent should use tabs where possible
#3624: FILE: drivers/net/atl1e/atl1e_main.c:853:
+                       rx_page_desc[i].rx_page[j].write_offset_addr =3D$

ERROR: spaces required around that '=' (ctx:WxV)
#3624: FILE: drivers/net/atl1e/atl1e_main.c:853:
+                       rx_page_desc[i].rx_page[j].write_offset_addr =3D
                                                                     ^

ERROR: code indent should use tabs where possible
#3625: FILE: drivers/net/atl1e/atl1e_main.c:854:
+                               adapter->ring_vir_addr + offset;$

ERROR: code indent should use tabs where possible
#3626: FILE: drivers/net/atl1e/atl1e_main.c:855:
+                       offset +=3D sizeof(u32);$

ERROR: spaces required around that '+=' (ctx:WxV)
#3626: FILE: drivers/net/atl1e/atl1e_main.c:855:
+                       offset +=3D sizeof(u32);
                               ^

ERROR: code indent should use tabs where possible
#3627: FILE: drivers/net/atl1e/atl1e_main.c:856:
+               }$

ERROR: code indent should use tabs where possible
#3631: FILE: drivers/net/atl1e/atl1e_main.c:860:
+               dev_err(&pdev->dev, "offset(%d) > ring size(%d) !!\n",$

ERROR: code indent should use tabs where possible
#3632: FILE: drivers/net/atl1e/atl1e_main.c:861:
+                               offset, adapter->ring_size);$

ERROR: code indent should use tabs where possible
#3633: FILE: drivers/net/atl1e/atl1e_main.c:862:
+               err =3D -1;$

ERROR: spaces required around that '=' (ctx:WxV)
#3633: FILE: drivers/net/atl1e/atl1e_main.c:862:
+               err =3D -1;
                    ^

ERROR: need consistent spacing around '-' (ctx:WxV)
#3633: FILE: drivers/net/atl1e/atl1e_main.c:862:
+               err =3D -1;
                        ^

ERROR: code indent should use tabs where possible
#3634: FILE: drivers/net/atl1e/atl1e_main.c:863:
+               goto failed;$

ERROR: spaces required around that '!=' (ctx:WxV)
#3639: FILE: drivers/net/atl1e/atl1e_main.c:868:
+       if (adapter->ring_vir_addr !=3D NULL) {
                                   ^

ERROR: code indent should use tabs where possible
#3640: FILE: drivers/net/atl1e/atl1e_main.c:869:
+               pci_free_consistent(pdev, adapter->ring_size,$

ERROR: code indent should use tabs where possible
#3641: FILE: drivers/net/atl1e/atl1e_main.c:870:
+                               adapter->ring_vir_addr, adapter->ring_dma);$

ERROR: code indent should use tabs where possible
#3642: FILE: drivers/net/atl1e/atl1e_main.c:871:
+               adapter->ring_vir_addr =3D NULL;$

ERROR: spaces required around that '=' (ctx:WxV)
#3642: FILE: drivers/net/atl1e/atl1e_main.c:871:
+               adapter->ring_vir_addr =3D NULL;
                                       ^

ERROR: spaces required around that '=' (ctx:VxE)
#3647: FILE: drivers/net/atl1e/atl1e_main.c:876:
+static inline void atl1e_configure_des_ring(const struct atl1e_adapter *ad=
                                                                           ^

ERROR: that open brace { should be on the previous line
#3649: FILE: drivers/net/atl1e/atl1e_main.c:877:
+static inline void atl1e_configure_des_ring(const struct atl1e_adapter *ad=
+{

WARNING: space prohibited between function name and open parenthesis '('
#3651: FILE: drivers/net/atl1e/atl1e_main.c:879:
+       struct atl1e_hw *hw =3D (struct atl1e_hw *)&adapter->hw;

ERROR: spaces required around that '=' (ctx:WxV)
#3651: FILE: drivers/net/atl1e/atl1e_main.c:879:
+       struct atl1e_hw *hw =3D (struct atl1e_hw *)&adapter->hw;
                            ^

ERROR: spaces required around that '=' (ctx:WxV)
#3652: FILE: drivers/net/atl1e/atl1e_main.c:880:
+       struct atl1e_rx_ring *rx_ring =3D
                                      ^

ERROR: code indent should use tabs where possible
#3653: FILE: drivers/net/atl1e/atl1e_main.c:881:
+                       (struct atl1e_rx_ring *)&adapter->rx_ring;$

ERROR: spaces required around that '=' (ctx:WxV)
#3654: FILE: drivers/net/atl1e/atl1e_main.c:882:
+       struct atl1e_tx_ring *tx_ring =3D
                                      ^

ERROR: code indent should use tabs where possible
#3655: FILE: drivers/net/atl1e/atl1e_main.c:883:
+                       (struct atl1e_tx_ring *)&adapter->tx_ring;$

ERROR: spaces required around that '=' (ctx:WxV)
#3656: FILE: drivers/net/atl1e/atl1e_main.c:884:
+       struct atl1e_rx_page_desc *rx_page_desc =3D NULL;
                                                ^

ERROR: code indent should use tabs where possible
#3660: FILE: drivers/net/atl1e/atl1e_main.c:888:
+                       (u32)((adapter->ring_dma & AT_DMA_HI_ADDR_MASK) >> =$

ERROR: code indent should use tabs where possible
#3663: FILE: drivers/net/atl1e/atl1e_main.c:890:
+                       (u32)((tx_ring->dma) & AT_DMA_LO_ADDR_MASK));$

ERROR: code indent should use tabs where possible
#3666: FILE: drivers/net/atl1e/atl1e_main.c:893:
+                       (u32)((tx_ring->cmb_dma) & AT_DMA_LO_ADDR_MASK));$

ERROR: spaces required around that '=' (ctx:WxV)
#3668: FILE: drivers/net/atl1e/atl1e_main.c:895:
+       rx_page_desc =3D rx_ring->rx_page_desc;
                     ^

ERROR: spaces required around that '=' (ctx:WxV)
#3670: FILE: drivers/net/atl1e/atl1e_main.c:897:
+       for (i =3D 0; i < AT_MAX_RECEIVE_QUEUE; i++) {
               ^

ERROR: code indent should use tabs where possible
#3671: FILE: drivers/net/atl1e/atl1e_main.c:898:
+               AT_WRITE_REG(hw, atl1e_rx_page_hi_addr_regs[i],$

ERROR: code indent should use tabs where possible
#3672: FILE: drivers/net/atl1e/atl1e_main.c:899:
+                                (u32)((adapter->ring_dma &$

ERROR: code indent should use tabs where possible
#3673: FILE: drivers/net/atl1e/atl1e_main.c:900:
+                                AT_DMA_HI_ADDR_MASK) >> 32));$

ERROR: code indent should use tabs where possible
#3674: FILE: drivers/net/atl1e/atl1e_main.c:901:
+               for (j =3D 0; j < AT_PAGE_NUM_PER_QUEUE; j++) {$

ERROR: spaces required around that '=' (ctx:WxV)
#3674: FILE: drivers/net/atl1e/atl1e_main.c:901:
+               for (j =3D 0; j < AT_PAGE_NUM_PER_QUEUE; j++) {
                       ^

ERROR: code indent should use tabs where possible
#3675: FILE: drivers/net/atl1e/atl1e_main.c:902:
+                       u32 page_phy_addr;$

ERROR: code indent should use tabs where possible
#3676: FILE: drivers/net/atl1e/atl1e_main.c:903:
+                       u32 offset_phy_addr;$

ERROR: code indent should use tabs where possible
#3678: FILE: drivers/net/atl1e/atl1e_main.c:905:
+                       page_phy_addr =3D rx_page_desc[i].rx_page[j].dma;$

ERROR: spaces required around that '=' (ctx:WxV)
#3678: FILE: drivers/net/atl1e/atl1e_main.c:905:
+                       page_phy_addr =3D rx_page_desc[i].rx_page[j].dma;
                                      ^

ERROR: code indent should use tabs where possible
#3679: FILE: drivers/net/atl1e/atl1e_main.c:906:
+                       offset_phy_addr =3D$

ERROR: spaces required around that '=' (ctx:WxV)
#3679: FILE: drivers/net/atl1e/atl1e_main.c:906:
+                       offset_phy_addr =3D
                                        ^

ERROR: code indent should use tabs where possible
#3680: FILE: drivers/net/atl1e/atl1e_main.c:907:
+                                  rx_page_desc[i].rx_page[j].write_offset_=$

ERROR: spaces required around that '=' (ctx:VxE)
#3680: FILE: drivers/net/atl1e/atl1e_main.c:907:
+                                  rx_page_desc[i].rx_page[j].write_offset_=
                                                                           ^

ERROR: code indent should use tabs where possible
#3683: FILE: drivers/net/atl1e/atl1e_main.c:909:
+                       AT_WRITE_REG(hw, atl1e_rx_page_lo_addr_regs[i][j],$

ERROR: code indent should use tabs where possible
#3684: FILE: drivers/net/atl1e/atl1e_main.c:910:
+                                       page_phy_addr & AT_DMA_LO_ADDR_MASK=$

ERROR: spaces required around that '=' (ctx:VxE)
#3684: FILE: drivers/net/atl1e/atl1e_main.c:910:
+                                       page_phy_addr & AT_DMA_LO_ADDR_MASK=
                                                                           ^

ERROR: code indent should use tabs where possible
#3686: FILE: drivers/net/atl1e/atl1e_main.c:911:
+                       AT_WRITE_REG(hw, atl1e_rx_page_write_offset_regs[i]=$

ERROR: spaces required around that '=' (ctx:VxE)
#3686: FILE: drivers/net/atl1e/atl1e_main.c:911:
+                       AT_WRITE_REG(hw, atl1e_rx_page_write_offset_regs[i]=
                                                                           ^

ERROR: code indent should use tabs where possible
#3688: FILE: drivers/net/atl1e/atl1e_main.c:912:
+                                       offset_phy_addr & AT_DMA_LO_ADDR_MA=$

ERROR: spaces required around that '=' (ctx:VxE)
#3688: FILE: drivers/net/atl1e/atl1e_main.c:912:
+                                       offset_phy_addr & AT_DMA_LO_ADDR_MA=
                                                                           ^

ERROR: code indent should use tabs where possible
#3690: FILE: drivers/net/atl1e/atl1e_main.c:913:
+                       AT_WRITE_REGB(hw, atl1e_rx_page_vld_regs[i][j], 1);$

ERROR: code indent should use tabs where possible
#3691: FILE: drivers/net/atl1e/atl1e_main.c:914:
+               }$

WARNING: space prohibited between function name and open parenthesis '('
#3703: FILE: drivers/net/atl1e/atl1e_main.c:926:
+       struct atl1e_hw *hw =3D (struct atl1e_hw *)&adapter->hw;

ERROR: spaces required around that '=' (ctx:WxV)
#3703: FILE: drivers/net/atl1e/atl1e_main.c:926:
+       struct atl1e_hw *hw =3D (struct atl1e_hw *)&adapter->hw;
                            ^

ERROR: spaces required around that '=' (ctx:WxV)
#3704: FILE: drivers/net/atl1e/atl1e_main.c:927:
+       u32 dev_ctrl_data =3D 0;
                          ^

ERROR: spaces required around that '=' (ctx:WxV)
#3705: FILE: drivers/net/atl1e/atl1e_main.c:928:
+       u32 max_pay_load =3D 0;
                         ^

ERROR: spaces required around that '=' (ctx:WxV)
#3706: FILE: drivers/net/atl1e/atl1e_main.c:929:
+       u32 jumbo_thresh =3D 0;
                         ^

ERROR: spaces required around that '=' (ctx:WxV)
#3707: FILE: drivers/net/atl1e/atl1e_main.c:930:
+       u32 extra_size =3D 0;     /* Jumbo frame threshold in QWORD unit */
                       ^

ERROR: spaces required around that '!=' (ctx:WxV)
#3710: FILE: drivers/net/atl1e/atl1e_main.c:933:
+       if (hw->nic_type !=3D athr_l2e_revB) {
                         ^

ERROR: code indent should use tabs where possible
#3711: FILE: drivers/net/atl1e/atl1e_main.c:934:
+               extra_size =3D ETH_HLEN + VLAN_HLEN + ETH_FCS_LEN;$

ERROR: spaces required around that '=' (ctx:WxV)
#3711: FILE: drivers/net/atl1e/atl1e_main.c:934:
+               extra_size =3D ETH_HLEN + VLAN_HLEN + ETH_FCS_LEN;
                           ^

ERROR: code indent should use tabs where possible
#3712: FILE: drivers/net/atl1e/atl1e_main.c:935:
+               if (hw->max_frame_size <=3D 1500) {$

ERROR: spaces required around that '<=' (ctx:WxV)
#3712: FILE: drivers/net/atl1e/atl1e_main.c:935:
+               if (hw->max_frame_size <=3D 1500) {
                                       ^

ERROR: code indent should use tabs where possible
#3713: FILE: drivers/net/atl1e/atl1e_main.c:936:
+                       jumbo_thresh =3D hw->max_frame_size + extra_size;$

ERROR: spaces required around that '=' (ctx:WxV)
#3713: FILE: drivers/net/atl1e/atl1e_main.c:936:
+                       jumbo_thresh =3D hw->max_frame_size + extra_size;
                                     ^

ERROR: code indent should use tabs where possible
#3714: FILE: drivers/net/atl1e/atl1e_main.c:937:
+               } else if (hw->max_frame_size < 6*1024) {$

ERROR: code indent should use tabs where possible
#3715: FILE: drivers/net/atl1e/atl1e_main.c:938:
+                       jumbo_thresh =3D$

ERROR: spaces required around that '=' (ctx:WxV)
#3715: FILE: drivers/net/atl1e/atl1e_main.c:938:
+                       jumbo_thresh =3D
                                     ^

ERROR: code indent should use tabs where possible
#3716: FILE: drivers/net/atl1e/atl1e_main.c:939:
+                               (hw->max_frame_size + extra_size) * 2 / 3;$

ERROR: code indent should use tabs where possible
#3717: FILE: drivers/net/atl1e/atl1e_main.c:940:
+               } else {$

ERROR: code indent should use tabs where possible
#3718: FILE: drivers/net/atl1e/atl1e_main.c:941:
+                       jumbo_thresh =3D (hw->max_frame_size + extra_size) =$

WARNING: space prohibited between function name and open parenthesis '('
#3718: FILE: drivers/net/atl1e/atl1e_main.c:941:
+                       jumbo_thresh =3D (hw->max_frame_size + extra_size) =

ERROR: spaces required around that '=' (ctx:WxV)
#3718: FILE: drivers/net/atl1e/atl1e_main.c:941:
+                       jumbo_thresh =3D (hw->max_frame_size + extra_size) =
                                     ^

ERROR: code indent should use tabs where possible
#3720: FILE: drivers/net/atl1e/atl1e_main.c:942:
+               }$

ERROR: code indent should use tabs where possible
#3721: FILE: drivers/net/atl1e/atl1e_main.c:943:
+               AT_WRITE_REG(hw, REG_TX_EARLY_TH, (jumbo_thresh + 7) >> 3);$

ERROR: spaces required around that '=' (ctx:WxV)
#3724: FILE: drivers/net/atl1e/atl1e_main.c:946:
+       dev_ctrl_data =3D AT_READ_REG(hw, REG_DEVICE_CTRL);
                      ^

WARNING: space prohibited between function name and open parenthesis '('
#3726: FILE: drivers/net/atl1e/atl1e_main.c:948:
+       max_pay_load  =3D ((dev_ctrl_data >> DEVICE_CTRL_MAX_PAYLOAD_SHIFT)=

ERROR: spaces required around that '=' (ctx:WxV)
#3726: FILE: drivers/net/atl1e/atl1e_main.c:948:
+       max_pay_load  =3D ((dev_ctrl_data >> DEVICE_CTRL_MAX_PAYLOAD_SHIFT)=
                      ^

ERROR: spaces required around that '=' (ctx:VxE)
#3726: FILE: drivers/net/atl1e/atl1e_main.c:948:
+       max_pay_load  =3D ((dev_ctrl_data >> DEVICE_CTRL_MAX_PAYLOAD_SHIFT)=
                                                                           ^

ERROR: code indent should use tabs where possible
#3728: FILE: drivers/net/atl1e/atl1e_main.c:949:
+                       DEVICE_CTRL_MAX_PAYLOAD_MASK;$

ERROR: spaces required around that '=' (ctx:WxV)
#3730: FILE: drivers/net/atl1e/atl1e_main.c:951:
+       hw->dmaw_block =3D min(max_pay_load, hw->dmaw_block);
                       ^

WARNING: space prohibited between function name and open parenthesis '('
#3732: FILE: drivers/net/atl1e/atl1e_main.c:953:
+       max_pay_load  =3D ((dev_ctrl_data >> DEVICE_CTRL_MAX_RREQ_SZ_SHIFT)=

ERROR: spaces required around that '=' (ctx:WxV)
#3732: FILE: drivers/net/atl1e/atl1e_main.c:953:
+       max_pay_load  =3D ((dev_ctrl_data >> DEVICE_CTRL_MAX_RREQ_SZ_SHIFT)=
                      ^

ERROR: spaces required around that '=' (ctx:VxE)
#3732: FILE: drivers/net/atl1e/atl1e_main.c:953:
+       max_pay_load  =3D ((dev_ctrl_data >> DEVICE_CTRL_MAX_RREQ_SZ_SHIFT)=
                                                                           ^

ERROR: code indent should use tabs where possible
#3734: FILE: drivers/net/atl1e/atl1e_main.c:954:
+                       DEVICE_CTRL_MAX_RREQ_SZ_MASK;$

ERROR: spaces required around that '=' (ctx:WxV)
#3735: FILE: drivers/net/atl1e/atl1e_main.c:955:
+       hw->dmar_block =3D min(max_pay_load, hw->dmar_block);
                       ^

ERROR: spaces required around that '!=' (ctx:WxV)
#3737: FILE: drivers/net/atl1e/atl1e_main.c:957:
+       if (hw->nic_type !=3D athr_l2e_revB)
                         ^

ERROR: code indent should use tabs where possible
#3738: FILE: drivers/net/atl1e/atl1e_main.c:958:
+               AT_WRITE_REGW(hw, REG_TXQ_CTRL + 2,$

ERROR: code indent should use tabs where possible
#3739: FILE: drivers/net/atl1e/atl1e_main.c:959:
+                             atl1e_pay_load_size[hw->dmar_block]);$

ERROR: code indent should use tabs where possible
#3743: FILE: drivers/net/atl1e/atl1e_main.c:963:
+                       (((u16)hw->tpd_burst & TXQ_CTRL_NUM_TPD_BURST_MASK)$

ERROR: code indent should use tabs where possible
#3744: FILE: drivers/net/atl1e/atl1e_main.c:964:
+                        << TXQ_CTRL_NUM_TPD_BURST_SHIFT)$

ERROR: code indent should use tabs where possible
#3745: FILE: drivers/net/atl1e/atl1e_main.c:965:
+                       | TXQ_CTRL_ENH_MODE | TXQ_CTRL_EN);$

WARNING: space prohibited between function name and open parenthesis '('
#3751: FILE: drivers/net/atl1e/atl1e_main.c:971:
+       struct atl1e_hw *hw =3D (struct atl1e_hw *)&adapter->hw;

ERROR: spaces required around that '=' (ctx:WxV)
#3751: FILE: drivers/net/atl1e/atl1e_main.c:971:
+       struct atl1e_hw *hw =3D (struct atl1e_hw *)&adapter->hw;
                            ^

ERROR: spaces required around that '=' (ctx:WxV)
#3752: FILE: drivers/net/atl1e/atl1e_main.c:972:
+       u32 rxf_len  =3D 0;
                     ^

ERROR: spaces required around that '=' (ctx:WxV)
#3753: FILE: drivers/net/atl1e/atl1e_main.c:973:
+       u32 rxf_low  =3D 0;
                     ^

ERROR: spaces required around that '=' (ctx:WxV)
#3754: FILE: drivers/net/atl1e/atl1e_main.c:974:
+       u32 rxf_high =3D 0;
                     ^

ERROR: spaces required around that '=' (ctx:WxV)
#3755: FILE: drivers/net/atl1e/atl1e_main.c:975:
+       u32 rxf_thresh_data =3D 0;
                            ^

ERROR: spaces required around that '=' (ctx:WxV)
#3756: FILE: drivers/net/atl1e/atl1e_main.c:976:
+       u32 rxq_ctrl_data =3D 0;
                          ^

ERROR: spaces required around that '!=' (ctx:WxV)
#3758: FILE: drivers/net/atl1e/atl1e_main.c:978:
+       if (hw->nic_type !=3D athr_l2e_revB) {
                         ^

ERROR: code indent should use tabs where possible
#3759: FILE: drivers/net/atl1e/atl1e_main.c:979:
+               AT_WRITE_REGW(hw, REG_RXQ_JMBOSZ_RRDTIM,$

ERROR: code indent should use tabs where possible
#3760: FILE: drivers/net/atl1e/atl1e_main.c:980:
+                             (u16)((hw->rx_jumbo_th & RXQ_JMBOSZ_TH_MASK) =$

ERROR: code indent should use tabs where possible
#3762: FILE: drivers/net/atl1e/atl1e_main.c:981:
+                             RXQ_JMBOSZ_TH_SHIFT |$

ERROR: code indent should use tabs where possible
#3763: FILE: drivers/net/atl1e/atl1e_main.c:982:
+                             (1 & RXQ_JMBO_LKAH_MASK) <<$

ERROR: code indent should use tabs where possible
#3764: FILE: drivers/net/atl1e/atl1e_main.c:983:
+                             RXQ_JMBO_LKAH_SHIFT));$

ERROR: code indent should use tabs where possible
#3766: FILE: drivers/net/atl1e/atl1e_main.c:985:
+               rxf_len  =3D AT_READ_REG(hw, REG_SRAM_RXF_LEN);$

ERROR: spaces required around that '=' (ctx:WxV)
#3766: FILE: drivers/net/atl1e/atl1e_main.c:985:
+               rxf_len  =3D AT_READ_REG(hw, REG_SRAM_RXF_LEN);
                         ^

ERROR: code indent should use tabs where possible
#3767: FILE: drivers/net/atl1e/atl1e_main.c:986:
+               rxf_high =3D rxf_len * 4 / 5;$

ERROR: "foo * bar" should be "foo *bar"
#3767: FILE: drivers/net/atl1e/atl1e_main.c:986:
+               rxf_high =3D rxf_len * 4 / 5;

ERROR: spaces required around that '=' (ctx:WxV)
#3767: FILE: drivers/net/atl1e/atl1e_main.c:986:
+               rxf_high =3D rxf_len * 4 / 5;
                         ^

ERROR: code indent should use tabs where possible
#3768: FILE: drivers/net/atl1e/atl1e_main.c:987:
+               rxf_low  =3D rxf_len / 5;$

ERROR: spaces required around that '=' (ctx:WxV)
#3768: FILE: drivers/net/atl1e/atl1e_main.c:987:
+               rxf_low  =3D rxf_len / 5;
                         ^

ERROR: code indent should use tabs where possible
#3769: FILE: drivers/net/atl1e/atl1e_main.c:988:
+               rxf_thresh_data =3D ((rxf_high  & RXQ_RXF_PAUSE_TH_HI_MASK)$

WARNING: space prohibited between function name and open parenthesis '('
#3769: FILE: drivers/net/atl1e/atl1e_main.c:988:
+               rxf_thresh_data =3D ((rxf_high  & RXQ_RXF_PAUSE_TH_HI_MASK)

ERROR: spaces required around that '=' (ctx:WxV)
#3769: FILE: drivers/net/atl1e/atl1e_main.c:988:
+               rxf_thresh_data =3D ((rxf_high  & RXQ_RXF_PAUSE_TH_HI_MASK)
                                ^

ERROR: code indent should use tabs where possible
#3770: FILE: drivers/net/atl1e/atl1e_main.c:989:
+                                 << RXQ_RXF_PAUSE_TH_HI_SHIFT) |$

ERROR: code indent should use tabs where possible
#3771: FILE: drivers/net/atl1e/atl1e_main.c:990:
+                                 ((rxf_low & RXQ_RXF_PAUSE_TH_LO_MASK)$

ERROR: code indent should use tabs where possible
#3772: FILE: drivers/net/atl1e/atl1e_main.c:991:
+                                 << RXQ_RXF_PAUSE_TH_LO_SHIFT);$

ERROR: code indent should use tabs where possible
#3774: FILE: drivers/net/atl1e/atl1e_main.c:993:
+               AT_WRITE_REG(hw, REG_RXQ_RXF_PAUSE_THRESH, rxf_thresh_data)=$

ERROR: spaces required around that '=' (ctx:VxE)
#3774: FILE: drivers/net/atl1e/atl1e_main.c:993:
+               AT_WRITE_REG(hw, REG_RXQ_RXF_PAUSE_THRESH, rxf_thresh_data)=
                                                                           ^

ERROR: code indent should use tabs where possible
#3783: FILE: drivers/net/atl1e/atl1e_main.c:1001:
+               rxq_ctrl_data |=3D RXQ_CTRL_HASH_TYPE_IPV4;$

ERROR: spaces required around that '|=' (ctx:WxV)
#3783: FILE: drivers/net/atl1e/atl1e_main.c:1001:
+               rxq_ctrl_data |=3D RXQ_CTRL_HASH_TYPE_IPV4;
                              ^

ERROR: code indent should use tabs where possible
#3786: FILE: drivers/net/atl1e/atl1e_main.c:1004:
+               rxq_ctrl_data |=3D RXQ_CTRL_HASH_TYPE_IPV4_TCP;$

ERROR: spaces required around that '|=' (ctx:WxV)
#3786: FILE: drivers/net/atl1e/atl1e_main.c:1004:
+               rxq_ctrl_data |=3D RXQ_CTRL_HASH_TYPE_IPV4_TCP;
                              ^

ERROR: code indent should use tabs where possible
#3789: FILE: drivers/net/atl1e/atl1e_main.c:1007:
+               rxq_ctrl_data |=3D RXQ_CTRL_HASH_TYPE_IPV6;$

ERROR: spaces required around that '|=' (ctx:WxV)
#3789: FILE: drivers/net/atl1e/atl1e_main.c:1007:
+               rxq_ctrl_data |=3D RXQ_CTRL_HASH_TYPE_IPV6;
                              ^

ERROR: code indent should use tabs where possible
#3792: FILE: drivers/net/atl1e/atl1e_main.c:1010:
+               rxq_ctrl_data |=3D RXQ_CTRL_HASH_TYPE_IPV6_TCP;$

ERROR: spaces required around that '|=' (ctx:WxV)
#3792: FILE: drivers/net/atl1e/atl1e_main.c:1010:
+               rxq_ctrl_data |=3D RXQ_CTRL_HASH_TYPE_IPV6_TCP;
                              ^

ERROR: spaces required around that '!=' (ctx:WxV)
#3794: FILE: drivers/net/atl1e/atl1e_main.c:1012:
+       if (hw->rrs_type !=3D atl1e_rrs_disable)
                         ^

ERROR: code indent should use tabs where possible
#3795: FILE: drivers/net/atl1e/atl1e_main.c:1013:
+               rxq_ctrl_data |=3D$

ERROR: spaces required around that '|=' (ctx:WxV)
#3795: FILE: drivers/net/atl1e/atl1e_main.c:1013:
+               rxq_ctrl_data |=3D
                              ^

ERROR: code indent should use tabs where possible
#3796: FILE: drivers/net/atl1e/atl1e_main.c:1014:
+                       (RXQ_CTRL_HASH_ENABLE | RXQ_CTRL_RSS_MODE_MQUESINT)=$

ERROR: spaces required around that '=' (ctx:VxE)
#3796: FILE: drivers/net/atl1e/atl1e_main.c:1014:
+                       (RXQ_CTRL_HASH_ENABLE | RXQ_CTRL_RSS_MODE_MQUESINT)=
                                                                           ^

ERROR: spaces required around that '|=' (ctx:WxV)
#3800: FILE: drivers/net/atl1e/atl1e_main.c:1017:
+       rxq_ctrl_data |=3D RXQ_CTRL_IPV6_XSUM_VERIFY_EN | RXQ_CTRL_PBA_ALIG=
                      ^

ERROR: spaces required around that '=' (ctx:VxE)
#3800: FILE: drivers/net/atl1e/atl1e_main.c:1017:
+       rxq_ctrl_data |=3D RXQ_CTRL_IPV6_XSUM_VERIFY_EN | RXQ_CTRL_PBA_ALIG=
                                                                           ^

ERROR: code indent should use tabs where possible
#3802: FILE: drivers/net/atl1e/atl1e_main.c:1018:
+                        RXQ_CTRL_CUT_THRU_EN | RXQ_CTRL_EN;$

ERROR: spaces required around that '=' (ctx:WxV)
#3810: FILE: drivers/net/atl1e/atl1e_main.c:1026:
+       struct atl1e_hw *hw =3D &adapter->hw;
                            ^

ERROR: need consistent spacing around '&' (ctx:WxV)
#3810: FILE: drivers/net/atl1e/atl1e_main.c:1026:
+       struct atl1e_hw *hw =3D &adapter->hw;
                                ^

ERROR: spaces required around that '=' (ctx:WxV)
#3811: FILE: drivers/net/atl1e/atl1e_main.c:1027:
+       u32 dma_ctrl_data =3D 0;
                          ^

ERROR: spaces required around that '=' (ctx:WxV)
#3813: FILE: drivers/net/atl1e/atl1e_main.c:1029:
+       dma_ctrl_data =3D DMA_CTRL_RXCMB_EN;
                      ^

WARNING: space prohibited between function name and open parenthesis '('
#3814: FILE: drivers/net/atl1e/atl1e_main.c:1030:
+       dma_ctrl_data |=3D (((u32)hw->dmar_block) & DMA_CTRL_DMAR_BURST_LEN=

ERROR: spaces required around that '|=' (ctx:WxV)
#3814: FILE: drivers/net/atl1e/atl1e_main.c:1030:
+       dma_ctrl_data |=3D (((u32)hw->dmar_block) & DMA_CTRL_DMAR_BURST_LEN=
                      ^

ERROR: spaces required around that '=' (ctx:VxE)
#3814: FILE: drivers/net/atl1e/atl1e_main.c:1030:
+       dma_ctrl_data |=3D (((u32)hw->dmar_block) & DMA_CTRL_DMAR_BURST_LEN=
                                                                           ^

ERROR: code indent should use tabs where possible
#3816: FILE: drivers/net/atl1e/atl1e_main.c:1031:
+               << DMA_CTRL_DMAR_BURST_LEN_SHIFT;$

WARNING: space prohibited between function name and open parenthesis '('
#3817: FILE: drivers/net/atl1e/atl1e_main.c:1032:
+       dma_ctrl_data |=3D (((u32)hw->dmaw_block) & DMA_CTRL_DMAW_BURST_LEN=

ERROR: spaces required around that '|=' (ctx:WxV)
#3817: FILE: drivers/net/atl1e/atl1e_main.c:1032:
+       dma_ctrl_data |=3D (((u32)hw->dmaw_block) & DMA_CTRL_DMAW_BURST_LEN=
                      ^

ERROR: spaces required around that '=' (ctx:VxE)
#3817: FILE: drivers/net/atl1e/atl1e_main.c:1032:
+       dma_ctrl_data |=3D (((u32)hw->dmaw_block) & DMA_CTRL_DMAW_BURST_LEN=
                                                                           ^

ERROR: code indent should use tabs where possible
#3819: FILE: drivers/net/atl1e/atl1e_main.c:1033:
+               << DMA_CTRL_DMAW_BURST_LEN_SHIFT;$

ERROR: spaces required around that '|=' (ctx:WxV)
#3820: FILE: drivers/net/atl1e/atl1e_main.c:1034:
+       dma_ctrl_data |=3D DMA_CTRL_DMAR_REQ_PRI | DMA_CTRL_DMAR_OUT_ORDER;
                      ^

WARNING: space prohibited between function name and open parenthesis '('
#3821: FILE: drivers/net/atl1e/atl1e_main.c:1035:
+       dma_ctrl_data |=3D (((u32)hw->dmar_dly_cnt) & DMA_CTRL_DMAR_DLY_CNT=

ERROR: spaces required around that '|=' (ctx:WxV)
#3821: FILE: drivers/net/atl1e/atl1e_main.c:1035:
+       dma_ctrl_data |=3D (((u32)hw->dmar_dly_cnt) & DMA_CTRL_DMAR_DLY_CNT=
                      ^

ERROR: spaces required around that '=' (ctx:VxE)
#3821: FILE: drivers/net/atl1e/atl1e_main.c:1035:
+       dma_ctrl_data |=3D (((u32)hw->dmar_dly_cnt) & DMA_CTRL_DMAR_DLY_CNT=
                                                                           ^

ERROR: code indent should use tabs where possible
#3823: FILE: drivers/net/atl1e/atl1e_main.c:1036:
+               << DMA_CTRL_DMAR_DLY_CNT_SHIFT;$

WARNING: space prohibited between function name and open parenthesis '('
#3824: FILE: drivers/net/atl1e/atl1e_main.c:1037:
+       dma_ctrl_data |=3D (((u32)hw->dmaw_dly_cnt) & DMA_CTRL_DMAW_DLY_CNT=

ERROR: spaces required around that '|=' (ctx:WxV)
#3824: FILE: drivers/net/atl1e/atl1e_main.c:1037:
+       dma_ctrl_data |=3D (((u32)hw->dmaw_dly_cnt) & DMA_CTRL_DMAW_DLY_CNT=
                      ^

ERROR: spaces required around that '=' (ctx:VxE)
#3824: FILE: drivers/net/atl1e/atl1e_main.c:1037:
+       dma_ctrl_data |=3D (((u32)hw->dmaw_dly_cnt) & DMA_CTRL_DMAW_DLY_CNT=
                                                                           ^

ERROR: code indent should use tabs where possible
#3826: FILE: drivers/net/atl1e/atl1e_main.c:1038:
+               << DMA_CTRL_DMAW_DLY_CNT_SHIFT;$

ERROR: spaces required around that '=' (ctx:WxV)
#3835: FILE: drivers/net/atl1e/atl1e_main.c:1047:
+       struct atl1e_hw *hw =3D &adapter->hw;
                            ^

ERROR: need consistent spacing around '&' (ctx:WxV)
#3835: FILE: drivers/net/atl1e/atl1e_main.c:1047:
+       struct atl1e_hw *hw =3D &adapter->hw;
                                ^

ERROR: spaces required around that '=' (ctx:WxV)
#3836: FILE: drivers/net/atl1e/atl1e_main.c:1048:
+       struct net_device *netdev =3D adapter->netdev;
                                  ^

ERROR: spaces required around that '=' (ctx:WxV)
#3839: FILE: drivers/net/atl1e/atl1e_main.c:1051:
+       value =3D MAC_CTRL_TX_EN |
              ^

ERROR: code indent should use tabs where possible
#3840: FILE: drivers/net/atl1e/atl1e_main.c:1052:
+               MAC_CTRL_RX_EN ;$

ERROR: spaces required around that '=' (ctx:WxV)
#3842: FILE: drivers/net/atl1e/atl1e_main.c:1054:
+       if (FULL_DUPLEX =3D=3D adapter->link_duplex)
                        ^

ERROR: spaces required around that '=' (ctx:VxV)
#3842: FILE: drivers/net/atl1e/atl1e_main.c:1054:
+       if (FULL_DUPLEX =3D=3D adapter->link_duplex)
                           ^

ERROR: do not use assignment in if condition
#3842: FILE: drivers/net/atl1e/atl1e_main.c:1054:
+       if (FULL_DUPLEX =3D=3D adapter->link_duplex)

ERROR: code indent should use tabs where possible
#3843: FILE: drivers/net/atl1e/atl1e_main.c:1055:
+               value |=3D MAC_CTRL_DUPLX;$

ERROR: spaces required around that '|=' (ctx:WxV)
#3843: FILE: drivers/net/atl1e/atl1e_main.c:1055:
+               value |=3D MAC_CTRL_DUPLX;
                      ^

WARNING: space prohibited between function name and open parenthesis '('
#3845: FILE: drivers/net/atl1e/atl1e_main.c:1057:
+       value |=3D ((u32)((SPEED_1000 =3D=3D adapter->link_speed) ?

ERROR: spaces required around that '|=' (ctx:WxV)
#3845: FILE: drivers/net/atl1e/atl1e_main.c:1057:
+       value |=3D ((u32)((SPEED_1000 =3D=3D adapter->link_speed) ?
              ^

ERROR: spaces required around that '=' (ctx:WxV)
#3845: FILE: drivers/net/atl1e/atl1e_main.c:1057:
+       value |=3D ((u32)((SPEED_1000 =3D=3D adapter->link_speed) ?
                                      ^

ERROR: spaces required around that '=' (ctx:VxV)
#3845: FILE: drivers/net/atl1e/atl1e_main.c:1057:
+       value |=3D ((u32)((SPEED_1000 =3D=3D adapter->link_speed) ?
                                         ^

ERROR: code indent should use tabs where possible
#3846: FILE: drivers/net/atl1e/atl1e_main.c:1058:
+                         MAC_CTRL_SPEED_1000 : MAC_CTRL_SPEED_10_100) <<$

ERROR: code indent should use tabs where possible
#3847: FILE: drivers/net/atl1e/atl1e_main.c:1059:
+                         MAC_CTRL_SPEED_SHIFT);$

WARNING: space prohibited between function name and open parenthesis '('
#3848: FILE: drivers/net/atl1e/atl1e_main.c:1060:
+       value |=3D (MAC_CTRL_TX_FLOW | MAC_CTRL_RX_FLOW);

ERROR: spaces required around that '|=' (ctx:WxV)
#3848: FILE: drivers/net/atl1e/atl1e_main.c:1060:
+       value |=3D (MAC_CTRL_TX_FLOW | MAC_CTRL_RX_FLOW);
              ^

WARNING: space prohibited between function name and open parenthesis '('
#3850: FILE: drivers/net/atl1e/atl1e_main.c:1062:
+       value |=3D (MAC_CTRL_ADD_CRC | MAC_CTRL_PAD);

ERROR: spaces required around that '|=' (ctx:WxV)
#3850: FILE: drivers/net/atl1e/atl1e_main.c:1062:
+       value |=3D (MAC_CTRL_ADD_CRC | MAC_CTRL_PAD);
              ^

WARNING: space prohibited between function name and open parenthesis '('
#3851: FILE: drivers/net/atl1e/atl1e_main.c:1063:
+       value |=3D (((u32)adapter->hw.preamble_len &

ERROR: spaces required around that '|=' (ctx:WxV)
#3851: FILE: drivers/net/atl1e/atl1e_main.c:1063:
+       value |=3D (((u32)adapter->hw.preamble_len &
              ^

ERROR: code indent should use tabs where possible
#3852: FILE: drivers/net/atl1e/atl1e_main.c:1064:
+                 MAC_CTRL_PRMLEN_MASK) << MAC_CTRL_PRMLEN_SHIFT);$

ERROR: code indent should use tabs where possible
#3855: FILE: drivers/net/atl1e/atl1e_main.c:1067:
+               value |=3D MAC_CTRL_RMV_VLAN;$

ERROR: spaces required around that '|=' (ctx:WxV)
#3855: FILE: drivers/net/atl1e/atl1e_main.c:1067:
+               value |=3D MAC_CTRL_RMV_VLAN;
                      ^

ERROR: spaces required around that '|=' (ctx:WxV)
#3857: FILE: drivers/net/atl1e/atl1e_main.c:1069:
+       value |=3D MAC_CTRL_BC_EN;
              ^

ERROR: code indent should use tabs where possible
#3859: FILE: drivers/net/atl1e/atl1e_main.c:1071:
+               value |=3D MAC_CTRL_PROMIS_EN;$

ERROR: spaces required around that '|=' (ctx:WxV)
#3859: FILE: drivers/net/atl1e/atl1e_main.c:1071:
+               value |=3D MAC_CTRL_PROMIS_EN;
                      ^

ERROR: code indent should use tabs where possible
#3861: FILE: drivers/net/atl1e/atl1e_main.c:1073:
+               value |=3D MAC_CTRL_MC_ALL_EN;$

ERROR: spaces required around that '|=' (ctx:WxV)
#3861: FILE: drivers/net/atl1e/atl1e_main.c:1073:
+               value |=3D MAC_CTRL_MC_ALL_EN;
                      ^

ERROR: spaces required around that '=' (ctx:WxV)
#3874: FILE: drivers/net/atl1e/atl1e_main.c:1086:
+       struct atl1e_hw *hw =3D &adapter->hw;
                            ^

ERROR: need consistent spacing around '&' (ctx:WxV)
#3874: FILE: drivers/net/atl1e/atl1e_main.c:1086:
+       struct atl1e_hw *hw =3D &adapter->hw;
                                ^

ERROR: spaces required around that '=' (ctx:WxV)
#3875: FILE: drivers/net/atl1e/atl1e_main.c:1087:
+       struct pci_dev *pdev =3D adapter->pdev;
                             ^

ERROR: spaces required around that '=' (ctx:WxV)
#3877: FILE: drivers/net/atl1e/atl1e_main.c:1089:
+       u32 intr_status_data =3D 0;
                             ^

ERROR: code indent should use tabs where possible
#3891: FILE: drivers/net/atl1e/atl1e_main.c:1103:
+        *    TPD Ring/SMB/RXF0 Page CMBs, they use the same$

ERROR: code indent should use tabs where possible
#3892: FILE: drivers/net/atl1e/atl1e_main.c:1104:
+        *    High 32bits memory */$

ERROR: code indent should use tabs where possible
#3899: FILE: drivers/net/atl1e/atl1e_main.c:1111:
+                       MASTER_CTRL_ITIMER_EN | MASTER_CTRL_ITIMER2_EN);$

ERROR: code indent should use tabs where possible
#3912: FILE: drivers/net/atl1e/atl1e_main.c:1124:
+                       VLAN_HLEN + ETH_FCS_LEN);$

ERROR: spaces required around that '=' (ctx:WxV)
#3926: FILE: drivers/net/atl1e/atl1e_main.c:1138:
+       intr_status_data =3D AT_READ_REG(hw, REG_ISR);
                         ^

ERROR: spaces required around that '!=' (ctx:WxV)
#3927: FILE: drivers/net/atl1e/atl1e_main.c:1139:
+       if (unlikely((intr_status_data & ISR_PHY_LINKDOWN) !=3D 0)) {
                                                           ^

ERROR: code indent should use tabs where possible
#3928: FILE: drivers/net/atl1e/atl1e_main.c:1140:
+               dev_err(&pdev->dev, "atl1e_configure failed,"$

ERROR: code indent should use tabs where possible
#3929: FILE: drivers/net/atl1e/atl1e_main.c:1141:
+                               "PCIE phy link down\n");$

ERROR: code indent should use tabs where possible
#3930: FILE: drivers/net/atl1e/atl1e_main.c:1142:
+               return -1;$

ERROR: spaces required around that '=' (ctx:WxV)
#3946: FILE: drivers/net/atl1e/atl1e_main.c:1158:
+       struct atl1e_adapter *adapter =3D netdev_priv(netdev);
                                      ^

ERROR: spaces required around that '=' (ctx:WxV)
#3947: FILE: drivers/net/atl1e/atl1e_main.c:1159:
+       struct atl1e_hw_stats  *hw_stats =3D &adapter->hw_stats;
                                         ^

ERROR: need consistent spacing around '&' (ctx:WxV)
#3947: FILE: drivers/net/atl1e/atl1e_main.c:1159:
+       struct atl1e_hw_stats  *hw_stats =3D &adapter->hw_stats;
                                             ^

ERROR: spaces required around that '=' (ctx:WxV)
#3948: FILE: drivers/net/atl1e/atl1e_main.c:1160:
+       struct net_device_stats *net_stats =3D &adapter->net_stats;
                                           ^

ERROR: need consistent spacing around '&' (ctx:WxV)
#3948: FILE: drivers/net/atl1e/atl1e_main.c:1160:
+       struct net_device_stats *net_stats =3D &adapter->net_stats;
                                               ^

ERROR: spaces required around that '=' (ctx:WxV)
#3950: FILE: drivers/net/atl1e/atl1e_main.c:1162:
+       net_stats->rx_packets =3D hw_stats->rx_ok;
                              ^

ERROR: spaces required around that '=' (ctx:WxV)
#3951: FILE: drivers/net/atl1e/atl1e_main.c:1163:
+       net_stats->tx_packets =3D hw_stats->tx_ok;
                              ^

ERROR: spaces required around that '=' (ctx:WxV)
#3952: FILE: drivers/net/atl1e/atl1e_main.c:1164:
+       net_stats->rx_bytes   =3D hw_stats->rx_byte_cnt;
                              ^

ERROR: spaces required around that '=' (ctx:WxV)
#3953: FILE: drivers/net/atl1e/atl1e_main.c:1165:
+       net_stats->tx_bytes   =3D hw_stats->tx_byte_cnt;
                              ^

ERROR: spaces required around that '=' (ctx:WxV)
#3954: FILE: drivers/net/atl1e/atl1e_main.c:1166:
+       net_stats->multicast  =3D hw_stats->rx_mcast;
                              ^

ERROR: spaces required around that '=' (ctx:WxV)
#3955: FILE: drivers/net/atl1e/atl1e_main.c:1167:
+       net_stats->collisions =3D hw_stats->tx_1_col +
                              ^

ERROR: code indent should use tabs where possible
#3956: FILE: drivers/net/atl1e/atl1e_main.c:1168:
+                               hw_stats->tx_2_col * 2 +$

ERROR: code indent should use tabs where possible
#3957: FILE: drivers/net/atl1e/atl1e_main.c:1169:
+                               hw_stats->tx_late_col + hw_stats->tx_abort_=$

ERROR: spaces required around that '=' (ctx:VxE)
#3957: FILE: drivers/net/atl1e/atl1e_main.c:1169:
+                               hw_stats->tx_late_col + hw_stats->tx_abort_=
                                                                           ^

ERROR: spaces required around that '=' (ctx:WxV)
#3960: FILE: drivers/net/atl1e/atl1e_main.c:1171:
+       net_stats->rx_errors  =3D hw_stats->rx_frag + hw_stats->rx_fcs_err =
                              ^

ERROR: code indent should use tabs where possible
#3962: FILE: drivers/net/atl1e/atl1e_main.c:1173:
+                               hw_stats->rx_len_err + hw_stats->rx_sz_ov +$

ERROR: code indent should use tabs where possible
#3963: FILE: drivers/net/atl1e/atl1e_main.c:1174:
+                               hw_stats->rx_rrd_ov + hw_stats->rx_align_er=$

ERROR: spaces required around that '=' (ctx:VxE)
#3963: FILE: drivers/net/atl1e/atl1e_main.c:1174:
+                               hw_stats->rx_rrd_ov + hw_stats->rx_align_er=
                                                                           ^

ERROR: spaces required around that '=' (ctx:WxV)
#3965: FILE: drivers/net/atl1e/atl1e_main.c:1175:
+       net_stats->rx_fifo_errors   =3D hw_stats->rx_rxf_ov;
                                    ^

ERROR: spaces required around that '=' (ctx:WxV)
#3966: FILE: drivers/net/atl1e/atl1e_main.c:1176:
+       net_stats->rx_length_errors =3D hw_stats->rx_len_err;
                                    ^

ERROR: spaces required around that '=' (ctx:WxV)
#3967: FILE: drivers/net/atl1e/atl1e_main.c:1177:
+       net_stats->rx_crc_errors    =3D hw_stats->rx_fcs_err;
                                    ^

ERROR: spaces required around that '=' (ctx:WxV)
#3968: FILE: drivers/net/atl1e/atl1e_main.c:1178:
+       net_stats->rx_frame_errors  =3D hw_stats->rx_align_err;
                                    ^

ERROR: spaces required around that '=' (ctx:WxV)
#3969: FILE: drivers/net/atl1e/atl1e_main.c:1179:
+       net_stats->rx_over_errors   =3D hw_stats->rx_rrd_ov + hw_stats->rx_=
                                    ^

ERROR: spaces required around that '=' (ctx:VxE)
#3969: FILE: drivers/net/atl1e/atl1e_main.c:1179:
+       net_stats->rx_over_errors   =3D hw_stats->rx_rrd_ov + hw_stats->rx_=
                                                                           ^

ERROR: spaces required around that '=' (ctx:WxV)
#3972: FILE: drivers/net/atl1e/atl1e_main.c:1181:
+       net_stats->rx_missed_errors =3D hw_stats->rx_rrd_ov + hw_stats->rx_=
                                    ^

ERROR: spaces required around that '=' (ctx:VxE)
#3972: FILE: drivers/net/atl1e/atl1e_main.c:1181:
+       net_stats->rx_missed_errors =3D hw_stats->rx_rrd_ov + hw_stats->rx_=
                                                                           ^

ERROR: spaces required around that '=' (ctx:WxV)
#3975: FILE: drivers/net/atl1e/atl1e_main.c:1183:
+       net_stats->tx_errors =3D hw_stats->tx_late_col + hw_stats->tx_abort=
                             ^

ERROR: spaces required around that '=' (ctx:VxE)
#3975: FILE: drivers/net/atl1e/atl1e_main.c:1183:
+       net_stats->tx_errors =3D hw_stats->tx_late_col + hw_stats->tx_abort=
                                                                           ^

ERROR: code indent should use tabs where possible
#3977: FILE: drivers/net/atl1e/atl1e_main.c:1184:
+                              hw_stats->tx_underrun + hw_stats->tx_trunc;$

ERROR: spaces required around that '=' (ctx:WxV)
#3978: FILE: drivers/net/atl1e/atl1e_main.c:1185:
+       net_stats->tx_fifo_errors    =3D hw_stats->tx_underrun;
                                     ^

ERROR: spaces required around that '=' (ctx:WxV)
#3979: FILE: drivers/net/atl1e/atl1e_main.c:1186:
+       net_stats->tx_aborted_errors =3D hw_stats->tx_abort_col;
                                     ^

ERROR: spaces required around that '=' (ctx:WxV)
#3980: FILE: drivers/net/atl1e/atl1e_main.c:1187:
+       net_stats->tx_window_errors  =3D hw_stats->tx_late_col;
                                     ^

ERROR: spaces required around that '=' (ctx:WxV)
#3987: FILE: drivers/net/atl1e/atl1e_main.c:1194:
+       u16 hw_reg_addr =3D 0;
                        ^

ERROR: spaces required around that '=' (ctx:WxV)
#3988: FILE: drivers/net/atl1e/atl1e_main.c:1195:
+       unsigned long *stats_item =3D NULL;
                                  ^

ERROR: spaces required around that '=' (ctx:WxV)
#3991: FILE: drivers/net/atl1e/atl1e_main.c:1198:
+       hw_reg_addr =3D REG_MAC_RX_STATUS_BIN;
                    ^

ERROR: spaces required around that '=' (ctx:WxV)
#3992: FILE: drivers/net/atl1e/atl1e_main.c:1199:
+       stats_item  =3D &adapter->hw_stats.rx_ok;
                    ^

ERROR: need consistent spacing around '&' (ctx:WxV)
#3992: FILE: drivers/net/atl1e/atl1e_main.c:1199:
+       stats_item  =3D &adapter->hw_stats.rx_ok;
                        ^

ERROR: spaces required around that '<=' (ctx:WxV)
#3993: FILE: drivers/net/atl1e/atl1e_main.c:1200:
+       while (hw_reg_addr <=3D REG_MAC_RX_STATUS_END) {
                           ^

ERROR: code indent should use tabs where possible
#3994: FILE: drivers/net/atl1e/atl1e_main.c:1201:
+               *stats_item +=3D AT_READ_REG(&adapter->hw, hw_reg_addr);$

ERROR: spaces required around that '+=' (ctx:WxV)
#3994: FILE: drivers/net/atl1e/atl1e_main.c:1201:
+               *stats_item +=3D AT_READ_REG(&adapter->hw, hw_reg_addr);
                            ^

ERROR: code indent should use tabs where possible
#3995: FILE: drivers/net/atl1e/atl1e_main.c:1202:
+               stats_item++;$

ERROR: code indent should use tabs where possible
#3996: FILE: drivers/net/atl1e/atl1e_main.c:1203:
+               hw_reg_addr +=3D 4;$

ERROR: spaces required around that '+=' (ctx:WxV)
#3996: FILE: drivers/net/atl1e/atl1e_main.c:1203:
+               hw_reg_addr +=3D 4;
                            ^

ERROR: spaces required around that '=' (ctx:WxV)
#3999: FILE: drivers/net/atl1e/atl1e_main.c:1206:
+       hw_reg_addr =3D REG_MAC_TX_STATUS_BIN;
                    ^

ERROR: spaces required around that '=' (ctx:WxV)
#4000: FILE: drivers/net/atl1e/atl1e_main.c:1207:
+       stats_item  =3D &adapter->hw_stats.tx_ok;
                    ^

ERROR: need consistent spacing around '&' (ctx:WxV)
#4000: FILE: drivers/net/atl1e/atl1e_main.c:1207:
+       stats_item  =3D &adapter->hw_stats.tx_ok;
                        ^

ERROR: spaces required around that '<=' (ctx:WxV)
#4001: FILE: drivers/net/atl1e/atl1e_main.c:1208:
+       while (hw_reg_addr <=3D REG_MAC_TX_STATUS_END) {
                           ^

ERROR: code indent should use tabs where possible
#4002: FILE: drivers/net/atl1e/atl1e_main.c:1209:
+               *stats_item +=3D AT_READ_REG(&adapter->hw, hw_reg_addr);$

ERROR: spaces required around that '+=' (ctx:WxV)
#4002: FILE: drivers/net/atl1e/atl1e_main.c:1209:
+               *stats_item +=3D AT_READ_REG(&adapter->hw, hw_reg_addr);
                            ^

ERROR: code indent should use tabs where possible
#4003: FILE: drivers/net/atl1e/atl1e_main.c:1210:
+               stats_item++;$

ERROR: code indent should use tabs where possible
#4004: FILE: drivers/net/atl1e/atl1e_main.c:1211:
+               hw_reg_addr +=3D 4;$

ERROR: spaces required around that '+=' (ctx:WxV)
#4004: FILE: drivers/net/atl1e/atl1e_main.c:1211:
+               hw_reg_addr +=3D 4;
                            ^

WARNING: space prohibited between function name and open parenthesis '('
#4019: FILE: drivers/net/atl1e/atl1e_main.c:1226:
+       struct atl1e_tx_ring *tx_ring =3D (struct atl1e_tx_ring *)

ERROR: spaces required around that '=' (ctx:WxV)
#4019: FILE: drivers/net/atl1e/atl1e_main.c:1226:
+       struct atl1e_tx_ring *tx_ring =3D (struct atl1e_tx_ring *)
                                      ^

ERROR: code indent should use tabs where possible
#4020: FILE: drivers/net/atl1e/atl1e_main.c:1227:
+                                       &adapter->tx_ring;$

ERROR: spaces required around that '=' (ctx:WxV)
#4021: FILE: drivers/net/atl1e/atl1e_main.c:1228:
+       struct atl1e_tx_buffer *tx_buffer =3D NULL;
                                          ^

ERROR: spaces required around that '=' (ctx:WxV)
#4022: FILE: drivers/net/atl1e/atl1e_main.c:1229:
+       u16 hw_next_to_clean =3D AT_READ_REGW(&adapter->hw, REG_TPD_CONS_ID=
                             ^

ERROR: spaces required around that '=' (ctx:VxE)
#4022: FILE: drivers/net/atl1e/atl1e_main.c:1229:
+       u16 hw_next_to_clean =3D AT_READ_REGW(&adapter->hw, REG_TPD_CONS_ID=
                                                                           ^

ERROR: spaces required around that '=' (ctx:WxV)
#4024: FILE: drivers/net/atl1e/atl1e_main.c:1230:
+       u16 next_to_clean =3D atomic_read(&tx_ring->next_to_clean);
                          ^

ERROR: spaces required around that '!=' (ctx:WxV)
#4026: FILE: drivers/net/atl1e/atl1e_main.c:1232:
+       while (next_to_clean !=3D hw_next_to_clean) {
                             ^

ERROR: code indent should use tabs where possible
#4027: FILE: drivers/net/atl1e/atl1e_main.c:1233:
+               tx_buffer =3D &tx_ring->tx_buffer[next_to_clean];$

ERROR: spaces required around that '=' (ctx:WxV)
#4027: FILE: drivers/net/atl1e/atl1e_main.c:1233:
+               tx_buffer =3D &tx_ring->tx_buffer[next_to_clean];
                          ^

ERROR: need consistent spacing around '&' (ctx:WxV)
#4027: FILE: drivers/net/atl1e/atl1e_main.c:1233:
+               tx_buffer =3D &tx_ring->tx_buffer[next_to_clean];
                              ^

ERROR: code indent should use tabs where possible
#4028: FILE: drivers/net/atl1e/atl1e_main.c:1234:
+               if (tx_buffer->dma) {$

ERROR: code indent should use tabs where possible
#4029: FILE: drivers/net/atl1e/atl1e_main.c:1235:
+                       pci_unmap_page(adapter->pdev, tx_buffer->dma,$

ERROR: code indent should use tabs where possible
#4030: FILE: drivers/net/atl1e/atl1e_main.c:1236:
+                                       tx_buffer->length, PCI_DMA_TODEVICE=$

ERROR: spaces required around that '=' (ctx:VxE)
#4030: FILE: drivers/net/atl1e/atl1e_main.c:1236:
+                                       tx_buffer->length, PCI_DMA_TODEVICE=
                                                                           ^

ERROR: code indent should use tabs where possible
#4032: FILE: drivers/net/atl1e/atl1e_main.c:1237:
+                       tx_buffer->dma =3D 0;$

ERROR: spaces required around that '=' (ctx:WxV)
#4032: FILE: drivers/net/atl1e/atl1e_main.c:1237:
+                       tx_buffer->dma =3D 0;
                                       ^

ERROR: code indent should use tabs where possible
#4033: FILE: drivers/net/atl1e/atl1e_main.c:1238:
+               }$

ERROR: code indent should use tabs where possible
#4035: FILE: drivers/net/atl1e/atl1e_main.c:1240:
+               if (tx_buffer->skb) {$

ERROR: code indent should use tabs where possible
#4036: FILE: drivers/net/atl1e/atl1e_main.c:1241:
+                       dev_kfree_skb_irq(tx_buffer->skb);$

ERROR: code indent should use tabs where possible
#4037: FILE: drivers/net/atl1e/atl1e_main.c:1242:
+                       tx_buffer->skb =3D NULL;$

ERROR: spaces required around that '=' (ctx:WxV)
#4037: FILE: drivers/net/atl1e/atl1e_main.c:1242:
+                       tx_buffer->skb =3D NULL;
                                       ^

ERROR: code indent should use tabs where possible
#4038: FILE: drivers/net/atl1e/atl1e_main.c:1243:
+               }$

ERROR: code indent should use tabs where possible
#4040: FILE: drivers/net/atl1e/atl1e_main.c:1245:
+               if (++next_to_clean =3D=3D tx_ring->count)$

ERROR: spaces required around that '=' (ctx:WxV)
#4040: FILE: drivers/net/atl1e/atl1e_main.c:1245:
+               if (++next_to_clean =3D=3D tx_ring->count)
                                    ^

ERROR: spaces required around that '=' (ctx:VxV)
#4040: FILE: drivers/net/atl1e/atl1e_main.c:1245:
+               if (++next_to_clean =3D=3D tx_ring->count)
                                       ^

ERROR: do not use assignment in if condition
#4040: FILE: drivers/net/atl1e/atl1e_main.c:1245:
+               if (++next_to_clean =3D=3D tx_ring->count)

ERROR: code indent should use tabs where possible
#4041: FILE: drivers/net/atl1e/atl1e_main.c:1246:
+                       next_to_clean =3D 0;$

ERROR: spaces required around that '=' (ctx:WxV)
#4041: FILE: drivers/net/atl1e/atl1e_main.c:1246:
+                       next_to_clean =3D 0;
                                      ^

ERROR: code indent should use tabs where possible
#4047: FILE: drivers/net/atl1e/atl1e_main.c:1252:
+                       netif_carrier_ok(adapter->netdev)) {$

ERROR: code indent should use tabs where possible
#4048: FILE: drivers/net/atl1e/atl1e_main.c:1253:
+               netif_wake_queue(adapter->netdev);$

ERROR: spaces required around that '=' (ctx:WxV)
#4062: FILE: drivers/net/atl1e/atl1e_main.c:1267:
+       struct net_device *netdev  =3D data;
                                   ^

ERROR: spaces required around that '=' (ctx:WxV)
#4063: FILE: drivers/net/atl1e/atl1e_main.c:1268:
+       struct atl1e_adapter *adapter =3D netdev_priv(netdev);
                                      ^

ERROR: spaces required around that '=' (ctx:WxV)
#4064: FILE: drivers/net/atl1e/atl1e_main.c:1269:
+       struct pci_dev *pdev =3D adapter->pdev;
                             ^

ERROR: spaces required around that '=' (ctx:WxV)
#4065: FILE: drivers/net/atl1e/atl1e_main.c:1270:
+       struct atl1e_hw *hw =3D &adapter->hw;
                            ^

ERROR: need consistent spacing around '&' (ctx:WxV)
#4065: FILE: drivers/net/atl1e/atl1e_main.c:1270:
+       struct atl1e_hw *hw =3D &adapter->hw;
                                ^

ERROR: spaces required around that '=' (ctx:WxV)
#4066: FILE: drivers/net/atl1e/atl1e_main.c:1271:
+       int max_ints =3D AT_MAX_INT_WORK;
                     ^

ERROR: spaces required around that '=' (ctx:WxV)
#4067: FILE: drivers/net/atl1e/atl1e_main.c:1272:
+       int handled =3D IRQ_NONE;
                    ^

ERROR: code indent should use tabs where possible
#4071: FILE: drivers/net/atl1e/atl1e_main.c:1276:
+               status =3D AT_READ_REG(hw, REG_ISR);$

ERROR: spaces required around that '=' (ctx:WxV)
#4071: FILE: drivers/net/atl1e/atl1e_main.c:1276:
+               status =3D AT_READ_REG(hw, REG_ISR);
                       ^

ERROR: code indent should use tabs where possible
#4072: FILE: drivers/net/atl1e/atl1e_main.c:1277:
+               if ((status & IMR_NORMAL_MASK) =3D=3D 0 ||$

ERROR: spaces required around that '=' (ctx:WxV)
#4072: FILE: drivers/net/atl1e/atl1e_main.c:1277:
+               if ((status & IMR_NORMAL_MASK) =3D=3D 0 ||
                                               ^

ERROR: spaces required around that '=' (ctx:VxV)
#4072: FILE: drivers/net/atl1e/atl1e_main.c:1277:
+               if ((status & IMR_NORMAL_MASK) =3D=3D 0 ||
                                                  ^

ERROR: do not use assignment in if condition
#4072: FILE: drivers/net/atl1e/atl1e_main.c:1277:
+               if ((status & IMR_NORMAL_MASK) =3D=3D 0 ||

ERROR: code indent should use tabs where possible
#4073: FILE: drivers/net/atl1e/atl1e_main.c:1278:
+                               (status & ISR_DIS_INT) !=3D 0) {$

ERROR: spaces required around that '!=' (ctx:WxV)
#4073: FILE: drivers/net/atl1e/atl1e_main.c:1278:
+                               (status & ISR_DIS_INT) !=3D 0) {
                                                       ^

ERROR: code indent should use tabs where possible
#4074: FILE: drivers/net/atl1e/atl1e_main.c:1279:
+                       if (max_ints !=3D AT_MAX_INT_WORK)$

ERROR: spaces required around that '!=' (ctx:WxV)
#4074: FILE: drivers/net/atl1e/atl1e_main.c:1279:
+                       if (max_ints !=3D AT_MAX_INT_WORK)
                                     ^

ERROR: code indent should use tabs where possible
#4075: FILE: drivers/net/atl1e/atl1e_main.c:1280:
+                               handled =3D IRQ_HANDLED;$

ERROR: spaces required around that '=' (ctx:WxV)
#4075: FILE: drivers/net/atl1e/atl1e_main.c:1280:
+                               handled =3D IRQ_HANDLED;
                                        ^

ERROR: code indent should use tabs where possible
#4076: FILE: drivers/net/atl1e/atl1e_main.c:1281:
+                       break;$

ERROR: code indent should use tabs where possible
#4077: FILE: drivers/net/atl1e/atl1e_main.c:1282:
+               }$

ERROR: code indent should use tabs where possible
#4078: FILE: drivers/net/atl1e/atl1e_main.c:1283:
+               /* link event */$

ERROR: code indent should use tabs where possible
#4079: FILE: drivers/net/atl1e/atl1e_main.c:1284:
+               if (status & ISR_GPHY)$

ERROR: code indent should use tabs where possible
#4080: FILE: drivers/net/atl1e/atl1e_main.c:1285:
+                       atl1e_clear_phy_int(adapter);$

ERROR: code indent should use tabs where possible
#4081: FILE: drivers/net/atl1e/atl1e_main.c:1286:
+               /* Ack ISR */$

ERROR: code indent should use tabs where possible
#4082: FILE: drivers/net/atl1e/atl1e_main.c:1287:
+               AT_WRITE_REG(hw, REG_ISR, status | ISR_DIS_INT);$

ERROR: code indent should use tabs where possible
#4084: FILE: drivers/net/atl1e/atl1e_main.c:1289:
+               handled =3D IRQ_HANDLED;$

ERROR: spaces required around that '=' (ctx:WxV)
#4084: FILE: drivers/net/atl1e/atl1e_main.c:1289:
+               handled =3D IRQ_HANDLED;
                        ^

ERROR: code indent should use tabs where possible
#4085: FILE: drivers/net/atl1e/atl1e_main.c:1290:
+               /* check if PCIE PHY Link down */$

ERROR: code indent should use tabs where possible
#4086: FILE: drivers/net/atl1e/atl1e_main.c:1291:
+               if (status & ISR_PHY_LINKDOWN) {$

ERROR: code indent should use tabs where possible
#4087: FILE: drivers/net/atl1e/atl1e_main.c:1292:
+                       dev_err(&pdev->dev,$

ERROR: code indent should use tabs where possible
#4088: FILE: drivers/net/atl1e/atl1e_main.c:1293:
+                               "pcie phy linkdown %x\n", status);$

ERROR: code indent should use tabs where possible
#4089: FILE: drivers/net/atl1e/atl1e_main.c:1294:
+                       if (netif_running(adapter->netdev)) {$

ERROR: code indent should use tabs where possible
#4090: FILE: drivers/net/atl1e/atl1e_main.c:1295:
+                               /* reset MAC */$

ERROR: code indent should use tabs where possible
#4091: FILE: drivers/net/atl1e/atl1e_main.c:1296:
+                               atl1e_irq_reset(adapter);$

ERROR: code indent should use tabs where possible
#4092: FILE: drivers/net/atl1e/atl1e_main.c:1297:
+                               schedule_work(&adapter->reset_task);$

ERROR: code indent should use tabs where possible
#4093: FILE: drivers/net/atl1e/atl1e_main.c:1298:
+                               break;$

ERROR: code indent should use tabs where possible
#4094: FILE: drivers/net/atl1e/atl1e_main.c:1299:
+                       }$

ERROR: code indent should use tabs where possible
#4095: FILE: drivers/net/atl1e/atl1e_main.c:1300:
+               }$

ERROR: code indent should use tabs where possible
#4097: FILE: drivers/net/atl1e/atl1e_main.c:1302:
+               /* check if DMA read/write error */$

ERROR: code indent should use tabs where possible
#4098: FILE: drivers/net/atl1e/atl1e_main.c:1303:
+               if (status & (ISR_DMAR_TO_RST | ISR_DMAW_TO_RST)) {$

ERROR: code indent should use tabs where possible
#4099: FILE: drivers/net/atl1e/atl1e_main.c:1304:
+                       dev_err(&pdev->dev,$

ERROR: code indent should use tabs where possible
#4100: FILE: drivers/net/atl1e/atl1e_main.c:1305:
+                               "PCIE DMA RW error (status =3D 0x%x)\n",$

ERROR: code indent should use tabs where possible
#4101: FILE: drivers/net/atl1e/atl1e_main.c:1306:
+                               status);$

ERROR: code indent should use tabs where possible
#4102: FILE: drivers/net/atl1e/atl1e_main.c:1307:
+                       atl1e_irq_reset(adapter);$

ERROR: code indent should use tabs where possible
#4103: FILE: drivers/net/atl1e/atl1e_main.c:1308:
+                       schedule_work(&adapter->reset_task);$

ERROR: code indent should use tabs where possible
#4104: FILE: drivers/net/atl1e/atl1e_main.c:1309:
+                       break;$

ERROR: code indent should use tabs where possible
#4105: FILE: drivers/net/atl1e/atl1e_main.c:1310:
+               }$

ERROR: code indent should use tabs where possible
#4107: FILE: drivers/net/atl1e/atl1e_main.c:1312:
+               if (status & ISR_SMB)$

ERROR: code indent should use tabs where possible
#4108: FILE: drivers/net/atl1e/atl1e_main.c:1313:
+                       atl1e_update_hw_stats(adapter);$

ERROR: code indent should use tabs where possible
#4110: FILE: drivers/net/atl1e/atl1e_main.c:1315:
+               /* link event */$

ERROR: code indent should use tabs where possible
#4111: FILE: drivers/net/atl1e/atl1e_main.c:1316:
+               if (status & (ISR_GPHY | ISR_MANUAL)) {$

ERROR: code indent should use tabs where possible
#4112: FILE: drivers/net/atl1e/atl1e_main.c:1317:
+                       adapter->net_stats.tx_carrier_errors++;$

ERROR: code indent should use tabs where possible
#4113: FILE: drivers/net/atl1e/atl1e_main.c:1318:
+                       atl1e_link_chg_event(adapter);$

ERROR: code indent should use tabs where possible
#4114: FILE: drivers/net/atl1e/atl1e_main.c:1319:
+                       break;$

ERROR: code indent should use tabs where possible
#4115: FILE: drivers/net/atl1e/atl1e_main.c:1320:
+               }$

ERROR: code indent should use tabs where possible
#4117: FILE: drivers/net/atl1e/atl1e_main.c:1322:
+               /* transmit event */$

ERROR: code indent should use tabs where possible
#4118: FILE: drivers/net/atl1e/atl1e_main.c:1323:
+               if (status & ISR_TX_EVENT)$

ERROR: code indent should use tabs where possible
#4119: FILE: drivers/net/atl1e/atl1e_main.c:1324:
+                       atl1e_clean_tx_irq(adapter);$

ERROR: code indent should use tabs where possible
#4121: FILE: drivers/net/atl1e/atl1e_main.c:1326:
+               if (status & ISR_RX_EVENT) {$

ERROR: code indent should use tabs where possible
#4122: FILE: drivers/net/atl1e/atl1e_main.c:1327:
+                       /*$

ERROR: code indent should use tabs where possible
#4123: FILE: drivers/net/atl1e/atl1e_main.c:1328:
+                        * disable rx interrupts, without$

ERROR: code indent should use tabs where possible
#4124: FILE: drivers/net/atl1e/atl1e_main.c:1329:
+                        * the synchronize_irq bit$

ERROR: code indent should use tabs where possible
#4125: FILE: drivers/net/atl1e/atl1e_main.c:1330:
+                        */$

ERROR: code indent should use tabs where possible
#4126: FILE: drivers/net/atl1e/atl1e_main.c:1331:
+                       AT_WRITE_REG(hw, REG_IMR,$

ERROR: code indent should use tabs where possible
#4127: FILE: drivers/net/atl1e/atl1e_main.c:1332:
+                                    IMR_NORMAL_MASK & ~ISR_RX_EVENT);$

ERROR: code indent should use tabs where possible
#4128: FILE: drivers/net/atl1e/atl1e_main.c:1333:
+                       AT_WRITE_FLUSH(hw);$

ERROR: code indent should use tabs where possible
#4129: FILE: drivers/net/atl1e/atl1e_main.c:1334:
+                       if (likely(netif_rx_schedule_prep(netdev,$

ERROR: code indent should use tabs where possible
#4130: FILE: drivers/net/atl1e/atl1e_main.c:1335:
+                                  &adapter->napi)))$

ERROR: code indent should use tabs where possible
#4131: FILE: drivers/net/atl1e/atl1e_main.c:1336:
+                               __netif_rx_schedule(netdev, &adapter->napi)=$

ERROR: spaces required around that '=' (ctx:VxE)
#4131: FILE: drivers/net/atl1e/atl1e_main.c:1336:
+                               __netif_rx_schedule(netdev, &adapter->napi)=
                                                                           ^

ERROR: code indent should use tabs where possible
#4133: FILE: drivers/net/atl1e/atl1e_main.c:1337:
+               }$

ERROR: code indent should use tabs where possible
#4142: FILE: drivers/net/atl1e/atl1e_main.c:1346:
+                 struct sk_buff *skb, struct atl1e_recv_ret_status *prrs)$

WARNING: space prohibited between function name and open parenthesis '('
#4144: FILE: drivers/net/atl1e/atl1e_main.c:1348:
+       u8 *packet =3D (u8 *)(prrs + 1);

ERROR: spaces required around that '=' (ctx:WxV)
#4144: FILE: drivers/net/atl1e/atl1e_main.c:1348:
+       u8 *packet =3D (u8 *)(prrs + 1);
                   ^

ERROR: spaces required around that '=' (ctx:WxV)
#4146: FILE: drivers/net/atl1e/atl1e_main.c:1350:
+       u16 head_len =3D ETH_HLEN;
                     ^

ERROR: spaces required around that '=' (ctx:WxV)
#4150: FILE: drivers/net/atl1e/atl1e_main.c:1354:
+       skb->ip_summed =3D CHECKSUM_NONE;
                       ^

ERROR: spaces required around that '=' (ctx:WxV)
#4151: FILE: drivers/net/atl1e/atl1e_main.c:1355:
+       pkt_flags =3D prrs->pkt_flag;
                  ^

ERROR: spaces required around that '=' (ctx:WxV)
#4152: FILE: drivers/net/atl1e/atl1e_main.c:1356:
+       err_flags =3D prrs->err_flag;
                  ^

ERROR: code indent should use tabs where possible
#4154: FILE: drivers/net/atl1e/atl1e_main.c:1358:
+               ((pkt_flags & RRS_IS_TCP) || (pkt_flags & RRS_IS_UDP))) {$

ERROR: code indent should use tabs where possible
#4155: FILE: drivers/net/atl1e/atl1e_main.c:1359:
+               if (pkt_flags & RRS_IS_IPV4) {$

ERROR: code indent should use tabs where possible
#4156: FILE: drivers/net/atl1e/atl1e_main.c:1360:
+                       if (pkt_flags & RRS_IS_802_3)$

ERROR: code indent should use tabs where possible
#4157: FILE: drivers/net/atl1e/atl1e_main.c:1361:
+                               head_len +=3D 8;$

ERROR: spaces required around that '+=' (ctx:WxV)
#4157: FILE: drivers/net/atl1e/atl1e_main.c:1361:
+                               head_len +=3D 8;
                                         ^

ERROR: code indent should use tabs where possible
#4158: FILE: drivers/net/atl1e/atl1e_main.c:1362:
+                       iph =3D (struct iphdr *) (packet + head_len);$

WARNING: space prohibited between function name and open parenthesis '('
#4158: FILE: drivers/net/atl1e/atl1e_main.c:1362:
+                       iph =3D (struct iphdr *) (packet + head_len);

ERROR: spaces required around that '=' (ctx:WxV)
#4158: FILE: drivers/net/atl1e/atl1e_main.c:1362:
+                       iph =3D (struct iphdr *) (packet + head_len);
                            ^

ERROR: code indent should use tabs where possible
#4159: FILE: drivers/net/atl1e/atl1e_main.c:1363:
+                       if (iph->frag_off !=3D 0 && !(pkt_flags & RRS_IS_IP=$

ERROR: spaces required around that '!=' (ctx:WxV)
#4159: FILE: drivers/net/atl1e/atl1e_main.c:1363:
+                       if (iph->frag_off !=3D 0 && !(pkt_flags & RRS_IS_IP=
                                          ^

ERROR: spaces required around that '=' (ctx:VxE)
#4159: FILE: drivers/net/atl1e/atl1e_main.c:1363:
+                       if (iph->frag_off !=3D 0 && !(pkt_flags & RRS_IS_IP=
                                                                           ^

ERROR: do not use assignment in if condition
#4159: FILE: drivers/net/atl1e/atl1e_main.c:1363:
+                       if (iph->frag_off !=3D 0 && !(pkt_flags & RRS_IS_IP=

ERROR: code indent should use tabs where possible
#4161: FILE: drivers/net/atl1e/atl1e_main.c:1364:
+                               goto hw_xsum;$

ERROR: code indent should use tabs where possible
#4162: FILE: drivers/net/atl1e/atl1e_main.c:1365:
+               }$

ERROR: code indent should use tabs where possible
#4163: FILE: drivers/net/atl1e/atl1e_main.c:1366:
+               if (!(err_flags & (RRS_ERR_IP_CSUM | RRS_ERR_L4_CSUM))) {$

ERROR: code indent should use tabs where possible
#4164: FILE: drivers/net/atl1e/atl1e_main.c:1367:
+                       skb->ip_summed =3D CHECKSUM_UNNECESSARY;$

ERROR: spaces required around that '=' (ctx:WxV)
#4164: FILE: drivers/net/atl1e/atl1e_main.c:1367:
+                       skb->ip_summed =3D CHECKSUM_UNNECESSARY;
                                       ^

ERROR: code indent should use tabs where possible
#4165: FILE: drivers/net/atl1e/atl1e_main.c:1368:
+                       return;$

ERROR: code indent should use tabs where possible
#4166: FILE: drivers/net/atl1e/atl1e_main.c:1369:
+               }$

ERROR: spaces required around that '=' (ctx:VxE)
#4173: FILE: drivers/net/atl1e/atl1e_main.c:1376:
+static struct atl1e_rx_page *atl1e_get_rx_page(struct atl1e_adapter *adapt=
                                                                           ^

ERROR: code indent should use tabs where possible
#4175: FILE: drivers/net/atl1e/atl1e_main.c:1377:
+                                              u8 que)$

ERROR: spaces required around that '=' (ctx:WxV)
#4177: FILE: drivers/net/atl1e/atl1e_main.c:1379:
+       struct atl1e_rx_page_desc *rx_page_desc =3D
                                                ^

ERROR: code indent should use tabs where possible
#4178: FILE: drivers/net/atl1e/atl1e_main.c:1380:
+               (struct atl1e_rx_page_desc *) adapter->rx_ring.rx_page_desc=$

ERROR: spaces required around that '=' (ctx:VxE)
#4178: FILE: drivers/net/atl1e/atl1e_main.c:1380:
+               (struct atl1e_rx_page_desc *) adapter->rx_ring.rx_page_desc=
                                                                           ^

ERROR: spaces required around that '=' (ctx:WxV)
#4180: FILE: drivers/net/atl1e/atl1e_main.c:1381:
+       u8 rx_using =3D rx_page_desc[que].rx_using;
                    ^

ERROR: spaces required around that '=' (ctx:VxE)
#4182: FILE: drivers/net/atl1e/atl1e_main.c:1383:
+       return (struct atl1e_rx_page *)&(rx_page_desc[que].rx_page[rx_using=
                                                                           ^

ERROR: code indent should use tabs where possible
#4187: FILE: drivers/net/atl1e/atl1e_main.c:1387:
+                  int *work_done, int work_to_do)$

ERROR: spaces required around that '=' (ctx:WxV)
#4189: FILE: drivers/net/atl1e/atl1e_main.c:1389:
+       struct pci_dev *pdev =3D adapter->pdev;
                             ^

ERROR: spaces required around that '=' (ctx:WxV)
#4190: FILE: drivers/net/atl1e/atl1e_main.c:1390:
+       struct net_device *netdev  =3D adapter->netdev;
                                   ^

WARNING: space prohibited between function name and open parenthesis '('
#4191: FILE: drivers/net/atl1e/atl1e_main.c:1391:
+       struct atl1e_rx_ring *rx_ring =3D (struct atl1e_rx_ring *)

ERROR: spaces required around that '=' (ctx:WxV)
#4191: FILE: drivers/net/atl1e/atl1e_main.c:1391:
+       struct atl1e_rx_ring *rx_ring =3D (struct atl1e_rx_ring *)
                                      ^

ERROR: code indent should use tabs where possible
#4192: FILE: drivers/net/atl1e/atl1e_main.c:1392:
+                                        &adapter->rx_ring;$

ERROR: spaces required around that '=' (ctx:WxV)
#4193: FILE: drivers/net/atl1e/atl1e_main.c:1393:
+       struct atl1e_rx_page_desc *rx_page_desc =3D
                                                ^

ERROR: code indent should use tabs where possible
#4194: FILE: drivers/net/atl1e/atl1e_main.c:1394:
+               (struct atl1e_rx_page_desc *) rx_ring->rx_page_desc;$

ERROR: spaces required around that '=' (ctx:WxV)
#4195: FILE: drivers/net/atl1e/atl1e_main.c:1395:
+       struct sk_buff *skb =3D NULL;
                            ^

ERROR: spaces required around that '=' (ctx:WxV)
#4196: FILE: drivers/net/atl1e/atl1e_main.c:1396:
+       struct atl1e_rx_page *rx_page =3D atl1e_get_rx_page(adapter, que);
                                      ^

ERROR: spaces required around that '=' (ctx:WxV)
#4200: FILE: drivers/net/atl1e/atl1e_main.c:1400:
+       write_offset =3D *(rx_page->write_offset_addr);
                     ^

ERROR: need consistent spacing around '*' (ctx:WxV)
#4200: FILE: drivers/net/atl1e/atl1e_main.c:1400:
+       write_offset =3D *(rx_page->write_offset_addr);
                         ^

ERROR: code indent should use tabs where possible
#4202: FILE: drivers/net/atl1e/atl1e_main.c:1402:
+               do {$

ERROR: code indent should use tabs where possible
#4203: FILE: drivers/net/atl1e/atl1e_main.c:1403:
+                       if (*work_done >=3D work_to_do)$

ERROR: spaces required around that '>=' (ctx:WxV)
#4203: FILE: drivers/net/atl1e/atl1e_main.c:1403:
+                       if (*work_done >=3D work_to_do)
                                       ^

ERROR: code indent should use tabs where possible
#4204: FILE: drivers/net/atl1e/atl1e_main.c:1404:
+                               break;$

ERROR: code indent should use tabs where possible
#4205: FILE: drivers/net/atl1e/atl1e_main.c:1405:
+                       (*work_done)++;$

ERROR: code indent should use tabs where possible
#4206: FILE: drivers/net/atl1e/atl1e_main.c:1406:
+                       /* get new packet's  rrs */$

ERROR: code indent should use tabs where possible
#4207: FILE: drivers/net/atl1e/atl1e_main.c:1407:
+                       prrs =3D (struct atl1e_recv_ret_status *) (rx_page-=$

WARNING: space prohibited between function name and open parenthesis '('
#4207: FILE: drivers/net/atl1e/atl1e_main.c:1407:
+                       prrs =3D (struct atl1e_recv_ret_status *) (rx_page-=

ERROR: spaces required around that '=' (ctx:WxV)
#4207: FILE: drivers/net/atl1e/atl1e_main.c:1407:
+                       prrs =3D (struct atl1e_recv_ret_status *) (rx_page-=
                             ^

ERROR: spaces required around that '-=' (ctx:VxE)
#4207: FILE: drivers/net/atl1e/atl1e_main.c:1407:
+                       prrs =3D (struct atl1e_recv_ret_status *) (rx_page-=
                                                                          ^

ERROR: code indent should use tabs where possible
#4209: FILE: drivers/net/atl1e/atl1e_main.c:1408:
+                                                rx_page->read_offset);$

ERROR: code indent should use tabs where possible
#4210: FILE: drivers/net/atl1e/atl1e_main.c:1409:
+                       /* check sequence number */$

ERROR: code indent should use tabs where possible
#4211: FILE: drivers/net/atl1e/atl1e_main.c:1410:
+                       if (prrs->seq_num !=3D rx_page_desc[que].rx_nxseq) =$

ERROR: spaces required around that '!=' (ctx:WxV)
#4211: FILE: drivers/net/atl1e/atl1e_main.c:1410:
+                       if (prrs->seq_num !=3D rx_page_desc[que].rx_nxseq) =
                                          ^

ERROR: trailing statements should be on next line
#4211: FILE: drivers/net/atl1e/atl1e_main.c:1410:
+                       if (prrs->seq_num !=3D rx_page_desc[que].rx_nxseq) =

ERROR: code indent should use tabs where possible
#4213: FILE: drivers/net/atl1e/atl1e_main.c:1411:
+                               dev_err(&pdev->dev,$

ERROR: code indent should use tabs where possible
#4214: FILE: drivers/net/atl1e/atl1e_main.c:1412:
+                                       "rx sequence number"$

ERROR: code indent should use tabs where possible
#4215: FILE: drivers/net/atl1e/atl1e_main.c:1413:
+                                       " error (rx=3D%d) (expect=3D%d)\n",$

ERROR: code indent should use tabs where possible
#4216: FILE: drivers/net/atl1e/atl1e_main.c:1414:
+                                       prrs->seq_num,$

ERROR: code indent should use tabs where possible
#4217: FILE: drivers/net/atl1e/atl1e_main.c:1415:
+                                       rx_page_desc[que].rx_nxseq);$

ERROR: code indent should use tabs where possible
#4218: FILE: drivers/net/atl1e/atl1e_main.c:1416:
+                               rx_page_desc[que].rx_nxseq++;$

ERROR: code indent should use tabs where possible
#4219: FILE: drivers/net/atl1e/atl1e_main.c:1417:
+                               /* just for debug use */$

ERROR: code indent should use tabs where possible
#4220: FILE: drivers/net/atl1e/atl1e_main.c:1418:
+                               AT_WRITE_REG(&adapter->hw, REG_DEBUG_DATA0,$

ERROR: code indent should use tabs where possible
#4221: FILE: drivers/net/atl1e/atl1e_main.c:1419:
+                                            (((u32)prrs->seq_num) << 16) |$

ERROR: code indent should use tabs where possible
#4222: FILE: drivers/net/atl1e/atl1e_main.c:1420:
+                                            rx_page_desc[que].rx_nxseq);$

ERROR: code indent should use tabs where possible
#4223: FILE: drivers/net/atl1e/atl1e_main.c:1421:
+                               goto fatal_err;$

ERROR: code indent should use tabs where possible
#4224: FILE: drivers/net/atl1e/atl1e_main.c:1422:
+                       }$

ERROR: code indent should use tabs where possible
#4225: FILE: drivers/net/atl1e/atl1e_main.c:1423:
+                       rx_page_desc[que].rx_nxseq++;$

ERROR: code indent should use tabs where possible
#4227: FILE: drivers/net/atl1e/atl1e_main.c:1425:
+                       /* error packet */$

ERROR: code indent should use tabs where possible
#4228: FILE: drivers/net/atl1e/atl1e_main.c:1426:
+                       if (prrs->pkt_flag & RRS_IS_ERR_FRAME) {$

ERROR: code indent should use tabs where possible
#4229: FILE: drivers/net/atl1e/atl1e_main.c:1427:
+                               if (prrs->err_flag & (RRS_ERR_BAD_CRC |$

ERROR: code indent should use tabs where possible
#4230: FILE: drivers/net/atl1e/atl1e_main.c:1428:
+                                       RRS_ERR_DRIBBLE | RRS_ERR_CODE |$

ERROR: code indent should use tabs where possible
#4231: FILE: drivers/net/atl1e/atl1e_main.c:1429:
+                                       RRS_ERR_TRUNC)) {$

ERROR: code indent should use tabs where possible
#4232: FILE: drivers/net/atl1e/atl1e_main.c:1430:
+                               /* hardware error, discard this packet*/$

ERROR: code indent should use tabs where possible
#4233: FILE: drivers/net/atl1e/atl1e_main.c:1431:
+                                       dev_err(&pdev->dev,$

ERROR: code indent should use tabs where possible
#4234: FILE: drivers/net/atl1e/atl1e_main.c:1432:
+                                               "rx packet desc error %x\n"=$

ERROR: spaces required around that '=' (ctx:VxE)
#4234: FILE: drivers/net/atl1e/atl1e_main.c:1432:
+                                               "rx packet desc error %x\n"=
                                                                           ^

ERROR: code indent should use tabs where possible
#4236: FILE: drivers/net/atl1e/atl1e_main.c:1433:
+                                               *((u32 *)prrs + 1));$

ERROR: code indent should use tabs where possible
#4237: FILE: drivers/net/atl1e/atl1e_main.c:1434:
+                                       goto skip_pkt;$

ERROR: code indent should use tabs where possible
#4238: FILE: drivers/net/atl1e/atl1e_main.c:1435:
+                               }$

ERROR: code indent should use tabs where possible
#4239: FILE: drivers/net/atl1e/atl1e_main.c:1436:
+                       }$

ERROR: code indent should use tabs where possible
#4241: FILE: drivers/net/atl1e/atl1e_main.c:1438:
+                       packet_size =3D ((prrs->word1 >> RRS_PKT_SIZE_SHIFT=$

WARNING: space prohibited between function name and open parenthesis '('
#4241: FILE: drivers/net/atl1e/atl1e_main.c:1438:
+                       packet_size =3D ((prrs->word1 >> RRS_PKT_SIZE_SHIFT=

ERROR: spaces required around that '=' (ctx:WxV)
#4241: FILE: drivers/net/atl1e/atl1e_main.c:1438:
+                       packet_size =3D ((prrs->word1 >> RRS_PKT_SIZE_SHIFT=
                                    ^

ERROR: spaces required around that '=' (ctx:VxE)
#4241: FILE: drivers/net/atl1e/atl1e_main.c:1438:
+                       packet_size =3D ((prrs->word1 >> RRS_PKT_SIZE_SHIFT=
                                                                           ^

ERROR: code indent should use tabs where possible
#4243: FILE: drivers/net/atl1e/atl1e_main.c:1439:
+                                       RRS_PKT_SIZE_MASK) - 4; /* CRC */$

ERROR: code indent should use tabs where possible
#4244: FILE: drivers/net/atl1e/atl1e_main.c:1440:
+                       skb =3D netdev_alloc_skb(netdev,$

ERROR: spaces required around that '=' (ctx:WxV)
#4244: FILE: drivers/net/atl1e/atl1e_main.c:1440:
+                       skb =3D netdev_alloc_skb(netdev,
                            ^

ERROR: code indent should use tabs where possible
#4245: FILE: drivers/net/atl1e/atl1e_main.c:1441:
+                                              packet_size + NET_IP_ALIGN);$

ERROR: code indent should use tabs where possible
#4246: FILE: drivers/net/atl1e/atl1e_main.c:1442:
+                       if (skb =3D=3D NULL) {$

ERROR: spaces required around that '=' (ctx:WxV)
#4246: FILE: drivers/net/atl1e/atl1e_main.c:1442:
+                       if (skb =3D=3D NULL) {
                                ^

ERROR: spaces required around that '=' (ctx:VxV)
#4246: FILE: drivers/net/atl1e/atl1e_main.c:1442:
+                       if (skb =3D=3D NULL) {
                                   ^

ERROR: do not use assignment in if condition
#4246: FILE: drivers/net/atl1e/atl1e_main.c:1442:
+                       if (skb =3D=3D NULL) {

ERROR: code indent should use tabs where possible
#4247: FILE: drivers/net/atl1e/atl1e_main.c:1443:
+                               dev_warn(&pdev->dev, "%s: Memory squeeze,"$

ERROR: code indent should use tabs where possible
#4248: FILE: drivers/net/atl1e/atl1e_main.c:1444:
+                                       "deferring packet.\n", netdev->name=$

ERROR: spaces required around that '=' (ctx:VxE)
#4248: FILE: drivers/net/atl1e/atl1e_main.c:1444:
+                                       "deferring packet.\n", netdev->name=
                                                                           ^

ERROR: code indent should use tabs where possible
#4250: FILE: drivers/net/atl1e/atl1e_main.c:1445:
+                               goto skip_pkt;$

ERROR: code indent should use tabs where possible
#4251: FILE: drivers/net/atl1e/atl1e_main.c:1446:
+                       }$

ERROR: code indent should use tabs where possible
#4252: FILE: drivers/net/atl1e/atl1e_main.c:1447:
+                       skb_reserve(skb, NET_IP_ALIGN);$

ERROR: code indent should use tabs where possible
#4253: FILE: drivers/net/atl1e/atl1e_main.c:1448:
+                       skb->dev =3D netdev;$

ERROR: spaces required around that '=' (ctx:WxV)
#4253: FILE: drivers/net/atl1e/atl1e_main.c:1448:
+                       skb->dev =3D netdev;
                                 ^

ERROR: code indent should use tabs where possible
#4254: FILE: drivers/net/atl1e/atl1e_main.c:1449:
+                       memcpy(skb->data, (u8 *)(prrs + 1), packet_size);$

ERROR: code indent should use tabs where possible
#4255: FILE: drivers/net/atl1e/atl1e_main.c:1450:
+                       skb_put(skb, packet_size);$

ERROR: code indent should use tabs where possible
#4256: FILE: drivers/net/atl1e/atl1e_main.c:1451:
+                       skb->protocol =3D eth_type_trans(skb, netdev);$

ERROR: spaces required around that '=' (ctx:WxV)
#4256: FILE: drivers/net/atl1e/atl1e_main.c:1451:
+                       skb->protocol =3D eth_type_trans(skb, netdev);
                                      ^

ERROR: code indent should use tabs where possible
#4257: FILE: drivers/net/atl1e/atl1e_main.c:1452:
+                       atl1e_rx_checksum(adapter, skb, prrs);$

ERROR: code indent should use tabs where possible
#4259: FILE: drivers/net/atl1e/atl1e_main.c:1454:
+                       if (unlikely(adapter->vlgrp &&$

ERROR: code indent should use tabs where possible
#4260: FILE: drivers/net/atl1e/atl1e_main.c:1455:
+                               (prrs->pkt_flag & RRS_IS_VLAN_TAG))) {$

ERROR: code indent should use tabs where possible
#4261: FILE: drivers/net/atl1e/atl1e_main.c:1456:
+                               u16 vlan_tag =3D (prrs->vtag >> 4) |$

WARNING: space prohibited between function name and open parenthesis '('
#4261: FILE: drivers/net/atl1e/atl1e_main.c:1456:
+                               u16 vlan_tag =3D (prrs->vtag >> 4) |

ERROR: spaces required around that '=' (ctx:WxV)
#4261: FILE: drivers/net/atl1e/atl1e_main.c:1456:
+                               u16 vlan_tag =3D (prrs->vtag >> 4) |
                                             ^

ERROR: code indent should use tabs where possible
#4262: FILE: drivers/net/atl1e/atl1e_main.c:1457:
+                                              ((prrs->vtag & 7) << 13) |$

ERROR: code indent should use tabs where possible
#4263: FILE: drivers/net/atl1e/atl1e_main.c:1458:
+                                              ((prrs->vtag & 8) << 9);$

ERROR: code indent should use tabs where possible
#4264: FILE: drivers/net/atl1e/atl1e_main.c:1459:
+                               dev_dbg(&pdev->dev,$

ERROR: code indent should use tabs where possible
#4265: FILE: drivers/net/atl1e/atl1e_main.c:1460:
+                                       "RXD VLAN TAG<RRD>=3D0x%04x\n",$

ERROR: code indent should use tabs where possible
#4266: FILE: drivers/net/atl1e/atl1e_main.c:1461:
+                                       prrs->vtag);$

ERROR: code indent should use tabs where possible
#4267: FILE: drivers/net/atl1e/atl1e_main.c:1462:
+                               vlan_hwaccel_receive_skb(skb, adapter->vlgr=$

ERROR: spaces required around that '=' (ctx:VxE)
#4267: FILE: drivers/net/atl1e/atl1e_main.c:1462:
+                               vlan_hwaccel_receive_skb(skb, adapter->vlgr=
                                                                           ^

ERROR: code indent should use tabs where possible
#4269: FILE: drivers/net/atl1e/atl1e_main.c:1463:
+                                                        vlan_tag);$

ERROR: code indent should use tabs where possible
#4270: FILE: drivers/net/atl1e/atl1e_main.c:1464:
+                       } else {$

ERROR: code indent should use tabs where possible
#4271: FILE: drivers/net/atl1e/atl1e_main.c:1465:
+                               netif_receive_skb(skb);$

ERROR: code indent should use tabs where possible
#4272: FILE: drivers/net/atl1e/atl1e_main.c:1466:
+                       }$

ERROR: code indent should use tabs where possible
#4274: FILE: drivers/net/atl1e/atl1e_main.c:1468:
+                       netdev->last_rx =3D jiffies;$

ERROR: spaces required around that '=' (ctx:WxV)
#4274: FILE: drivers/net/atl1e/atl1e_main.c:1468:
+                       netdev->last_rx =3D jiffies;
                                        ^

ERROR: code indent should use tabs where possible
#4278: FILE: drivers/net/atl1e/atl1e_main.c:1472:
+                       rx_page->read_offset +=3D$

ERROR: spaces required around that '+=' (ctx:WxV)
#4278: FILE: drivers/net/atl1e/atl1e_main.c:1472:
+                       rx_page->read_offset +=3D
                                             ^

ERROR: code indent should use tabs where possible
#4279: FILE: drivers/net/atl1e/atl1e_main.c:1473:
+                               (((u32)((prrs->word1 >> RRS_PKT_SIZE_SHIFT)=$

ERROR: spaces required around that '=' (ctx:VxE)
#4279: FILE: drivers/net/atl1e/atl1e_main.c:1473:
+                               (((u32)((prrs->word1 >> RRS_PKT_SIZE_SHIFT)=
                                                                           ^

ERROR: code indent should use tabs where possible
#4281: FILE: drivers/net/atl1e/atl1e_main.c:1475:
+                               RRS_PKT_SIZE_MASK) +$

ERROR: code indent should use tabs where possible
#4282: FILE: drivers/net/atl1e/atl1e_main.c:1476:
+                               sizeof(struct atl1e_recv_ret_status) + 31) =$

ERROR: code indent should use tabs where possible
#4284: FILE: drivers/net/atl1e/atl1e_main.c:1477:
+                                               0xFFFFFFE0);$

ERROR: code indent should use tabs where possible
#4286: FILE: drivers/net/atl1e/atl1e_main.c:1479:
+                       if (rx_page->read_offset >=3D rx_ring->page_size) {$

ERROR: spaces required around that '>=' (ctx:WxV)
#4286: FILE: drivers/net/atl1e/atl1e_main.c:1479:
+                       if (rx_page->read_offset >=3D rx_ring->page_size) {
                                                 ^

ERROR: code indent should use tabs where possible
#4287: FILE: drivers/net/atl1e/atl1e_main.c:1480:
+                               /* mark this page clean */$

ERROR: code indent should use tabs where possible
#4288: FILE: drivers/net/atl1e/atl1e_main.c:1481:
+                               u16 reg_addr;$

ERROR: code indent should use tabs where possible
#4289: FILE: drivers/net/atl1e/atl1e_main.c:1482:
+                               u8  rx_using;$

ERROR: code indent should use tabs where possible
#4291: FILE: drivers/net/atl1e/atl1e_main.c:1484:
+                               rx_page->read_offset =3D$

ERROR: spaces required around that '=' (ctx:WxV)
#4291: FILE: drivers/net/atl1e/atl1e_main.c:1484:
+                               rx_page->read_offset =3D
                                                     ^

ERROR: code indent should use tabs where possible
#4292: FILE: drivers/net/atl1e/atl1e_main.c:1485:
+                                       *(rx_page->write_offset_addr) =3D 0=$

ERROR: spaces required around that '=' (ctx:WxV)
#4292: FILE: drivers/net/atl1e/atl1e_main.c:1485:
+                                       *(rx_page->write_offset_addr) =3D 0=
                                                                      ^

ERROR: spaces required around that '=' (ctx:VxE)
#4292: FILE: drivers/net/atl1e/atl1e_main.c:1485:
+                                       *(rx_page->write_offset_addr) =3D 0=
                                                                           ^

ERROR: code indent should use tabs where possible
#4294: FILE: drivers/net/atl1e/atl1e_main.c:1486:
+                               rx_using =3D rx_page_desc[que].rx_using;$

ERROR: spaces required around that '=' (ctx:WxV)
#4294: FILE: drivers/net/atl1e/atl1e_main.c:1486:
+                               rx_using =3D rx_page_desc[que].rx_using;
                                         ^

ERROR: code indent should use tabs where possible
#4295: FILE: drivers/net/atl1e/atl1e_main.c:1487:
+                               reg_addr =3D$

ERROR: spaces required around that '=' (ctx:WxV)
#4295: FILE: drivers/net/atl1e/atl1e_main.c:1487:
+                               reg_addr =3D
                                         ^

ERROR: code indent should use tabs where possible
#4296: FILE: drivers/net/atl1e/atl1e_main.c:1488:
+                                       atl1e_rx_page_vld_regs[que][rx_usin=$

ERROR: spaces required around that '=' (ctx:VxE)
#4296: FILE: drivers/net/atl1e/atl1e_main.c:1488:
+                                       atl1e_rx_page_vld_regs[que][rx_usin=
                                                                           ^

ERROR: code indent should use tabs where possible
#4298: FILE: drivers/net/atl1e/atl1e_main.c:1489:
+                               AT_WRITE_REGB(&adapter->hw, reg_addr, 1);$

ERROR: code indent should use tabs where possible
#4299: FILE: drivers/net/atl1e/atl1e_main.c:1490:
+                               rx_page_desc[que].rx_using ^=3D 1;$

ERROR: spaces required around that '^=' (ctx:WxV)
#4299: FILE: drivers/net/atl1e/atl1e_main.c:1490:
+                               rx_page_desc[que].rx_using ^=3D 1;
                                                           ^

ERROR: code indent should use tabs where possible
#4300: FILE: drivers/net/atl1e/atl1e_main.c:1491:
+                               rx_page =3D atl1e_get_rx_page(adapter, que)=$

ERROR: spaces required around that '=' (ctx:WxV)
#4300: FILE: drivers/net/atl1e/atl1e_main.c:1491:
+                               rx_page =3D atl1e_get_rx_page(adapter, que)=
                                        ^

ERROR: spaces required around that '=' (ctx:VxE)
#4300: FILE: drivers/net/atl1e/atl1e_main.c:1491:
+                               rx_page =3D atl1e_get_rx_page(adapter, que)=
                                                                           ^

ERROR: code indent should use tabs where possible
#4302: FILE: drivers/net/atl1e/atl1e_main.c:1492:
+                       }$

ERROR: code indent should use tabs where possible
#4303: FILE: drivers/net/atl1e/atl1e_main.c:1493:
+                       write_offset =3D *(rx_page->write_offset_addr);$

ERROR: spaces required around that '=' (ctx:WxV)
#4303: FILE: drivers/net/atl1e/atl1e_main.c:1493:
+                       write_offset =3D *(rx_page->write_offset_addr);
                                     ^

ERROR: need consistent spacing around '*' (ctx:WxV)
#4303: FILE: drivers/net/atl1e/atl1e_main.c:1493:
+                       write_offset =3D *(rx_page->write_offset_addr);
                                         ^

ERROR: code indent should use tabs where possible
#4304: FILE: drivers/net/atl1e/atl1e_main.c:1494:
+               } while (rx_page->read_offset < write_offset);$

ERROR: code indent should use tabs where possible
#4312: FILE: drivers/net/atl1e/atl1e_main.c:1502:
+               schedule_work(&adapter->reset_task);$

ERROR: spaces required around that '=' (ctx:WxV)
#4320: FILE: drivers/net/atl1e/atl1e_main.c:1510:
+       struct atl1e_adapter *adapter =3D
                                      ^

ERROR: code indent should use tabs where possible
#4321: FILE: drivers/net/atl1e/atl1e_main.c:1511:
+                       container_of(napi, struct atl1e_adapter, napi);$

ERROR: spaces required around that '=' (ctx:WxV)
#4322: FILE: drivers/net/atl1e/atl1e_main.c:1512:
+       struct net_device *netdev  =3D adapter->netdev;
                                   ^

ERROR: spaces required around that '=' (ctx:WxV)
#4323: FILE: drivers/net/atl1e/atl1e_main.c:1513:
+       struct pci_dev    *pdev    =3D adapter->pdev;
                                   ^

ERROR: spaces required around that '=' (ctx:WxV)
#4325: FILE: drivers/net/atl1e/atl1e_main.c:1515:
+       int work_done =3D 0;
                      ^

ERROR: code indent should use tabs where possible
#4329: FILE: drivers/net/atl1e/atl1e_main.c:1519:
+               goto quit_polling;$

ERROR: code indent should use tabs where possible
#4336: FILE: drivers/net/atl1e/atl1e_main.c:1526:
+               netif_rx_complete(netdev, napi);$

ERROR: code indent should use tabs where possible
#4337: FILE: drivers/net/atl1e/atl1e_main.c:1527:
+               imr_data =3D AT_READ_REG(&adapter->hw, REG_IMR);$

ERROR: spaces required around that '=' (ctx:WxV)
#4337: FILE: drivers/net/atl1e/atl1e_main.c:1527:
+               imr_data =3D AT_READ_REG(&adapter->hw, REG_IMR);
                         ^

ERROR: code indent should use tabs where possible
#4338: FILE: drivers/net/atl1e/atl1e_main.c:1528:
+               AT_WRITE_REG(&adapter->hw, REG_IMR, imr_data | ISR_RX_EVENT=$

ERROR: spaces required around that '=' (ctx:VxE)
#4338: FILE: drivers/net/atl1e/atl1e_main.c:1528:
+               AT_WRITE_REG(&adapter->hw, REG_IMR, imr_data | ISR_RX_EVENT=
                                                                           ^

ERROR: code indent should use tabs where possible
#4340: FILE: drivers/net/atl1e/atl1e_main.c:1529:
+               /* test debug */$

ERROR: code indent should use tabs where possible
#4341: FILE: drivers/net/atl1e/atl1e_main.c:1530:
+               if (test_bit(__AT_DOWN, &adapter->flags)) {$

ERROR: code indent should use tabs where possible
#4342: FILE: drivers/net/atl1e/atl1e_main.c:1531:
+                       atomic_dec(&adapter->irq_sem);$

ERROR: code indent should use tabs where possible
#4343: FILE: drivers/net/atl1e/atl1e_main.c:1532:
+                       dev_err(&pdev->dev,$

ERROR: code indent should use tabs where possible
#4344: FILE: drivers/net/atl1e/atl1e_main.c:1533:
+                               "atl1e_clean is called when AT_DOWN\n");$

ERROR: code indent should use tabs where possible
#4345: FILE: drivers/net/atl1e/atl1e_main.c:1534:
+               }$

ERROR: code indent should use tabs where possible
#4346: FILE: drivers/net/atl1e/atl1e_main.c:1535:
+               /* reenable RX intr */$

ERROR: code indent should use tabs where possible
#4347: FILE: drivers/net/atl1e/atl1e_main.c:1536:
+               /*atl1e_irq_enable(adapter); */$

ERROR: spaces required around that '=' (ctx:WxV)
#4362: FILE: drivers/net/atl1e/atl1e_main.c:1551:
+       struct atl1e_adapter *adapter =3D netdev_priv(netdev);
                                      ^

ERROR: spaces required around that '=' (ctx:WxV)
#4372: FILE: drivers/net/atl1e/atl1e_main.c:1561:
+       struct atl1e_tx_ring *tx_ring =3D &adapter->tx_ring;
                                      ^

ERROR: need consistent spacing around '&' (ctx:WxV)
#4372: FILE: drivers/net/atl1e/atl1e_main.c:1561:
+       struct atl1e_tx_ring *tx_ring =3D &adapter->tx_ring;
                                          ^

ERROR: spaces required around that '=' (ctx:WxV)
#4373: FILE: drivers/net/atl1e/atl1e_main.c:1562:
+       u16 next_to_use =3D 0;
                        ^

ERROR: spaces required around that '=' (ctx:WxV)
#4374: FILE: drivers/net/atl1e/atl1e_main.c:1563:
+       u16 next_to_clean =3D 0;
                          ^

ERROR: spaces required around that '=' (ctx:WxV)
#4376: FILE: drivers/net/atl1e/atl1e_main.c:1565:
+       next_to_clean =3D atomic_read(&tx_ring->next_to_clean);
                      ^

ERROR: spaces required around that '=' (ctx:WxV)
#4377: FILE: drivers/net/atl1e/atl1e_main.c:1566:
+       next_to_use   =3D tx_ring->next_to_use;
                      ^

ERROR: code indent should use tabs where possible
#4380: FILE: drivers/net/atl1e/atl1e_main.c:1569:
+               (next_to_clean - next_to_use - 1) :$

ERROR: code indent should use tabs where possible
#4381: FILE: drivers/net/atl1e/atl1e_main.c:1570:
+               (tx_ring->count + next_to_clean - next_to_use - 1);$

ERROR: spaces required around that '=' (ctx:WxV)
#4391: FILE: drivers/net/atl1e/atl1e_main.c:1580:
+       struct atl1e_tx_ring *tx_ring =3D &adapter->tx_ring;
                                      ^

ERROR: need consistent spacing around '&' (ctx:WxV)
#4391: FILE: drivers/net/atl1e/atl1e_main.c:1580:
+       struct atl1e_tx_ring *tx_ring =3D &adapter->tx_ring;
                                          ^

ERROR: spaces required around that '=' (ctx:WxV)
#4392: FILE: drivers/net/atl1e/atl1e_main.c:1581:
+       u16 next_to_use =3D 0;
                        ^

ERROR: spaces required around that '=' (ctx:WxV)
#4394: FILE: drivers/net/atl1e/atl1e_main.c:1583:
+       next_to_use =3D tx_ring->next_to_use;
                    ^

ERROR: spaces required around that '=' (ctx:WxV)
#4395: FILE: drivers/net/atl1e/atl1e_main.c:1584:
+       if (++tx_ring->next_to_use =3D=3D tx_ring->count)
                                   ^

ERROR: spaces required around that '=' (ctx:VxV)
#4395: FILE: drivers/net/atl1e/atl1e_main.c:1584:
+       if (++tx_ring->next_to_use =3D=3D tx_ring->count)
                                      ^

ERROR: do not use assignment in if condition
#4395: FILE: drivers/net/atl1e/atl1e_main.c:1584:
+       if (++tx_ring->next_to_use =3D=3D tx_ring->count)

ERROR: code indent should use tabs where possible
#4396: FILE: drivers/net/atl1e/atl1e_main.c:1585:
+               tx_ring->next_to_use =3D 0;$

ERROR: spaces required around that '=' (ctx:WxV)
#4396: FILE: drivers/net/atl1e/atl1e_main.c:1585:
+               tx_ring->next_to_use =3D 0;
                                     ^

ERROR: spaces required around that '=' (ctx:VxE)
#4398: FILE: drivers/net/atl1e/atl1e_main.c:1587:
+       memset(&tx_ring->desc[next_to_use], 0, sizeof(struct atl1e_tpd_desc=
                                                                           ^

ERROR: spaces required around that '=' (ctx:WxV)
#4407: FILE: drivers/net/atl1e/atl1e_main.c:1594:
+       struct atl1e_tx_ring *tx_ring =3D &adapter->tx_ring;
                                      ^

ERROR: need consistent spacing around '&' (ctx:WxV)
#4407: FILE: drivers/net/atl1e/atl1e_main.c:1594:
+       struct atl1e_tx_ring *tx_ring =3D &adapter->tx_ring;
                                          ^

ERROR: spaces required around that '=' (ctx:WxV)
#4415: FILE: drivers/net/atl1e/atl1e_main.c:1602:
+       int i =3D 0;
              ^

ERROR: spaces required around that '=' (ctx:WxV)
#4416: FILE: drivers/net/atl1e/atl1e_main.c:1603:
+       u16 tpd_req =3D 1;
                    ^

ERROR: spaces required around that '=' (ctx:WxV)
#4417: FILE: drivers/net/atl1e/atl1e_main.c:1604:
+       u16 fg_size =3D 0;
                    ^

ERROR: spaces required around that '=' (ctx:WxV)
#4418: FILE: drivers/net/atl1e/atl1e_main.c:1605:
+       u16 proto_hdr_len =3D 0;
                          ^

ERROR: spaces required around that '=' (ctx:WxV)
#4420: FILE: drivers/net/atl1e/atl1e_main.c:1607:
+       for (i =3D 0; i < skb_shinfo(skb)->nr_frags; i++) {
               ^

ERROR: code indent should use tabs where possible
#4421: FILE: drivers/net/atl1e/atl1e_main.c:1608:
+               fg_size =3D skb_shinfo(skb)->frags[i].size;$

ERROR: spaces required around that '=' (ctx:WxV)
#4421: FILE: drivers/net/atl1e/atl1e_main.c:1608:
+               fg_size =3D skb_shinfo(skb)->frags[i].size;
                        ^

ERROR: code indent should use tabs where possible
#4422: FILE: drivers/net/atl1e/atl1e_main.c:1609:
+               tpd_req +=3D ((fg_size + MAX_TX_BUF_LEN - 1) >> MAX_TX_BUF_=$

WARNING: space prohibited between function name and open parenthesis '('
#4422: FILE: drivers/net/atl1e/atl1e_main.c:1609:
+               tpd_req +=3D ((fg_size + MAX_TX_BUF_LEN - 1) >> MAX_TX_BUF_=

ERROR: spaces required around that '+=' (ctx:WxV)
#4422: FILE: drivers/net/atl1e/atl1e_main.c:1609:
+               tpd_req +=3D ((fg_size + MAX_TX_BUF_LEN - 1) >> MAX_TX_BUF_=
                        ^

ERROR: spaces required around that '=' (ctx:VxE)
#4422: FILE: drivers/net/atl1e/atl1e_main.c:1609:
+               tpd_req +=3D ((fg_size + MAX_TX_BUF_LEN - 1) >> MAX_TX_BUF_=
                                                                           ^

ERROR: code indent should use tabs where possible
#4427: FILE: drivers/net/atl1e/atl1e_main.c:1613:
+               if (skb->protocol =3D=3D ntohs(ETH_P_IP) ||$

ERROR: spaces required around that '=' (ctx:WxV)
#4427: FILE: drivers/net/atl1e/atl1e_main.c:1613:
+               if (skb->protocol =3D=3D ntohs(ETH_P_IP) ||
                                  ^

ERROR: spaces required around that '=' (ctx:VxV)
#4427: FILE: drivers/net/atl1e/atl1e_main.c:1613:
+               if (skb->protocol =3D=3D ntohs(ETH_P_IP) ||
                                     ^

ERROR: do not use assignment in if condition
#4427: FILE: drivers/net/atl1e/atl1e_main.c:1613:
+               if (skb->protocol =3D=3D ntohs(ETH_P_IP) ||

ERROR: code indent should use tabs where possible
#4428: FILE: drivers/net/atl1e/atl1e_main.c:1614:
+                  (skb_shinfo(skb)->gso_type =3D=3D SKB_GSO_TCPV6)) {$

ERROR: spaces required around that '=' (ctx:WxV)
#4428: FILE: drivers/net/atl1e/atl1e_main.c:1614:
+                  (skb_shinfo(skb)->gso_type =3D=3D SKB_GSO_TCPV6)) {
                                              ^

ERROR: spaces required around that '=' (ctx:VxV)
#4428: FILE: drivers/net/atl1e/atl1e_main.c:1614:
+                  (skb_shinfo(skb)->gso_type =3D=3D SKB_GSO_TCPV6)) {
                                                 ^

ERROR: code indent should use tabs where possible
#4429: FILE: drivers/net/atl1e/atl1e_main.c:1615:
+                       proto_hdr_len =3D skb_transport_offset(skb) +$

ERROR: spaces required around that '=' (ctx:WxV)
#4429: FILE: drivers/net/atl1e/atl1e_main.c:1615:
+                       proto_hdr_len =3D skb_transport_offset(skb) +
                                      ^

ERROR: code indent should use tabs where possible
#4430: FILE: drivers/net/atl1e/atl1e_main.c:1616:
+                                       tcp_hdrlen(skb);$

ERROR: code indent should use tabs where possible
#4431: FILE: drivers/net/atl1e/atl1e_main.c:1617:
+                       if (proto_hdr_len < skb_headlen(skb)) {$

ERROR: code indent should use tabs where possible
#4432: FILE: drivers/net/atl1e/atl1e_main.c:1618:
+                               tpd_req +=3D ((skb_headlen(skb) - proto_hdr=$

WARNING: space prohibited between function name and open parenthesis '('
#4432: FILE: drivers/net/atl1e/atl1e_main.c:1618:
+                               tpd_req +=3D ((skb_headlen(skb) - proto_hdr=

ERROR: spaces required around that '+=' (ctx:WxV)
#4432: FILE: drivers/net/atl1e/atl1e_main.c:1618:
+                               tpd_req +=3D ((skb_headlen(skb) - proto_hdr=
                                        ^

ERROR: spaces required around that '=' (ctx:VxE)
#4432: FILE: drivers/net/atl1e/atl1e_main.c:1618:
+                               tpd_req +=3D ((skb_headlen(skb) - proto_hdr=
                                                                           ^

ERROR: code indent should use tabs where possible
#4434: FILE: drivers/net/atl1e/atl1e_main.c:1619:
+                                          MAX_TX_BUF_LEN - 1) >>$

ERROR: code indent should use tabs where possible
#4435: FILE: drivers/net/atl1e/atl1e_main.c:1620:
+                                          MAX_TX_BUF_SHIFT);$

ERROR: code indent should use tabs where possible
#4436: FILE: drivers/net/atl1e/atl1e_main.c:1621:
+                       }$

ERROR: code indent should use tabs where possible
#4437: FILE: drivers/net/atl1e/atl1e_main.c:1622:
+               }$

ERROR: code indent should use tabs where possible
#4444: FILE: drivers/net/atl1e/atl1e_main.c:1629:
+                      struct sk_buff *skb, struct atl1e_tpd_desc *tpd)$

ERROR: spaces required around that '=' (ctx:WxV)
#4446: FILE: drivers/net/atl1e/atl1e_main.c:1631:
+       struct pci_dev *pdev =3D adapter->pdev;
                             ^

ERROR: code indent should use tabs where possible
#4453: FILE: drivers/net/atl1e/atl1e_main.c:1638:
+               if (skb_header_cloned(skb)) {$

ERROR: code indent should use tabs where possible
#4454: FILE: drivers/net/atl1e/atl1e_main.c:1639:
+                       err =3D pskb_expand_head(skb, 0, 0, GFP_ATOMIC);$

ERROR: spaces required around that '=' (ctx:WxV)
#4454: FILE: drivers/net/atl1e/atl1e_main.c:1639:
+                       err =3D pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
                            ^

ERROR: code indent should use tabs where possible
#4455: FILE: drivers/net/atl1e/atl1e_main.c:1640:
+                       if (unlikely(err))$

ERROR: code indent should use tabs where possible
#4456: FILE: drivers/net/atl1e/atl1e_main.c:1641:
+                               return -1;$

ERROR: code indent should use tabs where possible
#4457: FILE: drivers/net/atl1e/atl1e_main.c:1642:
+               }$

ERROR: code indent should use tabs where possible
#4458: FILE: drivers/net/atl1e/atl1e_main.c:1643:
+               offload_type =3D skb_shinfo(skb)->gso_type;$

ERROR: spaces required around that '=' (ctx:WxV)
#4458: FILE: drivers/net/atl1e/atl1e_main.c:1643:
+               offload_type =3D skb_shinfo(skb)->gso_type;
                             ^

ERROR: code indent should use tabs where possible
#4460: FILE: drivers/net/atl1e/atl1e_main.c:1645:
+               if (offload_type & SKB_GSO_TCPV4) {$

ERROR: code indent should use tabs where possible
#4461: FILE: drivers/net/atl1e/atl1e_main.c:1646:
+                       real_len =3D (((unsigned char *)ip_hdr(skb) - skb->=$

WARNING: space prohibited between function name and open parenthesis '('
#4461: FILE: drivers/net/atl1e/atl1e_main.c:1646:
+                       real_len =3D (((unsigned char *)ip_hdr(skb) - skb->=

ERROR: spaces required around that '=' (ctx:WxV)
#4461: FILE: drivers/net/atl1e/atl1e_main.c:1646:
+                       real_len =3D (((unsigned char *)ip_hdr(skb) - skb->=
                                 ^

ERROR: spaces required around that '=' (ctx:OxE)
#4461: FILE: drivers/net/atl1e/atl1e_main.c:1646:
+                       real_len =3D (((unsigned char *)ip_hdr(skb) - skb->=
                                                                           ^

ERROR: code indent should use tabs where possible
#4463: FILE: drivers/net/atl1e/atl1e_main.c:1647:
+                                       + ntohs(ip_hdr(skb)->tot_len));$

ERROR: code indent should use tabs where possible
#4465: FILE: drivers/net/atl1e/atl1e_main.c:1649:
+                       if (real_len < skb->len)$

ERROR: code indent should use tabs where possible
#4466: FILE: drivers/net/atl1e/atl1e_main.c:1650:
+                               pskb_trim(skb, real_len);$

ERROR: code indent should use tabs where possible
#4468: FILE: drivers/net/atl1e/atl1e_main.c:1652:
+                       hdr_len =3D (skb_transport_offset(skb) + tcp_hdrlen=$

WARNING: space prohibited between function name and open parenthesis '('
#4468: FILE: drivers/net/atl1e/atl1e_main.c:1652:
+                       hdr_len =3D (skb_transport_offset(skb) + tcp_hdrlen=

ERROR: spaces required around that '=' (ctx:WxV)
#4468: FILE: drivers/net/atl1e/atl1e_main.c:1652:
+                       hdr_len =3D (skb_transport_offset(skb) + tcp_hdrlen=
                                ^

ERROR: spaces required around that '=' (ctx:VxE)
#4468: FILE: drivers/net/atl1e/atl1e_main.c:1652:
+                       hdr_len =3D (skb_transport_offset(skb) + tcp_hdrlen=
                                                                           ^

ERROR: code indent should use tabs where possible
#4470: FILE: drivers/net/atl1e/atl1e_main.c:1653:
+                       if (unlikely(skb->len =3D=3D hdr_len)) {$

ERROR: spaces required around that '=' (ctx:WxV)
#4470: FILE: drivers/net/atl1e/atl1e_main.c:1653:
+                       if (unlikely(skb->len =3D=3D hdr_len)) {
                                              ^

ERROR: spaces required around that '=' (ctx:VxV)
#4470: FILE: drivers/net/atl1e/atl1e_main.c:1653:
+                       if (unlikely(skb->len =3D=3D hdr_len)) {
                                                 ^

ERROR: do not use assignment in if condition
#4470: FILE: drivers/net/atl1e/atl1e_main.c:1653:
+                       if (unlikely(skb->len =3D=3D hdr_len)) {

ERROR: code indent should use tabs where possible
#4471: FILE: drivers/net/atl1e/atl1e_main.c:1654:
+                               /* only xsum need */$

ERROR: code indent should use tabs where possible
#4472: FILE: drivers/net/atl1e/atl1e_main.c:1655:
+                               dev_warn(&pdev->dev,$

ERROR: code indent should use tabs where possible
#4473: FILE: drivers/net/atl1e/atl1e_main.c:1656:
+                                     "IPV4 tso with zero data??\n");$

ERROR: code indent should use tabs where possible
#4474: FILE: drivers/net/atl1e/atl1e_main.c:1657:
+                               goto check_sum;$

ERROR: code indent should use tabs where possible
#4475: FILE: drivers/net/atl1e/atl1e_main.c:1658:
+                       } else {$

ERROR: code indent should use tabs where possible
#4476: FILE: drivers/net/atl1e/atl1e_main.c:1659:
+                               ip_hdr(skb)->check =3D 0;$

ERROR: spaces required around that '=' (ctx:WxV)
#4476: FILE: drivers/net/atl1e/atl1e_main.c:1659:
+                               ip_hdr(skb)->check =3D 0;
                                                   ^

ERROR: code indent should use tabs where possible
#4477: FILE: drivers/net/atl1e/atl1e_main.c:1660:
+                               ip_hdr(skb)->tot_len =3D 0;$

ERROR: spaces required around that '=' (ctx:WxV)
#4477: FILE: drivers/net/atl1e/atl1e_main.c:1660:
+                               ip_hdr(skb)->tot_len =3D 0;
                                                     ^

ERROR: code indent should use tabs where possible
#4478: FILE: drivers/net/atl1e/atl1e_main.c:1661:
+                               tcp_hdr(skb)->check =3D ~csum_tcpudp_magic($

ERROR: spaces required around that '=' (ctx:WxV)
#4478: FILE: drivers/net/atl1e/atl1e_main.c:1661:
+                               tcp_hdr(skb)->check =3D ~csum_tcpudp_magic(
                                                    ^

ERROR: code indent should use tabs where possible
#4479: FILE: drivers/net/atl1e/atl1e_main.c:1662:
+                                                       ip_hdr(skb)->saddr,$

ERROR: code indent should use tabs where possible
#4480: FILE: drivers/net/atl1e/atl1e_main.c:1663:
+                                                       ip_hdr(skb)->daddr,$

ERROR: code indent should use tabs where possible
#4481: FILE: drivers/net/atl1e/atl1e_main.c:1664:
+                                                       0, IPPROTO_TCP, 0);$

ERROR: code indent should use tabs where possible
#4482: FILE: drivers/net/atl1e/atl1e_main.c:1665:
+                               tpd->word3 |=3D (ip_hdr(skb)->ihl &$

WARNING: space prohibited between function name and open parenthesis '('
#4482: FILE: drivers/net/atl1e/atl1e_main.c:1665:
+                               tpd->word3 |=3D (ip_hdr(skb)->ihl &

ERROR: spaces required around that '|=' (ctx:WxV)
#4482: FILE: drivers/net/atl1e/atl1e_main.c:1665:
+                               tpd->word3 |=3D (ip_hdr(skb)->ihl &
                                           ^

ERROR: code indent should use tabs where possible
#4483: FILE: drivers/net/atl1e/atl1e_main.c:1666:
+                                       TDP_V4_IPHL_MASK) <<$

ERROR: code indent should use tabs where possible
#4484: FILE: drivers/net/atl1e/atl1e_main.c:1667:
+                                       TPD_V4_IPHL_SHIFT;$

ERROR: code indent should use tabs where possible
#4485: FILE: drivers/net/atl1e/atl1e_main.c:1668:
+                               tpd->word3 |=3D ((tcp_hdrlen(skb) >> 2) &$

WARNING: space prohibited between function name and open parenthesis '('
#4485: FILE: drivers/net/atl1e/atl1e_main.c:1668:
+                               tpd->word3 |=3D ((tcp_hdrlen(skb) >> 2) &

ERROR: spaces required around that '|=' (ctx:WxV)
#4485: FILE: drivers/net/atl1e/atl1e_main.c:1668:
+                               tpd->word3 |=3D ((tcp_hdrlen(skb) >> 2) &
                                           ^

ERROR: code indent should use tabs where possible
#4486: FILE: drivers/net/atl1e/atl1e_main.c:1669:
+                                       TPD_TCPHDRLEN_MASK) <<$

ERROR: code indent should use tabs where possible
#4487: FILE: drivers/net/atl1e/atl1e_main.c:1670:
+                                       TPD_TCPHDRLEN_SHIFT;$

ERROR: code indent should use tabs where possible
#4488: FILE: drivers/net/atl1e/atl1e_main.c:1671:
+                               tpd->word3 |=3D ((skb_shinfo(skb)->gso_size=$

WARNING: space prohibited between function name and open parenthesis '('
#4488: FILE: drivers/net/atl1e/atl1e_main.c:1671:
+                               tpd->word3 |=3D ((skb_shinfo(skb)->gso_size=

ERROR: spaces required around that '|=' (ctx:WxV)
#4488: FILE: drivers/net/atl1e/atl1e_main.c:1671:
+                               tpd->word3 |=3D ((skb_shinfo(skb)->gso_size=
                                           ^

ERROR: spaces required around that '=' (ctx:VxE)
#4488: FILE: drivers/net/atl1e/atl1e_main.c:1671:
+                               tpd->word3 |=3D ((skb_shinfo(skb)->gso_size=
                                                                           ^

ERROR: code indent should use tabs where possible
#4490: FILE: drivers/net/atl1e/atl1e_main.c:1672:
+                                       TPD_MSS_MASK) << TPD_MSS_SHIFT;$

ERROR: code indent should use tabs where possible
#4491: FILE: drivers/net/atl1e/atl1e_main.c:1673:
+                               tpd->word3 |=3D 1 << TPD_SEGMENT_EN_SHIFT;$

ERROR: spaces required around that '|=' (ctx:WxV)
#4491: FILE: drivers/net/atl1e/atl1e_main.c:1673:
+                               tpd->word3 |=3D 1 << TPD_SEGMENT_EN_SHIFT;
                                           ^

ERROR: code indent should use tabs where possible
#4492: FILE: drivers/net/atl1e/atl1e_main.c:1674:
+                       }$

ERROR: code indent should use tabs where possible
#4493: FILE: drivers/net/atl1e/atl1e_main.c:1675:
+                       return 0;$

ERROR: code indent should use tabs where possible
#4494: FILE: drivers/net/atl1e/atl1e_main.c:1676:
+               }$

ERROR: code indent should use tabs where possible
#4496: FILE: drivers/net/atl1e/atl1e_main.c:1678:
+               if (offload_type & SKB_GSO_TCPV6) {$

ERROR: code indent should use tabs where possible
#4497: FILE: drivers/net/atl1e/atl1e_main.c:1679:
+                       real_len =3D (((unsigned char *)ipv6_hdr(skb) - skb=$

WARNING: space prohibited between function name and open parenthesis '('
#4497: FILE: drivers/net/atl1e/atl1e_main.c:1679:
+                       real_len =3D (((unsigned char *)ipv6_hdr(skb) - skb=

ERROR: spaces required around that '=' (ctx:WxV)
#4497: FILE: drivers/net/atl1e/atl1e_main.c:1679:
+                       real_len =3D (((unsigned char *)ipv6_hdr(skb) - skb=
                                 ^

ERROR: spaces required around that '=' (ctx:VxE)
#4497: FILE: drivers/net/atl1e/atl1e_main.c:1679:
+                       real_len =3D (((unsigned char *)ipv6_hdr(skb) - skb=
                                                                           ^

ERROR: code indent should use tabs where possible
#4499: FILE: drivers/net/atl1e/atl1e_main.c:1680:
+                                       + ntohs(ipv6_hdr(skb)->payload_len)=$

ERROR: spaces required around that '=' (ctx:VxE)
#4499: FILE: drivers/net/atl1e/atl1e_main.c:1680:
+                                       + ntohs(ipv6_hdr(skb)->payload_len)=
                                                                           ^

ERROR: code indent should use tabs where possible
#4501: FILE: drivers/net/atl1e/atl1e_main.c:1681:
+                       if (real_len < skb->len)$

ERROR: code indent should use tabs where possible
#4502: FILE: drivers/net/atl1e/atl1e_main.c:1682:
+                               pskb_trim(skb, real_len);$

ERROR: code indent should use tabs where possible
#4504: FILE: drivers/net/atl1e/atl1e_main.c:1684:
+                       /* check payload =3D=3D 0 byte ? */$

ERROR: code indent should use tabs where possible
#4505: FILE: drivers/net/atl1e/atl1e_main.c:1685:
+                       hdr_len =3D (skb_transport_offset(skb) + tcp_hdrlen=$

WARNING: space prohibited between function name and open parenthesis '('
#4505: FILE: drivers/net/atl1e/atl1e_main.c:1685:
+                       hdr_len =3D (skb_transport_offset(skb) + tcp_hdrlen=

ERROR: spaces required around that '=' (ctx:WxV)
#4505: FILE: drivers/net/atl1e/atl1e_main.c:1685:
+                       hdr_len =3D (skb_transport_offset(skb) + tcp_hdrlen=
                                ^

ERROR: spaces required around that '=' (ctx:VxE)
#4505: FILE: drivers/net/atl1e/atl1e_main.c:1685:
+                       hdr_len =3D (skb_transport_offset(skb) + tcp_hdrlen=
                                                                           ^

ERROR: code indent should use tabs where possible
#4507: FILE: drivers/net/atl1e/atl1e_main.c:1686:
+                       if (unlikely(skb->len =3D=3D hdr_len)) {$

ERROR: spaces required around that '=' (ctx:WxV)
#4507: FILE: drivers/net/atl1e/atl1e_main.c:1686:
+                       if (unlikely(skb->len =3D=3D hdr_len)) {
                                              ^

ERROR: spaces required around that '=' (ctx:VxV)
#4507: FILE: drivers/net/atl1e/atl1e_main.c:1686:
+                       if (unlikely(skb->len =3D=3D hdr_len)) {
                                                 ^

ERROR: do not use assignment in if condition
#4507: FILE: drivers/net/atl1e/atl1e_main.c:1686:
+                       if (unlikely(skb->len =3D=3D hdr_len)) {

ERROR: code indent should use tabs where possible
#4508: FILE: drivers/net/atl1e/atl1e_main.c:1687:
+                               /* only xsum need */$

ERROR: code indent should use tabs where possible
#4509: FILE: drivers/net/atl1e/atl1e_main.c:1688:
+                               dev_warn(&pdev->dev,$

ERROR: code indent should use tabs where possible
#4510: FILE: drivers/net/atl1e/atl1e_main.c:1689:
+                                       "IPV6 tso with zero data??\n");$

ERROR: code indent should use tabs where possible
#4511: FILE: drivers/net/atl1e/atl1e_main.c:1690:
+                               goto check_sum;$

ERROR: code indent should use tabs where possible
#4512: FILE: drivers/net/atl1e/atl1e_main.c:1691:
+                       } else {$

ERROR: code indent should use tabs where possible
#4513: FILE: drivers/net/atl1e/atl1e_main.c:1692:
+                               tcp_hdr(skb)->check =3D ~csum_ipv6_magic($

ERROR: spaces required around that '=' (ctx:WxV)
#4513: FILE: drivers/net/atl1e/atl1e_main.c:1692:
+                               tcp_hdr(skb)->check =3D ~csum_ipv6_magic(
                                                    ^

ERROR: code indent should use tabs where possible
#4514: FILE: drivers/net/atl1e/atl1e_main.c:1693:
+                                               &ipv6_hdr(skb)->saddr,$

ERROR: code indent should use tabs where possible
#4515: FILE: drivers/net/atl1e/atl1e_main.c:1694:
+                                               &ipv6_hdr(skb)->daddr,$

ERROR: code indent should use tabs where possible
#4516: FILE: drivers/net/atl1e/atl1e_main.c:1695:
+                                               0, IPPROTO_TCP, 0);$

ERROR: code indent should use tabs where possible
#4517: FILE: drivers/net/atl1e/atl1e_main.c:1696:
+                               tpd->word3 |=3D 1 << TPD_IP_VERSION_SHIFT;$

ERROR: spaces required around that '|=' (ctx:WxV)
#4517: FILE: drivers/net/atl1e/atl1e_main.c:1696:
+                               tpd->word3 |=3D 1 << TPD_IP_VERSION_SHIFT;
                                           ^

ERROR: code indent should use tabs where possible
#4518: FILE: drivers/net/atl1e/atl1e_main.c:1697:
+                               hdr_len >>=3D 1;$

ERROR: spaces required around that '>>=' (ctx:WxV)
#4518: FILE: drivers/net/atl1e/atl1e_main.c:1697:
+                               hdr_len >>=3D 1;
                                        ^

ERROR: code indent should use tabs where possible
#4519: FILE: drivers/net/atl1e/atl1e_main.c:1698:
+                               tpd->word3 |=3D (hdr_len & TPD_V6_IPHLLO_MA=$

WARNING: space prohibited between function name and open parenthesis '('
#4519: FILE: drivers/net/atl1e/atl1e_main.c:1698:
+                               tpd->word3 |=3D (hdr_len & TPD_V6_IPHLLO_MA=

ERROR: spaces required around that '|=' (ctx:WxV)
#4519: FILE: drivers/net/atl1e/atl1e_main.c:1698:
+                               tpd->word3 |=3D (hdr_len & TPD_V6_IPHLLO_MA=
                                           ^

ERROR: spaces required around that '=' (ctx:VxE)
#4519: FILE: drivers/net/atl1e/atl1e_main.c:1698:
+                               tpd->word3 |=3D (hdr_len & TPD_V6_IPHLLO_MA=
                                                                           ^

ERROR: code indent should use tabs where possible
#4521: FILE: drivers/net/atl1e/atl1e_main.c:1699:
+                                       TPD_V6_IPHLLO_SHIFT;$

ERROR: code indent should use tabs where possible
#4522: FILE: drivers/net/atl1e/atl1e_main.c:1700:
+                               tpd->word3 |=3D ((hdr_len >> 3) &$

WARNING: space prohibited between function name and open parenthesis '('
#4522: FILE: drivers/net/atl1e/atl1e_main.c:1700:
+                               tpd->word3 |=3D ((hdr_len >> 3) &

ERROR: spaces required around that '|=' (ctx:WxV)
#4522: FILE: drivers/net/atl1e/atl1e_main.c:1700:
+                               tpd->word3 |=3D ((hdr_len >> 3) &
                                           ^

ERROR: code indent should use tabs where possible
#4523: FILE: drivers/net/atl1e/atl1e_main.c:1701:
+                                       TPD_V6_IPHLHI_MASK) <<$

ERROR: code indent should use tabs where possible
#4524: FILE: drivers/net/atl1e/atl1e_main.c:1702:
+                                       TPD_V6_IPHLHI_SHIFT;$

ERROR: code indent should use tabs where possible
#4525: FILE: drivers/net/atl1e/atl1e_main.c:1703:
+                               tpd->word3 |=3D (tcp_hdrlen(skb) >> 2 &$

WARNING: space prohibited between function name and open parenthesis '('
#4525: FILE: drivers/net/atl1e/atl1e_main.c:1703:
+                               tpd->word3 |=3D (tcp_hdrlen(skb) >> 2 &

ERROR: spaces required around that '|=' (ctx:WxV)
#4525: FILE: drivers/net/atl1e/atl1e_main.c:1703:
+                               tpd->word3 |=3D (tcp_hdrlen(skb) >> 2 &
                                           ^

ERROR: code indent should use tabs where possible
#4526: FILE: drivers/net/atl1e/atl1e_main.c:1704:
+                                       TPD_TCPHDRLEN_MASK) <<$

ERROR: code indent should use tabs where possible
#4527: FILE: drivers/net/atl1e/atl1e_main.c:1705:
+                                       TPD_TCPHDRLEN_SHIFT;$

ERROR: code indent should use tabs where possible
#4528: FILE: drivers/net/atl1e/atl1e_main.c:1706:
+                               tpd->word3 |=3D ((skb_shinfo(skb)->gso_size=$

WARNING: space prohibited between function name and open parenthesis '('
#4528: FILE: drivers/net/atl1e/atl1e_main.c:1706:
+                               tpd->word3 |=3D ((skb_shinfo(skb)->gso_size=

ERROR: spaces required around that '|=' (ctx:WxV)
#4528: FILE: drivers/net/atl1e/atl1e_main.c:1706:
+                               tpd->word3 |=3D ((skb_shinfo(skb)->gso_size=
                                           ^

ERROR: spaces required around that '=' (ctx:VxE)
#4528: FILE: drivers/net/atl1e/atl1e_main.c:1706:
+                               tpd->word3 |=3D ((skb_shinfo(skb)->gso_size=
                                                                           ^

ERROR: code indent should use tabs where possible
#4530: FILE: drivers/net/atl1e/atl1e_main.c:1707:
+                                       TPD_MSS_MASK) << TPD_MSS_SHIFT;$

ERROR: code indent should use tabs where possible
#4531: FILE: drivers/net/atl1e/atl1e_main.c:1708:
+                                       tpd->word3 |=3D 1 << TPD_SEGMENT_EN=$

ERROR: spaces required around that '|=' (ctx:WxV)
#4531: FILE: drivers/net/atl1e/atl1e_main.c:1708:
+                                       tpd->word3 |=3D 1 << TPD_SEGMENT_EN=
                                                   ^

ERROR: spaces required around that '=' (ctx:VxE)
#4531: FILE: drivers/net/atl1e/atl1e_main.c:1708:
+                                       tpd->word3 |=3D 1 << TPD_SEGMENT_EN=
                                                                           ^

ERROR: code indent should use tabs where possible
#4533: FILE: drivers/net/atl1e/atl1e_main.c:1709:
+                       }$

ERROR: code indent should use tabs where possible
#4534: FILE: drivers/net/atl1e/atl1e_main.c:1710:
+               }$

ERROR: code indent should use tabs where possible
#4535: FILE: drivers/net/atl1e/atl1e_main.c:1711:
+               return 0;$

ERROR: spaces required around that '=' (ctx:WxV)
#4539: FILE: drivers/net/atl1e/atl1e_main.c:1715:
+       if (likely(skb->ip_summed =3D=3D CHECKSUM_PARTIAL)) {
                                  ^

ERROR: spaces required around that '=' (ctx:VxV)
#4539: FILE: drivers/net/atl1e/atl1e_main.c:1715:
+       if (likely(skb->ip_summed =3D=3D CHECKSUM_PARTIAL)) {
                                     ^

ERROR: do not use assignment in if condition
#4539: FILE: drivers/net/atl1e/atl1e_main.c:1715:
+       if (likely(skb->ip_summed =3D=3D CHECKSUM_PARTIAL)) {

ERROR: code indent should use tabs where possible
#4540: FILE: drivers/net/atl1e/atl1e_main.c:1716:
+               u8 css, cso;$

ERROR: code indent should use tabs where possible
#4542: FILE: drivers/net/atl1e/atl1e_main.c:1718:
+               cso =3D skb_transport_offset(skb);$

ERROR: spaces required around that '=' (ctx:WxV)
#4542: FILE: drivers/net/atl1e/atl1e_main.c:1718:
+               cso =3D skb_transport_offset(skb);
                    ^

ERROR: code indent should use tabs where possible
#4543: FILE: drivers/net/atl1e/atl1e_main.c:1719:
+               if (unlikely(cso & 0x1)) {$

ERROR: code indent should use tabs where possible
#4544: FILE: drivers/net/atl1e/atl1e_main.c:1720:
+                       dev_err(&adapter->pdev->dev,$

ERROR: code indent should use tabs where possible
#4545: FILE: drivers/net/atl1e/atl1e_main.c:1721:
+                          "pay load offset should not ant event number\n")=$

ERROR: spaces required around that '=' (ctx:VxE)
#4545: FILE: drivers/net/atl1e/atl1e_main.c:1721:
+                          "pay load offset should not ant event number\n")=
                                                                           ^

ERROR: code indent should use tabs where possible
#4547: FILE: drivers/net/atl1e/atl1e_main.c:1722:
+                       return -1;$

ERROR: code indent should use tabs where possible
#4548: FILE: drivers/net/atl1e/atl1e_main.c:1723:
+               } else {$

ERROR: code indent should use tabs where possible
#4549: FILE: drivers/net/atl1e/atl1e_main.c:1724:
+                       css =3D cso + skb->csum_offset;$

ERROR: spaces required around that '=' (ctx:WxV)
#4549: FILE: drivers/net/atl1e/atl1e_main.c:1724:
+                       css =3D cso + skb->csum_offset;
                            ^

ERROR: code indent should use tabs where possible
#4550: FILE: drivers/net/atl1e/atl1e_main.c:1725:
+                       tpd->word3 |=3D (cso & TPD_PLOADOFFSET_MASK) <<$

WARNING: space prohibited between function name and open parenthesis '('
#4550: FILE: drivers/net/atl1e/atl1e_main.c:1725:
+                       tpd->word3 |=3D (cso & TPD_PLOADOFFSET_MASK) <<

ERROR: spaces required around that '|=' (ctx:WxV)
#4550: FILE: drivers/net/atl1e/atl1e_main.c:1725:
+                       tpd->word3 |=3D (cso & TPD_PLOADOFFSET_MASK) <<
                                   ^

ERROR: code indent should use tabs where possible
#4551: FILE: drivers/net/atl1e/atl1e_main.c:1726:
+                                       TPD_PLOADOFFSET_SHIFT;$

ERROR: code indent should use tabs where possible
#4552: FILE: drivers/net/atl1e/atl1e_main.c:1727:
+                       tpd->word3 |=3D (css & TPD_CCSUMOFFSET_MASK) <<$

WARNING: space prohibited between function name and open parenthesis '('
#4552: FILE: drivers/net/atl1e/atl1e_main.c:1727:
+                       tpd->word3 |=3D (css & TPD_CCSUMOFFSET_MASK) <<

ERROR: spaces required around that '|=' (ctx:WxV)
#4552: FILE: drivers/net/atl1e/atl1e_main.c:1727:
+                       tpd->word3 |=3D (css & TPD_CCSUMOFFSET_MASK) <<
                                   ^

ERROR: code indent should use tabs where possible
#4553: FILE: drivers/net/atl1e/atl1e_main.c:1728:
+                                       TPD_CCSUMOFFSET_SHIFT;$

ERROR: code indent should use tabs where possible
#4554: FILE: drivers/net/atl1e/atl1e_main.c:1729:
+                       tpd->word3 |=3D 1 << TPD_CC_SEGMENT_EN_SHIFT;$

ERROR: spaces required around that '|=' (ctx:WxV)
#4554: FILE: drivers/net/atl1e/atl1e_main.c:1729:
+                       tpd->word3 |=3D 1 << TPD_CC_SEGMENT_EN_SHIFT;
                                   ^

ERROR: code indent should use tabs where possible
#4555: FILE: drivers/net/atl1e/atl1e_main.c:1730:
+               }$

ERROR: code indent should use tabs where possible
#4562: FILE: drivers/net/atl1e/atl1e_main.c:1737:
+                     struct sk_buff *skb, struct atl1e_tpd_desc *tpd)$

ERROR: spaces required around that '=' (ctx:WxV)
#4564: FILE: drivers/net/atl1e/atl1e_main.c:1739:
+       struct atl1e_tpd_desc *use_tpd =3D NULL;
                                       ^

ERROR: spaces required around that '=' (ctx:WxV)
#4565: FILE: drivers/net/atl1e/atl1e_main.c:1740:
+       struct atl1e_tx_buffer *tx_buffer =3D NULL;
                                          ^

ERROR: spaces required around that '=' (ctx:WxV)
#4566: FILE: drivers/net/atl1e/atl1e_main.c:1741:
+       u16 buf_len =3D skb->len - skb->data_len;
                    ^

ERROR: space prohibited after that '-' (ctx:WxW)
#4566: FILE: drivers/net/atl1e/atl1e_main.c:1741:
+       u16 buf_len =3D skb->len - skb->data_len;
                                 ^

ERROR: spaces required around that '=' (ctx:WxV)
#4567: FILE: drivers/net/atl1e/atl1e_main.c:1742:
+       u16 map_len =3D 0;
                    ^

ERROR: spaces required around that '=' (ctx:WxV)
#4568: FILE: drivers/net/atl1e/atl1e_main.c:1743:
+       u16 mapped_len =3D 0;
                       ^

ERROR: spaces required around that '=' (ctx:WxV)
#4569: FILE: drivers/net/atl1e/atl1e_main.c:1744:
+       u16 hdr_len =3D 0;
                    ^

ERROR: spaces required around that '=' (ctx:WxV)
#4574: FILE: drivers/net/atl1e/atl1e_main.c:1749:
+       nr_frags =3D skb_shinfo(skb)->nr_frags;
                 ^

WARNING: space prohibited between function name and open parenthesis '('
#4575: FILE: drivers/net/atl1e/atl1e_main.c:1750:
+       segment =3D (tpd->word3 >> TPD_SEGMENT_EN_SHIFT) & TPD_SEGMENT_EN_M=

ERROR: spaces required around that '=' (ctx:WxV)
#4575: FILE: drivers/net/atl1e/atl1e_main.c:1750:
+       segment =3D (tpd->word3 >> TPD_SEGMENT_EN_SHIFT) & TPD_SEGMENT_EN_M=
                ^

ERROR: spaces required around that '=' (ctx:VxE)
#4575: FILE: drivers/net/atl1e/atl1e_main.c:1750:
+       segment =3D (tpd->word3 >> TPD_SEGMENT_EN_SHIFT) & TPD_SEGMENT_EN_M=
                                                                           ^

ERROR: code indent should use tabs where possible
#4578: FILE: drivers/net/atl1e/atl1e_main.c:1752:
+               /* TSO */$

ERROR: code indent should use tabs where possible
#4579: FILE: drivers/net/atl1e/atl1e_main.c:1753:
+               map_len =3D hdr_len =3D skb_transport_offset(skb) + tcp_hdr=$

ERROR: spaces required around that '=' (ctx:WxV)
#4579: FILE: drivers/net/atl1e/atl1e_main.c:1753:
+               map_len =3D hdr_len =3D skb_transport_offset(skb) + tcp_hdr=
                        ^

ERROR: spaces required around that '=' (ctx:WxV)
#4579: FILE: drivers/net/atl1e/atl1e_main.c:1753:
+               map_len =3D hdr_len =3D skb_transport_offset(skb) + tcp_hdr=
                                    ^

ERROR: spaces required around that '=' (ctx:VxE)
#4579: FILE: drivers/net/atl1e/atl1e_main.c:1753:
+               map_len =3D hdr_len =3D skb_transport_offset(skb) + tcp_hdr=
                                                                           ^

ERROR: code indent should use tabs where possible
#4581: FILE: drivers/net/atl1e/atl1e_main.c:1754:
+               use_tpd =3D tpd;$

ERROR: spaces required around that '=' (ctx:WxV)
#4581: FILE: drivers/net/atl1e/atl1e_main.c:1754:
+               use_tpd =3D tpd;
                        ^

ERROR: code indent should use tabs where possible
#4583: FILE: drivers/net/atl1e/atl1e_main.c:1756:
+               tx_buffer =3D atl1e_get_tx_buffer(adapter, use_tpd);$

ERROR: spaces required around that '=' (ctx:WxV)
#4583: FILE: drivers/net/atl1e/atl1e_main.c:1756:
+               tx_buffer =3D atl1e_get_tx_buffer(adapter, use_tpd);
                          ^

ERROR: code indent should use tabs where possible
#4584: FILE: drivers/net/atl1e/atl1e_main.c:1757:
+               tx_buffer->length =3D map_len;$

ERROR: spaces required around that '=' (ctx:WxV)
#4584: FILE: drivers/net/atl1e/atl1e_main.c:1757:
+               tx_buffer->length =3D map_len;
                                  ^

ERROR: code indent should use tabs where possible
#4585: FILE: drivers/net/atl1e/atl1e_main.c:1758:
+               tx_buffer->dma =3D pci_map_single(adapter->pdev,$

ERROR: spaces required around that '=' (ctx:WxV)
#4585: FILE: drivers/net/atl1e/atl1e_main.c:1758:
+               tx_buffer->dma =3D pci_map_single(adapter->pdev,
                               ^

ERROR: code indent should use tabs where possible
#4586: FILE: drivers/net/atl1e/atl1e_main.c:1759:
+                                       skb->data, hdr_len, PCI_DMA_TODEVIC=$

ERROR: spaces required around that '=' (ctx:VxE)
#4586: FILE: drivers/net/atl1e/atl1e_main.c:1759:
+                                       skb->data, hdr_len, PCI_DMA_TODEVIC=
                                                                           ^

ERROR: code indent should use tabs where possible
#4588: FILE: drivers/net/atl1e/atl1e_main.c:1760:
+               mapped_len +=3D map_len;$

ERROR: spaces required around that '+=' (ctx:WxV)
#4588: FILE: drivers/net/atl1e/atl1e_main.c:1760:
+               mapped_len +=3D map_len;
                           ^

ERROR: code indent should use tabs where possible
#4589: FILE: drivers/net/atl1e/atl1e_main.c:1761:
+               use_tpd->buffer_addr =3D cpu_to_le64(tx_buffer->dma);$

ERROR: spaces required around that '=' (ctx:WxV)
#4589: FILE: drivers/net/atl1e/atl1e_main.c:1761:
+               use_tpd->buffer_addr =3D cpu_to_le64(tx_buffer->dma);
                                     ^

ERROR: code indent should use tabs where possible
#4590: FILE: drivers/net/atl1e/atl1e_main.c:1762:
+               use_tpd->word2 =3D (use_tpd->word2 & (~TPD_BUFLEN_MASK)) |$

WARNING: space prohibited between function name and open parenthesis '('
#4590: FILE: drivers/net/atl1e/atl1e_main.c:1762:
+               use_tpd->word2 =3D (use_tpd->word2 & (~TPD_BUFLEN_MASK)) |

ERROR: spaces required around that '=' (ctx:WxV)
#4590: FILE: drivers/net/atl1e/atl1e_main.c:1762:
+               use_tpd->word2 =3D (use_tpd->word2 & (~TPD_BUFLEN_MASK)) |
                               ^

ERROR: code indent should use tabs where possible
#4591: FILE: drivers/net/atl1e/atl1e_main.c:1763:
+                       ((cpu_to_le32(tx_buffer->length) &$

ERROR: code indent should use tabs where possible
#4592: FILE: drivers/net/atl1e/atl1e_main.c:1764:
+                       TPD_BUFLEN_MASK) << TPD_BUFLEN_SHIFT);$

ERROR: code indent should use tabs where possible
#4596: FILE: drivers/net/atl1e/atl1e_main.c:1768:
+               /* mapped_len =3D=3D 0, means we should use the first tpd,$

ERROR: code indent should use tabs where possible
#4597: FILE: drivers/net/atl1e/atl1e_main.c:1769:
+                  which is given by caller  */$

ERROR: code indent should use tabs where possible
#4598: FILE: drivers/net/atl1e/atl1e_main.c:1770:
+               if (mapped_len =3D=3D 0) {$

ERROR: spaces required around that '=' (ctx:WxV)
#4598: FILE: drivers/net/atl1e/atl1e_main.c:1770:
+               if (mapped_len =3D=3D 0) {
                               ^

ERROR: spaces required around that '=' (ctx:VxV)
#4598: FILE: drivers/net/atl1e/atl1e_main.c:1770:
+               if (mapped_len =3D=3D 0) {
                                  ^

ERROR: do not use assignment in if condition
#4598: FILE: drivers/net/atl1e/atl1e_main.c:1770:
+               if (mapped_len =3D=3D 0) {

ERROR: code indent should use tabs where possible
#4599: FILE: drivers/net/atl1e/atl1e_main.c:1771:
+                       use_tpd =3D tpd;$

ERROR: spaces required around that '=' (ctx:WxV)
#4599: FILE: drivers/net/atl1e/atl1e_main.c:1771:
+                       use_tpd =3D tpd;
                                ^

ERROR: code indent should use tabs where possible
#4600: FILE: drivers/net/atl1e/atl1e_main.c:1772:
+               } else {$

ERROR: code indent should use tabs where possible
#4601: FILE: drivers/net/atl1e/atl1e_main.c:1773:
+                       use_tpd =3D atl1e_get_tpd(adapter);$

ERROR: spaces required around that '=' (ctx:WxV)
#4601: FILE: drivers/net/atl1e/atl1e_main.c:1773:
+                       use_tpd =3D atl1e_get_tpd(adapter);
                                ^

ERROR: code indent should use tabs where possible
#4602: FILE: drivers/net/atl1e/atl1e_main.c:1774:
+                       memcpy(use_tpd, tpd, sizeof(struct atl1e_tpd_desc))=$

ERROR: spaces required around that '=' (ctx:VxE)
#4602: FILE: drivers/net/atl1e/atl1e_main.c:1774:
+                       memcpy(use_tpd, tpd, sizeof(struct atl1e_tpd_desc))=
                                                                           ^

ERROR: code indent should use tabs where possible
#4604: FILE: drivers/net/atl1e/atl1e_main.c:1775:
+               }$

ERROR: code indent should use tabs where possible
#4605: FILE: drivers/net/atl1e/atl1e_main.c:1776:
+               tx_buffer =3D atl1e_get_tx_buffer(adapter, use_tpd);$

ERROR: spaces required around that '=' (ctx:WxV)
#4605: FILE: drivers/net/atl1e/atl1e_main.c:1776:
+               tx_buffer =3D atl1e_get_tx_buffer(adapter, use_tpd);
                          ^

ERROR: code indent should use tabs where possible
#4606: FILE: drivers/net/atl1e/atl1e_main.c:1777:
+               tx_buffer->skb =3D NULL;$

ERROR: spaces required around that '=' (ctx:WxV)
#4606: FILE: drivers/net/atl1e/atl1e_main.c:1777:
+               tx_buffer->skb =3D NULL;
                               ^

ERROR: code indent should use tabs where possible
#4608: FILE: drivers/net/atl1e/atl1e_main.c:1779:
+               tx_buffer->length =3D map_len =3D$

ERROR: spaces required around that '=' (ctx:WxV)
#4608: FILE: drivers/net/atl1e/atl1e_main.c:1779:
+               tx_buffer->length =3D map_len =3D
                                  ^

ERROR: spaces required around that '=' (ctx:WxV)
#4608: FILE: drivers/net/atl1e/atl1e_main.c:1779:
+               tx_buffer->length =3D map_len =3D
                                              ^

ERROR: code indent should use tabs where possible
#4609: FILE: drivers/net/atl1e/atl1e_main.c:1780:
+                       ((buf_len - mapped_len) >=3D MAX_TX_BUF_LEN) ?$

ERROR: spaces required around that '>=' (ctx:WxV)
#4609: FILE: drivers/net/atl1e/atl1e_main.c:1780:
+                       ((buf_len - mapped_len) >=3D MAX_TX_BUF_LEN) ?
                                                ^

ERROR: code indent should use tabs where possible
#4610: FILE: drivers/net/atl1e/atl1e_main.c:1781:
+                       MAX_TX_BUF_LEN : (buf_len - mapped_len);$

ERROR: code indent should use tabs where possible
#4611: FILE: drivers/net/atl1e/atl1e_main.c:1782:
+               tx_buffer->dma =3D$

ERROR: spaces required around that '=' (ctx:WxV)
#4611: FILE: drivers/net/atl1e/atl1e_main.c:1782:
+               tx_buffer->dma =3D
                               ^

ERROR: code indent should use tabs where possible
#4612: FILE: drivers/net/atl1e/atl1e_main.c:1783:
+                       pci_map_single(adapter->pdev, skb->data + mapped_le=$

ERROR: spaces required around that '=' (ctx:VxE)
#4612: FILE: drivers/net/atl1e/atl1e_main.c:1783:
+                       pci_map_single(adapter->pdev, skb->data + mapped_le=
                                                                           ^

ERROR: code indent should use tabs where possible
#4614: FILE: drivers/net/atl1e/atl1e_main.c:1784:
+                                       map_len, PCI_DMA_TODEVICE);$

ERROR: code indent should use tabs where possible
#4615: FILE: drivers/net/atl1e/atl1e_main.c:1785:
+               mapped_len  +=3D map_len;$

ERROR: spaces required around that '+=' (ctx:WxV)
#4615: FILE: drivers/net/atl1e/atl1e_main.c:1785:
+               mapped_len  +=3D map_len;
                            ^

ERROR: code indent should use tabs where possible
#4616: FILE: drivers/net/atl1e/atl1e_main.c:1786:
+               use_tpd->buffer_addr =3D cpu_to_le64(tx_buffer->dma);$

ERROR: spaces required around that '=' (ctx:WxV)
#4616: FILE: drivers/net/atl1e/atl1e_main.c:1786:
+               use_tpd->buffer_addr =3D cpu_to_le64(tx_buffer->dma);
                                     ^

ERROR: code indent should use tabs where possible
#4617: FILE: drivers/net/atl1e/atl1e_main.c:1787:
+               use_tpd->word2 =3D (use_tpd->word2 & (~TPD_BUFLEN_MASK)) |$

WARNING: space prohibited between function name and open parenthesis '('
#4617: FILE: drivers/net/atl1e/atl1e_main.c:1787:
+               use_tpd->word2 =3D (use_tpd->word2 & (~TPD_BUFLEN_MASK)) |

ERROR: spaces required around that '=' (ctx:WxV)
#4617: FILE: drivers/net/atl1e/atl1e_main.c:1787:
+               use_tpd->word2 =3D (use_tpd->word2 & (~TPD_BUFLEN_MASK)) |
                               ^

ERROR: code indent should use tabs where possible
#4618: FILE: drivers/net/atl1e/atl1e_main.c:1788:
+                       ((cpu_to_le32(tx_buffer->length) &$

ERROR: code indent should use tabs where possible
#4619: FILE: drivers/net/atl1e/atl1e_main.c:1789:
+                       TPD_BUFLEN_MASK) << TPD_BUFLEN_SHIFT);$

ERROR: spaces required around that '=' (ctx:WxV)
#4622: FILE: drivers/net/atl1e/atl1e_main.c:1792:
+       for (f =3D 0; f < nr_frags; f++) {
               ^

ERROR: code indent should use tabs where possible
#4623: FILE: drivers/net/atl1e/atl1e_main.c:1793:
+               struct skb_frag_struct *frag;$

ERROR: code indent should use tabs where possible
#4624: FILE: drivers/net/atl1e/atl1e_main.c:1794:
+               u16 i;$

ERROR: code indent should use tabs where possible
#4625: FILE: drivers/net/atl1e/atl1e_main.c:1795:
+               u16 seg_num;$

ERROR: code indent should use tabs where possible
#4627: FILE: drivers/net/atl1e/atl1e_main.c:1797:
+               frag =3D &skb_shinfo(skb)->frags[f];$

ERROR: spaces required around that '=' (ctx:WxV)
#4627: FILE: drivers/net/atl1e/atl1e_main.c:1797:
+               frag =3D &skb_shinfo(skb)->frags[f];
                     ^

ERROR: need consistent spacing around '&' (ctx:WxV)
#4627: FILE: drivers/net/atl1e/atl1e_main.c:1797:
+               frag =3D &skb_shinfo(skb)->frags[f];
                         ^

ERROR: code indent should use tabs where possible
#4628: FILE: drivers/net/atl1e/atl1e_main.c:1798:
+               buf_len =3D frag->size;$

ERROR: spaces required around that '=' (ctx:WxV)
#4628: FILE: drivers/net/atl1e/atl1e_main.c:1798:
+               buf_len =3D frag->size;
                        ^

ERROR: code indent should use tabs where possible
#4630: FILE: drivers/net/atl1e/atl1e_main.c:1800:
+               seg_num =3D (buf_len + MAX_TX_BUF_LEN - 1) / MAX_TX_BUF_LEN=$

WARNING: space prohibited between function name and open parenthesis '('
#4630: FILE: drivers/net/atl1e/atl1e_main.c:1800:
+               seg_num =3D (buf_len + MAX_TX_BUF_LEN - 1) / MAX_TX_BUF_LEN=

ERROR: spaces required around that '=' (ctx:WxV)
#4630: FILE: drivers/net/atl1e/atl1e_main.c:1800:
+               seg_num =3D (buf_len + MAX_TX_BUF_LEN - 1) / MAX_TX_BUF_LEN=
                        ^

ERROR: spaces required around that '=' (ctx:VxE)
#4630: FILE: drivers/net/atl1e/atl1e_main.c:1800:
+               seg_num =3D (buf_len + MAX_TX_BUF_LEN - 1) / MAX_TX_BUF_LEN=
                                                                           ^

ERROR: code indent should use tabs where possible
#4632: FILE: drivers/net/atl1e/atl1e_main.c:1801:
+               for (i =3D 0; i < seg_num; i++) {$

ERROR: spaces required around that '=' (ctx:WxV)
#4632: FILE: drivers/net/atl1e/atl1e_main.c:1801:
+               for (i =3D 0; i < seg_num; i++) {
                       ^

ERROR: code indent should use tabs where possible
#4633: FILE: drivers/net/atl1e/atl1e_main.c:1802:
+                       use_tpd =3D atl1e_get_tpd(adapter);$

ERROR: spaces required around that '=' (ctx:WxV)
#4633: FILE: drivers/net/atl1e/atl1e_main.c:1802:
+                       use_tpd =3D atl1e_get_tpd(adapter);
                                ^

ERROR: code indent should use tabs where possible
#4634: FILE: drivers/net/atl1e/atl1e_main.c:1803:
+                       memcpy(use_tpd, tpd, sizeof(struct atl1e_tpd_desc))=$

ERROR: spaces required around that '=' (ctx:VxE)
#4634: FILE: drivers/net/atl1e/atl1e_main.c:1803:
+                       memcpy(use_tpd, tpd, sizeof(struct atl1e_tpd_desc))=
                                                                           ^

ERROR: code indent should use tabs where possible
#4637: FILE: drivers/net/atl1e/atl1e_main.c:1805:
+                       tx_buffer =3D atl1e_get_tx_buffer(adapter, use_tpd)=$

ERROR: spaces required around that '=' (ctx:WxV)
#4637: FILE: drivers/net/atl1e/atl1e_main.c:1805:
+                       tx_buffer =3D atl1e_get_tx_buffer(adapter, use_tpd)=
                                  ^

ERROR: spaces required around that '=' (ctx:VxE)
#4637: FILE: drivers/net/atl1e/atl1e_main.c:1805:
+                       tx_buffer =3D atl1e_get_tx_buffer(adapter, use_tpd)=
                                                                           ^

ERROR: code indent should use tabs where possible
#4639: FILE: drivers/net/atl1e/atl1e_main.c:1806:
+                       if (tx_buffer->skb)$

ERROR: code indent should use tabs where possible
#4640: FILE: drivers/net/atl1e/atl1e_main.c:1807:
+                               BUG();$

ERROR: code indent should use tabs where possible
#4642: FILE: drivers/net/atl1e/atl1e_main.c:1809:
+                       tx_buffer->skb =3D NULL;$

ERROR: spaces required around that '=' (ctx:WxV)
#4642: FILE: drivers/net/atl1e/atl1e_main.c:1809:
+                       tx_buffer->skb =3D NULL;
                                       ^

ERROR: code indent should use tabs where possible
#4643: FILE: drivers/net/atl1e/atl1e_main.c:1810:
+                       tx_buffer->length =3D$

ERROR: spaces required around that '=' (ctx:WxV)
#4643: FILE: drivers/net/atl1e/atl1e_main.c:1810:
+                       tx_buffer->length =3D
                                          ^

ERROR: code indent should use tabs where possible
#4644: FILE: drivers/net/atl1e/atl1e_main.c:1811:
+                               (buf_len > MAX_TX_BUF_LEN) ?$

ERROR: code indent should use tabs where possible
#4645: FILE: drivers/net/atl1e/atl1e_main.c:1812:
+                               MAX_TX_BUF_LEN : buf_len;$

ERROR: code indent should use tabs where possible
#4646: FILE: drivers/net/atl1e/atl1e_main.c:1813:
+                       buf_len -=3D tx_buffer->length;$

ERROR: spaces required around that '-=' (ctx:WxV)
#4646: FILE: drivers/net/atl1e/atl1e_main.c:1813:
+                       buf_len -=3D tx_buffer->length;
                                ^

ERROR: code indent should use tabs where possible
#4648: FILE: drivers/net/atl1e/atl1e_main.c:1815:
+                       tx_buffer->dma =3D$

ERROR: spaces required around that '=' (ctx:WxV)
#4648: FILE: drivers/net/atl1e/atl1e_main.c:1815:
+                       tx_buffer->dma =3D
                                       ^

ERROR: code indent should use tabs where possible
#4649: FILE: drivers/net/atl1e/atl1e_main.c:1816:
+                               pci_map_page(adapter->pdev, frag->page,$

ERROR: code indent should use tabs where possible
#4650: FILE: drivers/net/atl1e/atl1e_main.c:1817:
+                                               frag->page_offset +$

ERROR: code indent should use tabs where possible
#4651: FILE: drivers/net/atl1e/atl1e_main.c:1818:
+                                               (i * MAX_TX_BUF_LEN),$

ERROR: code indent should use tabs where possible
#4652: FILE: drivers/net/atl1e/atl1e_main.c:1819:
+                                               tx_buffer->length,$

ERROR: code indent should use tabs where possible
#4653: FILE: drivers/net/atl1e/atl1e_main.c:1820:
+                                               PCI_DMA_TODEVICE);$

ERROR: code indent should use tabs where possible
#4654: FILE: drivers/net/atl1e/atl1e_main.c:1821:
+                       use_tpd->buffer_addr =3D cpu_to_le64(tx_buffer->dma=$

ERROR: spaces required around that '=' (ctx:WxV)
#4654: FILE: drivers/net/atl1e/atl1e_main.c:1821:
+                       use_tpd->buffer_addr =3D cpu_to_le64(tx_buffer->dma=
                                             ^

ERROR: spaces required around that '=' (ctx:VxE)
#4654: FILE: drivers/net/atl1e/atl1e_main.c:1821:
+                       use_tpd->buffer_addr =3D cpu_to_le64(tx_buffer->dma=
                                                                           ^

ERROR: code indent should use tabs where possible
#4656: FILE: drivers/net/atl1e/atl1e_main.c:1822:
+                       use_tpd->word2 =3D (use_tpd->word2 & (~TPD_BUFLEN_M=$

WARNING: space prohibited between function name and open parenthesis '('
#4656: FILE: drivers/net/atl1e/atl1e_main.c:1822:
+                       use_tpd->word2 =3D (use_tpd->word2 & (~TPD_BUFLEN_M=

ERROR: spaces required around that '=' (ctx:WxV)
#4656: FILE: drivers/net/atl1e/atl1e_main.c:1822:
+                       use_tpd->word2 =3D (use_tpd->word2 & (~TPD_BUFLEN_M=
                                       ^

ERROR: spaces required around that '=' (ctx:VxE)
#4656: FILE: drivers/net/atl1e/atl1e_main.c:1822:
+                       use_tpd->word2 =3D (use_tpd->word2 & (~TPD_BUFLEN_M=
                                                                           ^

ERROR: code indent should use tabs where possible
#4658: FILE: drivers/net/atl1e/atl1e_main.c:1823:
+                                       ((cpu_to_le32(tx_buffer->length) &$

ERROR: code indent should use tabs where possible
#4659: FILE: drivers/net/atl1e/atl1e_main.c:1824:
+                                       TPD_BUFLEN_MASK) << TPD_BUFLEN_SHIF=$

ERROR: spaces required around that '=' (ctx:VxE)
#4659: FILE: drivers/net/atl1e/atl1e_main.c:1824:
+                                       TPD_BUFLEN_MASK) << TPD_BUFLEN_SHIF=
                                                                           ^

ERROR: code indent should use tabs where possible
#4661: FILE: drivers/net/atl1e/atl1e_main.c:1825:
+               }$

ERROR: code indent should use tabs where possible
#4665: FILE: drivers/net/atl1e/atl1e_main.c:1829:
+               /* note this one is a tcp header */$

ERROR: code indent should use tabs where possible
#4666: FILE: drivers/net/atl1e/atl1e_main.c:1830:
+               tpd->word3 |=3D 1 << TPD_HDRFLAG_SHIFT;$

ERROR: spaces required around that '|=' (ctx:WxV)
#4666: FILE: drivers/net/atl1e/atl1e_main.c:1830:
+               tpd->word3 |=3D 1 << TPD_HDRFLAG_SHIFT;
                           ^

ERROR: spaces required around that '|=' (ctx:WxV)
#4669: FILE: drivers/net/atl1e/atl1e_main.c:1833:
+       use_tpd->word3 |=3D 1 << TPD_EOP_SHIFT;
                       ^

ERROR: code indent should use tabs where possible
#4671: FILE: drivers/net/atl1e/atl1e_main.c:1835:
+          so it will be free after unmap */$

ERROR: spaces required around that '=' (ctx:WxV)
#4672: FILE: drivers/net/atl1e/atl1e_main.c:1836:
+       tx_buffer->skb =3D skb;
                       ^

ERROR: code indent should use tabs where possible
#4676: FILE: drivers/net/atl1e/atl1e_main.c:1840:
+                          struct atl1e_tpd_desc *tpd)$

ERROR: spaces required around that '=' (ctx:WxV)
#4678: FILE: drivers/net/atl1e/atl1e_main.c:1842:
+       struct atl1e_tx_ring *tx_ring =3D &adapter->tx_ring;
                                      ^

ERROR: need consistent spacing around '&' (ctx:WxV)
#4678: FILE: drivers/net/atl1e/atl1e_main.c:1842:
+       struct atl1e_tx_ring *tx_ring =3D &adapter->tx_ring;
                                          ^

ERROR: code indent should use tabs where possible
#4680: FILE: drivers/net/atl1e/atl1e_main.c:1844:
+        * know there are new descriptors to fetch.  (Only$

ERROR: code indent should use tabs where possible
#4681: FILE: drivers/net/atl1e/atl1e_main.c:1845:
+        * applicable for weak-ordered memory model archs,$

ERROR: code indent should use tabs where possible
#4682: FILE: drivers/net/atl1e/atl1e_main.c:1846:
+        * such as IA-64). */$

ERROR: spaces required around that '=' (ctx:VxE)
#4684: FILE: drivers/net/atl1e/atl1e_main.c:1848:
+       AT_WRITE_REG(&adapter->hw, REG_MB_TPD_PROD_IDX, tx_ring->next_to_us=
                                                                           ^

ERROR: spaces required around that '=' (ctx:VxE)
#4688: FILE: drivers/net/atl1e/atl1e_main.c:1851:
+static int atl1e_xmit_frame(struct sk_buff *skb, struct net_device *netdev=
                                                                           ^

ERROR: that open brace { should be on the previous line
#4690: FILE: drivers/net/atl1e/atl1e_main.c:1852:
+static int atl1e_xmit_frame(struct sk_buff *skb, struct net_device *netdev=
+{

ERROR: spaces required around that '=' (ctx:WxV)
#4691: FILE: drivers/net/atl1e/atl1e_main.c:1853:
+       struct atl1e_adapter *adapter =3D netdev_priv(netdev);
                                      ^

ERROR: spaces required around that '=' (ctx:WxV)
#4693: FILE: drivers/net/atl1e/atl1e_main.c:1855:
+       u16 tpd_req =3D 1;
                    ^

ERROR: code indent should use tabs where possible
#4697: FILE: drivers/net/atl1e/atl1e_main.c:1859:
+               dev_kfree_skb_any(skb);$

ERROR: code indent should use tabs where possible
#4698: FILE: drivers/net/atl1e/atl1e_main.c:1860:
+               return NETDEV_TX_OK;$

ERROR: spaces required around that '<=' (ctx:WxV)
#4701: FILE: drivers/net/atl1e/atl1e_main.c:1863:
+       if (unlikely(skb->len <=3D 0)) {
                              ^

ERROR: code indent should use tabs where possible
#4702: FILE: drivers/net/atl1e/atl1e_main.c:1864:
+               dev_kfree_skb_any(skb);$

ERROR: code indent should use tabs where possible
#4703: FILE: drivers/net/atl1e/atl1e_main.c:1865:
+               return NETDEV_TX_OK;$

ERROR: spaces required around that '=' (ctx:WxV)
#4705: FILE: drivers/net/atl1e/atl1e_main.c:1867:
+       tpd_req =3D atl1e_cal_tdp_req(skb);
                ^

ERROR: code indent should use tabs where possible
#4707: FILE: drivers/net/atl1e/atl1e_main.c:1869:
+               return NETDEV_TX_LOCKED;$

ERROR: code indent should use tabs where possible
#4710: FILE: drivers/net/atl1e/atl1e_main.c:1872:
+               /* no enough descriptor, just stop queue */$

ERROR: code indent should use tabs where possible
#4711: FILE: drivers/net/atl1e/atl1e_main.c:1873:
+               netif_stop_queue(netdev);$

ERROR: code indent should use tabs where possible
#4712: FILE: drivers/net/atl1e/atl1e_main.c:1874:
+               spin_unlock_irqrestore(&adapter->tx_lock, flags);$

ERROR: code indent should use tabs where possible
#4713: FILE: drivers/net/atl1e/atl1e_main.c:1875:
+               return NETDEV_TX_BUSY;$

ERROR: spaces required around that '=' (ctx:WxV)
#4716: FILE: drivers/net/atl1e/atl1e_main.c:1878:
+       tpd =3D atl1e_get_tpd(adapter);
            ^

ERROR: code indent should use tabs where possible
#4719: FILE: drivers/net/atl1e/atl1e_main.c:1881:
+               u16 vlan_tag =3D vlan_tx_tag_get(skb);$

ERROR: spaces required around that '=' (ctx:WxV)
#4719: FILE: drivers/net/atl1e/atl1e_main.c:1881:
+               u16 vlan_tag =3D vlan_tx_tag_get(skb);
                             ^

ERROR: code indent should use tabs where possible
#4720: FILE: drivers/net/atl1e/atl1e_main.c:1882:
+               u16 atl1e_vlan_tag;$

ERROR: code indent should use tabs where possible
#4722: FILE: drivers/net/atl1e/atl1e_main.c:1884:
+               tpd->word3 |=3D 1 << TPD_INS_VL_TAG_SHIFT;$

ERROR: spaces required around that '|=' (ctx:WxV)
#4722: FILE: drivers/net/atl1e/atl1e_main.c:1884:
+               tpd->word3 |=3D 1 << TPD_INS_VL_TAG_SHIFT;
                           ^

ERROR: code indent should use tabs where possible
#4723: FILE: drivers/net/atl1e/atl1e_main.c:1885:
+               AT_VLAN_TAG_TO_TPD_TAG(vlan_tag, atl1e_vlan_tag);$

ERROR: code indent should use tabs where possible
#4724: FILE: drivers/net/atl1e/atl1e_main.c:1886:
+               tpd->word2 |=3D (atl1e_vlan_tag & TPD_VLANTAG_MASK) <<$

WARNING: space prohibited between function name and open parenthesis '('
#4724: FILE: drivers/net/atl1e/atl1e_main.c:1886:
+               tpd->word2 |=3D (atl1e_vlan_tag & TPD_VLANTAG_MASK) <<

ERROR: spaces required around that '|=' (ctx:WxV)
#4724: FILE: drivers/net/atl1e/atl1e_main.c:1886:
+               tpd->word2 |=3D (atl1e_vlan_tag & TPD_VLANTAG_MASK) <<
                           ^

ERROR: code indent should use tabs where possible
#4725: FILE: drivers/net/atl1e/atl1e_main.c:1887:
+                               TPD_VLAN_SHIFT;$

ERROR: spaces required around that '=' (ctx:WxV)
#4728: FILE: drivers/net/atl1e/atl1e_main.c:1890:
+       if (skb->protocol =3D=3D ntohs(ETH_P_8021Q))
                          ^

ERROR: spaces required around that '=' (ctx:VxV)
#4728: FILE: drivers/net/atl1e/atl1e_main.c:1890:
+       if (skb->protocol =3D=3D ntohs(ETH_P_8021Q))
                             ^

ERROR: do not use assignment in if condition
#4728: FILE: drivers/net/atl1e/atl1e_main.c:1890:
+       if (skb->protocol =3D=3D ntohs(ETH_P_8021Q))

ERROR: code indent should use tabs where possible
#4729: FILE: drivers/net/atl1e/atl1e_main.c:1891:
+               tpd->word3 |=3D 1 << TPD_VL_TAGGED_SHIFT;$

ERROR: spaces required around that '|=' (ctx:WxV)
#4729: FILE: drivers/net/atl1e/atl1e_main.c:1891:
+               tpd->word3 |=3D 1 << TPD_VL_TAGGED_SHIFT;
                           ^

ERROR: spaces required around that '!=' (ctx:WxV)
#4731: FILE: drivers/net/atl1e/atl1e_main.c:1893:
+       if (skb_network_offset(skb) !=3D ETH_HLEN)
                                    ^

ERROR: code indent should use tabs where possible
#4732: FILE: drivers/net/atl1e/atl1e_main.c:1894:
+               tpd->word3 |=3D 1 << TPD_ETHTYPE_SHIFT; /* 802.3 frame */$

ERROR: spaces required around that '|=' (ctx:WxV)
#4732: FILE: drivers/net/atl1e/atl1e_main.c:1894:
+               tpd->word3 |=3D 1 << TPD_ETHTYPE_SHIFT; /* 802.3 frame */
                           ^

ERROR: spaces required around that '!=' (ctx:WxV)
#4735: FILE: drivers/net/atl1e/atl1e_main.c:1897:
+       if (atl1e_tso_csum(adapter, skb, tpd) !=3D 0) {
                                              ^

ERROR: code indent should use tabs where possible
#4736: FILE: drivers/net/atl1e/atl1e_main.c:1898:
+               spin_unlock_irqrestore(&adapter->tx_lock, flags);$

ERROR: code indent should use tabs where possible
#4737: FILE: drivers/net/atl1e/atl1e_main.c:1899:
+               dev_kfree_skb_any(skb);$

ERROR: code indent should use tabs where possible
#4738: FILE: drivers/net/atl1e/atl1e_main.c:1900:
+               return NETDEV_TX_OK;$

ERROR: spaces required around that '=' (ctx:WxV)
#4744: FILE: drivers/net/atl1e/atl1e_main.c:1906:
+       netdev->trans_start =3D jiffies;
                            ^

ERROR: spaces required around that '=' (ctx:WxV)
#4751: FILE: drivers/net/atl1e/atl1e_main.c:1913:
+       struct net_device *netdev =3D adapter->netdev;
                                  ^

ERROR: code indent should use tabs where possible
#4756: FILE: drivers/net/atl1e/atl1e_main.c:1918:
+               pci_disable_msi(adapter->pdev);$

ERROR: spaces required around that '=' (ctx:WxV)
#4761: FILE: drivers/net/atl1e/atl1e_main.c:1923:
+       struct pci_dev    *pdev   =3D adapter->pdev;
                                  ^

ERROR: spaces required around that '=' (ctx:WxV)
#4762: FILE: drivers/net/atl1e/atl1e_main.c:1924:
+       struct net_device *netdev =3D adapter->netdev;
                                  ^

ERROR: spaces required around that '=' (ctx:WxV)
#4763: FILE: drivers/net/atl1e/atl1e_main.c:1925:
+       int flags =3D 0;
                  ^

ERROR: spaces required around that '=' (ctx:WxV)
#4764: FILE: drivers/net/atl1e/atl1e_main.c:1926:
+       int err =3D 0;
                ^

ERROR: spaces required around that '=' (ctx:WxV)
#4766: FILE: drivers/net/atl1e/atl1e_main.c:1928:
+       adapter->have_msi =3D true;
                          ^

ERROR: spaces required around that '=' (ctx:WxV)
#4767: FILE: drivers/net/atl1e/atl1e_main.c:1929:
+       err =3D pci_enable_msi(adapter->pdev);
            ^

ERROR: code indent should use tabs where possible
#4769: FILE: drivers/net/atl1e/atl1e_main.c:1931:
+               dev_dbg(&pdev->dev,$

ERROR: code indent should use tabs where possible
#4770: FILE: drivers/net/atl1e/atl1e_main.c:1932:
+                       "Unable to allocate MSI interrupt Error: %d\n", err=$

ERROR: spaces required around that '=' (ctx:VxE)
#4770: FILE: drivers/net/atl1e/atl1e_main.c:1932:
+                       "Unable to allocate MSI interrupt Error: %d\n", err=
                                                                           ^

ERROR: code indent should use tabs where possible
#4772: FILE: drivers/net/atl1e/atl1e_main.c:1933:
+               adapter->have_msi =3D false;$

ERROR: spaces required around that '=' (ctx:WxV)
#4772: FILE: drivers/net/atl1e/atl1e_main.c:1933:
+               adapter->have_msi =3D false;
                                  ^

ERROR: code indent should use tabs where possible
#4774: FILE: drivers/net/atl1e/atl1e_main.c:1935:
+               netdev->irq =3D pdev->irq;$

ERROR: spaces required around that '=' (ctx:WxV)
#4774: FILE: drivers/net/atl1e/atl1e_main.c:1935:
+               netdev->irq =3D pdev->irq;
                            ^

ERROR: code indent should use tabs where possible
#4778: FILE: drivers/net/atl1e/atl1e_main.c:1939:
+               flags |=3D IRQF_SHARED;$

ERROR: spaces required around that '|=' (ctx:WxV)
#4778: FILE: drivers/net/atl1e/atl1e_main.c:1939:
+               flags |=3D IRQF_SHARED;
                      ^

ERROR: spaces required around that '=' (ctx:WxV)
#4779: FILE: drivers/net/atl1e/atl1e_main.c:1940:
+       err =3D request_irq(adapter->pdev->irq, &atl1e_intr, flags,
            ^

ERROR: code indent should use tabs where possible
#4780: FILE: drivers/net/atl1e/atl1e_main.c:1941:
+                       netdev->name, netdev);$

ERROR: code indent should use tabs where possible
#4782: FILE: drivers/net/atl1e/atl1e_main.c:1943:
+               dev_dbg(&pdev->dev,$

ERROR: code indent should use tabs where possible
#4783: FILE: drivers/net/atl1e/atl1e_main.c:1944:
+                       "Unable to allocate interrupt Error: %d\n", err);$

ERROR: code indent should use tabs where possible
#4784: FILE: drivers/net/atl1e/atl1e_main.c:1945:
+               if (adapter->have_msi)$

ERROR: code indent should use tabs where possible
#4785: FILE: drivers/net/atl1e/atl1e_main.c:1946:
+                       pci_disable_msi(adapter->pdev);$

ERROR: code indent should use tabs where possible
#4786: FILE: drivers/net/atl1e/atl1e_main.c:1947:
+               return err;$

ERROR: spaces required around that '=' (ctx:WxV)
#4794: FILE: drivers/net/atl1e/atl1e_main.c:1955:
+       struct net_device *netdev =3D adapter->netdev;
                                  ^

ERROR: spaces required around that '=' (ctx:WxV)
#4795: FILE: drivers/net/atl1e/atl1e_main.c:1956:
+       int err =3D 0;
                ^

ERROR: spaces required around that '=' (ctx:WxV)
#4800: FILE: drivers/net/atl1e/atl1e_main.c:1961:
+       err =3D atl1e_init_hw(&adapter->hw);
            ^

ERROR: code indent should use tabs where possible
#4802: FILE: drivers/net/atl1e/atl1e_main.c:1963:
+               err =3D -EIO;$

ERROR: spaces required around that '=' (ctx:WxV)
#4802: FILE: drivers/net/atl1e/atl1e_main.c:1963:
+               err =3D -EIO;
                    ^

ERROR: need consistent spacing around '-' (ctx:WxV)
#4802: FILE: drivers/net/atl1e/atl1e_main.c:1963:
+               err =3D -EIO;
                        ^

ERROR: code indent should use tabs where possible
#4803: FILE: drivers/net/atl1e/atl1e_main.c:1964:
+               return err;$

ERROR: code indent should use tabs where possible
#4810: FILE: drivers/net/atl1e/atl1e_main.c:1971:
+               err =3D -EIO;$

ERROR: spaces required around that '=' (ctx:WxV)
#4810: FILE: drivers/net/atl1e/atl1e_main.c:1971:
+               err =3D -EIO;
                    ^

ERROR: need consistent spacing around '-' (ctx:WxV)
#4810: FILE: drivers/net/atl1e/atl1e_main.c:1971:
+               err =3D -EIO;
                        ^

ERROR: code indent should use tabs where possible
#4811: FILE: drivers/net/atl1e/atl1e_main.c:1972:
+               goto err_up;$

ERROR: spaces required around that '=' (ctx:WxV)
#4817: FILE: drivers/net/atl1e/atl1e_main.c:1978:
+       val =3D AT_READ_REG(&adapter->hw, REG_MASTER_CTRL);
            ^

ERROR: code indent should use tabs where possible
#4819: FILE: drivers/net/atl1e/atl1e_main.c:1980:
+                     val | MASTER_CTRL_MANUAL_INT);$

ERROR: spaces required around that '=' (ctx:WxV)
#4827: FILE: drivers/net/atl1e/atl1e_main.c:1988:
+       struct net_device *netdev =3D adapter->netdev;
                                  ^

ERROR: code indent should use tabs where possible
#4830: FILE: drivers/net/atl1e/atl1e_main.c:1991:
+        * reschedule our watchdog timer */$

ERROR: spaces required around that '=' (ctx:WxV)
#4848: FILE: drivers/net/atl1e/atl1e_main.c:2009:
+       adapter->link_speed =3D SPEED_0;
                            ^

ERROR: spaces required around that '=' (ctx:WxV)
#4849: FILE: drivers/net/atl1e/atl1e_main.c:2010:
+       adapter->link_duplex =3D -1;
                             ^

ERROR: need consistent spacing around '-' (ctx:WxV)
#4849: FILE: drivers/net/atl1e/atl1e_main.c:2010:
+       adapter->link_duplex =3D -1;
                                 ^

ERROR: spaces required around that '=' (ctx:WxV)
#4868: FILE: drivers/net/atl1e/atl1e_main.c:2029:
+       struct atl1e_adapter *adapter =3D netdev_priv(netdev);
                                      ^

ERROR: code indent should use tabs where possible
#4873: FILE: drivers/net/atl1e/atl1e_main.c:2034:
+               return -EBUSY;$

ERROR: spaces required around that '=' (ctx:WxV)
#4877: FILE: drivers/net/atl1e/atl1e_main.c:2038:
+       err =3D atl1e_setup_ring_resources(adapter);
            ^

ERROR: code indent should use tabs where possible
#4879: FILE: drivers/net/atl1e/atl1e_main.c:2040:
+               return err;$

ERROR: spaces required around that '=' (ctx:WxV)
#4881: FILE: drivers/net/atl1e/atl1e_main.c:2042:
+       err =3D atl1e_request_irq(adapter);
            ^

ERROR: code indent should use tabs where possible
#4883: FILE: drivers/net/atl1e/atl1e_main.c:2044:
+               goto err_req_irq;$

ERROR: spaces required around that '=' (ctx:WxV)
#4885: FILE: drivers/net/atl1e/atl1e_main.c:2046:
+       err =3D atl1e_up(adapter);
            ^

ERROR: code indent should use tabs where possible
#4887: FILE: drivers/net/atl1e/atl1e_main.c:2048:
+               goto err_up;$

ERROR: spaces required around that '=' (ctx:WxV)
#4913: FILE: drivers/net/atl1e/atl1e_main.c:2074:
+       struct atl1e_adapter *adapter =3D netdev_priv(netdev);
                                      ^

ERROR: spaces required around that '=' (ctx:WxV)
#4926: FILE: drivers/net/atl1e/atl1e_main.c:2087:
+       struct net_device *netdev =3D pci_get_drvdata(pdev);
                                  ^

ERROR: spaces required around that '=' (ctx:WxV)
#4927: FILE: drivers/net/atl1e/atl1e_main.c:2088:
+       struct atl1e_adapter *adapter =3D netdev_priv(netdev);
                                      ^

ERROR: spaces required around that '=' (ctx:WxV)
#4928: FILE: drivers/net/atl1e/atl1e_main.c:2089:
+       struct atl1e_hw *hw =3D &adapter->hw;
                            ^

ERROR: need consistent spacing around '&' (ctx:WxV)
#4928: FILE: drivers/net/atl1e/atl1e_main.c:2089:
+       struct atl1e_hw *hw =3D &adapter->hw;
                                ^

ERROR: spaces required around that '=' (ctx:WxV)
#4929: FILE: drivers/net/atl1e/atl1e_main.c:2090:
+       u32 ctrl =3D 0;
                 ^

ERROR: spaces required around that '=' (ctx:WxV)
#4930: FILE: drivers/net/atl1e/atl1e_main.c:2091:
+       u32 mac_ctrl_data =3D 0;
                          ^

ERROR: spaces required around that '=' (ctx:WxV)
#4931: FILE: drivers/net/atl1e/atl1e_main.c:2092:
+       u32 wol_ctrl_data =3D 0;
                          ^

ERROR: spaces required around that '=' (ctx:WxV)
#4932: FILE: drivers/net/atl1e/atl1e_main.c:2093:
+       u16 mii_advertise_data =3D 0;
                               ^

ERROR: spaces required around that '=' (ctx:WxV)
#4933: FILE: drivers/net/atl1e/atl1e_main.c:2094:
+       u16 mii_bmsr_data =3D 0;
                          ^

ERROR: spaces required around that '=' (ctx:WxV)
#4934: FILE: drivers/net/atl1e/atl1e_main.c:2095:
+       u16 mii_intr_status_data =3D 0;
                                 ^

ERROR: spaces required around that '=' (ctx:WxV)
#4935: FILE: drivers/net/atl1e/atl1e_main.c:2096:
+       u32 wufc =3D adapter->wol;
                 ^

ERROR: spaces required around that '=' (ctx:WxV)
#4938: FILE: drivers/net/atl1e/atl1e_main.c:2099:
+       int retval =3D 0;
                   ^

ERROR: code indent should use tabs where possible
#4942: FILE: drivers/net/atl1e/atl1e_main.c:2103:
+               WARN_ON(test_bit(__AT_RESETTING, &adapter->flags));$

ERROR: code indent should use tabs where possible
#4943: FILE: drivers/net/atl1e/atl1e_main.c:2104:
+               atl1e_down(adapter);$

ERROR: spaces required around that '=' (ctx:WxV)
#4948: FILE: drivers/net/atl1e/atl1e_main.c:2109:
+       retval =3D pci_save_state(pdev);
               ^

ERROR: code indent should use tabs where possible
#4950: FILE: drivers/net/atl1e/atl1e_main.c:2111:
+               return retval;$

ERROR: code indent should use tabs where possible
#4954: FILE: drivers/net/atl1e/atl1e_main.c:2115:
+               /* get link status */$

ERROR: code indent should use tabs where possible
#4955: FILE: drivers/net/atl1e/atl1e_main.c:2116:
+               atl1e_read_phy_reg(hw, MII_BMSR, (u16 *)&mii_bmsr_data);$

ERROR: code indent should use tabs where possible
#4956: FILE: drivers/net/atl1e/atl1e_main.c:2117:
+               atl1e_read_phy_reg(hw, MII_BMSR, (u16 *)&mii_bmsr_data);$

ERROR: code indent should use tabs where possible
#4958: FILE: drivers/net/atl1e/atl1e_main.c:2119:
+               mii_advertise_data =3D MII_AR_10T_HD_CAPS;$

ERROR: spaces required around that '=' (ctx:WxV)
#4958: FILE: drivers/net/atl1e/atl1e_main.c:2119:
+               mii_advertise_data =3D MII_AR_10T_HD_CAPS;
                                   ^

ERROR: code indent should use tabs where possible
#4960: FILE: drivers/net/atl1e/atl1e_main.c:2121:
+               if ((atl1e_write_phy_reg(hw, MII_AT001_CR, 0) !=3D 0) ||$

ERROR: spaces required around that '!=' (ctx:WxV)
#4960: FILE: drivers/net/atl1e/atl1e_main.c:2121:
+               if ((atl1e_write_phy_reg(hw, MII_AT001_CR, 0) !=3D 0) ||
                                                              ^

ERROR: code indent should use tabs where possible
#4961: FILE: drivers/net/atl1e/atl1e_main.c:2122:
+                   (atl1e_write_phy_reg(hw,$

ERROR: code indent should use tabs where possible
#4962: FILE: drivers/net/atl1e/atl1e_main.c:2123:
+                          MII_ADVERTISE, mii_advertise_data) !=3D 0) ||$

ERROR: spaces required around that '!=' (ctx:WxV)
#4962: FILE: drivers/net/atl1e/atl1e_main.c:2123:
+                          MII_ADVERTISE, mii_advertise_data) !=3D 0) ||
                                                              ^

ERROR: code indent should use tabs where possible
#4963: FILE: drivers/net/atl1e/atl1e_main.c:2124:
+                   (atl1e_phy_commit(hw)) !=3D 0) {$

ERROR: spaces required around that '!=' (ctx:WxV)
#4963: FILE: drivers/net/atl1e/atl1e_main.c:2124:
+                   (atl1e_phy_commit(hw)) !=3D 0) {
                                           ^

ERROR: code indent should use tabs where possible
#4964: FILE: drivers/net/atl1e/atl1e_main.c:2125:
+                       dev_dbg(&pdev->dev, "set phy register failed\n");$

ERROR: code indent should use tabs where possible
#4965: FILE: drivers/net/atl1e/atl1e_main.c:2126:
+                       goto wol_dis;$

ERROR: code indent should use tabs where possible
#4966: FILE: drivers/net/atl1e/atl1e_main.c:2127:
+               }$

ERROR: code indent should use tabs where possible
#4968: FILE: drivers/net/atl1e/atl1e_main.c:2129:
+               hw->phy_configured =3D false; /* re-init PHY when resume */$

ERROR: spaces required around that '=' (ctx:WxV)
#4968: FILE: drivers/net/atl1e/atl1e_main.c:2129:
+               hw->phy_configured =3D false; /* re-init PHY when resume */
                                   ^

ERROR: code indent should use tabs where possible
#4970: FILE: drivers/net/atl1e/atl1e_main.c:2131:
+               /* turn on magic packet wol */$

ERROR: code indent should use tabs where possible
#4971: FILE: drivers/net/atl1e/atl1e_main.c:2132:
+               if (wufc & AT_WUFC_MAG)$

ERROR: code indent should use tabs where possible
#4972: FILE: drivers/net/atl1e/atl1e_main.c:2133:
+                       wol_ctrl_data |=3D WOL_MAGIC_EN | WOL_MAGIC_PME_EN;$

ERROR: spaces required around that '|=' (ctx:WxV)
#4972: FILE: drivers/net/atl1e/atl1e_main.c:2133:
+                       wol_ctrl_data |=3D WOL_MAGIC_EN | WOL_MAGIC_PME_EN;
                                      ^

ERROR: code indent should use tabs where possible
#4974: FILE: drivers/net/atl1e/atl1e_main.c:2135:
+               if (wufc & AT_WUFC_LNKC) {$

ERROR: code indent should use tabs where possible
#4975: FILE: drivers/net/atl1e/atl1e_main.c:2136:
+               /* if orignal link status is link, just wait for retrive li=$

ERROR: code indent should use tabs where possible
#4977: FILE: drivers/net/atl1e/atl1e_main.c:2137:
+                       if (mii_bmsr_data & BMSR_LSTATUS) {$

ERROR: code indent should use tabs where possible
#4978: FILE: drivers/net/atl1e/atl1e_main.c:2138:
+                               for (i =3D 0; i < AT_SUSPEND_LINK_TIMEOUT; =$

ERROR: code indent should use tabs where possible
#4980: FILE: drivers/net/atl1e/atl1e_main.c:2139:
+                                       msleep(100);$

ERROR: code indent should use tabs where possible
#4981: FILE: drivers/net/atl1e/atl1e_main.c:2140:
+                                       atl1e_read_phy_reg(hw, MII_BMSR,$

ERROR: code indent should use tabs where possible
#4982: FILE: drivers/net/atl1e/atl1e_main.c:2141:
+                                                       (u16 *)&mii_bmsr_da=$

ERROR: code indent should use tabs where possible
#4984: FILE: drivers/net/atl1e/atl1e_main.c:2142:
+                                       if (mii_bmsr_data & BMSR_LSTATUS)$

ERROR: code indent should use tabs where possible
#4985: FILE: drivers/net/atl1e/atl1e_main.c:2143:
+                                               break;$

ERROR: code indent should use tabs where possible
#4986: FILE: drivers/net/atl1e/atl1e_main.c:2144:
+                               }$

ERROR: code indent should use tabs where possible
#4988: FILE: drivers/net/atl1e/atl1e_main.c:2146:
+                               if ((mii_bmsr_data & BMSR_LSTATUS) =3D=3D 0=$

ERROR: code indent should use tabs where possible
#4990: FILE: drivers/net/atl1e/atl1e_main.c:2147:
+                                       dev_dbg(&pdev->dev,$

ERROR: code indent should use tabs where possible
#4991: FILE: drivers/net/atl1e/atl1e_main.c:2148:
+                                               "%s: Link may change"$

ERROR: code indent should use tabs where possible
#4992: FILE: drivers/net/atl1e/atl1e_main.c:2149:
+                                               "when suspend\n",$

ERROR: code indent should use tabs where possible
#4993: FILE: drivers/net/atl1e/atl1e_main.c:2150:
+                                               atl1e_driver_name);$

ERROR: code indent should use tabs where possible
#4994: FILE: drivers/net/atl1e/atl1e_main.c:2151:
+                       }$

ERROR: code indent should use tabs where possible
#4995: FILE: drivers/net/atl1e/atl1e_main.c:2152:
+                       wol_ctrl_data |=3D  WOL_LINK_CHG_EN | WOL_LINK_CHG_=$

ERROR: code indent should use tabs where possible
#4997: FILE: drivers/net/atl1e/atl1e_main.c:2153:
+                       /* only link up can wake up */$

ERROR: code indent should use tabs where possible
#4998: FILE: drivers/net/atl1e/atl1e_main.c:2154:
+                       if (atl1e_write_phy_reg(hw, MII_INT_CTRL, 0x400) !=$

ERROR: code indent should use tabs where possible
#5000: FILE: drivers/net/atl1e/atl1e_main.c:2155:
+                               dev_dbg(&pdev->dev, "%s: read write phy "$

ERROR: code indent should use tabs where possible
#5001: FILE: drivers/net/atl1e/atl1e_main.c:2156:
+                                                 "register failed.\n",$

ERROR: code indent should use tabs where possible
#5002: FILE: drivers/net/atl1e/atl1e_main.c:2157:
+                                                 atl1e_driver_name);$

ERROR: code indent should use tabs where possible
#5003: FILE: drivers/net/atl1e/atl1e_main.c:2158:
+                               goto wol_dis;$

ERROR: code indent should use tabs where possible
#5004: FILE: drivers/net/atl1e/atl1e_main.c:2159:
+                       }$

ERROR: code indent should use tabs where possible
#5005: FILE: drivers/net/atl1e/atl1e_main.c:2160:
+               }$

ERROR: code indent should use tabs where possible
#5006: FILE: drivers/net/atl1e/atl1e_main.c:2161:
+               /* clear phy interrupt */$

ERROR: code indent should use tabs where possible
#5007: FILE: drivers/net/atl1e/atl1e_main.c:2162:
+               atl1e_read_phy_reg(hw, MII_INT_STATUS, &mii_intr_status_dat=$

ERROR: spaces required around that '=' (ctx:VxE)
#5007: FILE: drivers/net/atl1e/atl1e_main.c:2162:
+               atl1e_read_phy_reg(hw, MII_INT_STATUS, &mii_intr_status_dat=
                                                                           ^

ERROR: code indent should use tabs where possible
#5009: FILE: drivers/net/atl1e/atl1e_main.c:2163:
+               /* Config MAC Ctrl register */$

ERROR: code indent should use tabs where possible
#5010: FILE: drivers/net/atl1e/atl1e_main.c:2164:
+               mac_ctrl_data =3D MAC_CTRL_RX_EN;$

ERROR: spaces required around that '=' (ctx:WxV)
#5010: FILE: drivers/net/atl1e/atl1e_main.c:2164:
+               mac_ctrl_data =3D MAC_CTRL_RX_EN;
                              ^

ERROR: code indent should use tabs where possible
#5011: FILE: drivers/net/atl1e/atl1e_main.c:2165:
+               /* set to 10/100M halt duplex */$

ERROR: code indent should use tabs where possible
#5012: FILE: drivers/net/atl1e/atl1e_main.c:2166:
+               mac_ctrl_data |=3D MAC_CTRL_SPEED_10_100 << MAC_CTRL_SPEED_=$

ERROR: spaces required around that '|=' (ctx:WxV)
#5012: FILE: drivers/net/atl1e/atl1e_main.c:2166:
+               mac_ctrl_data |=3D MAC_CTRL_SPEED_10_100 << MAC_CTRL_SPEED_=
                              ^

ERROR: spaces required around that '=' (ctx:VxE)
#5012: FILE: drivers/net/atl1e/atl1e_main.c:2166:
+               mac_ctrl_data |=3D MAC_CTRL_SPEED_10_100 << MAC_CTRL_SPEED_=
                                                                           ^

ERROR: code indent should use tabs where possible
#5014: FILE: drivers/net/atl1e/atl1e_main.c:2167:
+               mac_ctrl_data |=3D (((u32)adapter->hw.preamble_len &$

WARNING: space prohibited between function name and open parenthesis '('
#5014: FILE: drivers/net/atl1e/atl1e_main.c:2167:
+               mac_ctrl_data |=3D (((u32)adapter->hw.preamble_len &

ERROR: spaces required around that '|=' (ctx:WxV)
#5014: FILE: drivers/net/atl1e/atl1e_main.c:2167:
+               mac_ctrl_data |=3D (((u32)adapter->hw.preamble_len &
                              ^

ERROR: code indent should use tabs where possible
#5015: FILE: drivers/net/atl1e/atl1e_main.c:2168:
+                                MAC_CTRL_PRMLEN_MASK) <<$

ERROR: code indent should use tabs where possible
#5016: FILE: drivers/net/atl1e/atl1e_main.c:2169:
+                                MAC_CTRL_PRMLEN_SHIFT);$

ERROR: code indent should use tabs where possible
#5018: FILE: drivers/net/atl1e/atl1e_main.c:2171:
+               if (adapter->vlgrp)$

ERROR: code indent should use tabs where possible
#5019: FILE: drivers/net/atl1e/atl1e_main.c:2172:
+                       mac_ctrl_data |=3D MAC_CTRL_RMV_VLAN;$

ERROR: spaces required around that '|=' (ctx:WxV)
#5019: FILE: drivers/net/atl1e/atl1e_main.c:2172:
+                       mac_ctrl_data |=3D MAC_CTRL_RMV_VLAN;
                                      ^

ERROR: code indent should use tabs where possible
#5021: FILE: drivers/net/atl1e/atl1e_main.c:2174:
+               /* magic packet maybe Broadcast&multicast&Unicast frame */$

ERROR: code indent should use tabs where possible
#5022: FILE: drivers/net/atl1e/atl1e_main.c:2175:
+               if (wufc & AT_WUFC_MAG)$

ERROR: code indent should use tabs where possible
#5023: FILE: drivers/net/atl1e/atl1e_main.c:2176:
+                       mac_ctrl_data |=3D MAC_CTRL_BC_EN;$

ERROR: spaces required around that '|=' (ctx:WxV)
#5023: FILE: drivers/net/atl1e/atl1e_main.c:2176:
+                       mac_ctrl_data |=3D MAC_CTRL_BC_EN;
                                      ^

ERROR: code indent should use tabs where possible
#5025: FILE: drivers/net/atl1e/atl1e_main.c:2178:
+               dev_dbg(&pdev->dev,$

ERROR: code indent should use tabs where possible
#5026: FILE: drivers/net/atl1e/atl1e_main.c:2179:
+                       "%s: suspend MAC=3D0x%x\n",$

ERROR: code indent should use tabs where possible
#5027: FILE: drivers/net/atl1e/atl1e_main.c:2180:
+                       atl1e_driver_name, mac_ctrl_data);$

ERROR: code indent should use tabs where possible
#5029: FILE: drivers/net/atl1e/atl1e_main.c:2182:
+               AT_WRITE_REG(hw, REG_WOL_CTRL, wol_ctrl_data);$

ERROR: code indent should use tabs where possible
#5030: FILE: drivers/net/atl1e/atl1e_main.c:2183:
+               AT_WRITE_REG(hw, REG_MAC_CTRL, mac_ctrl_data);$

ERROR: code indent should use tabs where possible
#5031: FILE: drivers/net/atl1e/atl1e_main.c:2184:
+               /* pcie patch */$

ERROR: code indent should use tabs where possible
#5032: FILE: drivers/net/atl1e/atl1e_main.c:2185:
+               ctrl =3D AT_READ_REG(hw, REG_PCIE_PHYMISC);$

ERROR: spaces required around that '=' (ctx:WxV)
#5032: FILE: drivers/net/atl1e/atl1e_main.c:2185:
+               ctrl =3D AT_READ_REG(hw, REG_PCIE_PHYMISC);
                     ^

ERROR: code indent should use tabs where possible
#5033: FILE: drivers/net/atl1e/atl1e_main.c:2186:
+               ctrl |=3D PCIE_PHYMISC_FORCE_RCV_DET;$

ERROR: spaces required around that '|=' (ctx:WxV)
#5033: FILE: drivers/net/atl1e/atl1e_main.c:2186:
+               ctrl |=3D PCIE_PHYMISC_FORCE_RCV_DET;
                     ^

ERROR: code indent should use tabs where possible
#5034: FILE: drivers/net/atl1e/atl1e_main.c:2187:
+               AT_WRITE_REG(hw, REG_PCIE_PHYMISC, ctrl);$

ERROR: code indent should use tabs where possible
#5035: FILE: drivers/net/atl1e/atl1e_main.c:2188:
+               pci_enable_wake(pdev, pci_choose_state(pdev, state), 1);$

ERROR: code indent should use tabs where possible
#5036: FILE: drivers/net/atl1e/atl1e_main.c:2189:
+               goto suspend_exit;$

ERROR: spaces required around that '=' (ctx:WxV)
#5044: FILE: drivers/net/atl1e/atl1e_main.c:2197:
+       ctrl =3D AT_READ_REG(hw, REG_PCIE_PHYMISC);
             ^

ERROR: spaces required around that '|=' (ctx:WxV)
#5045: FILE: drivers/net/atl1e/atl1e_main.c:2198:
+       ctrl |=3D PCIE_PHYMISC_FORCE_RCV_DET;
             ^

ERROR: spaces required around that '=' (ctx:WxV)
#5049: FILE: drivers/net/atl1e/atl1e_main.c:2202:
+       hw->phy_configured =3D false; /* re-init PHY when resume */
                           ^

ERROR: code indent should use tabs where possible
#5056: FILE: drivers/net/atl1e/atl1e_main.c:2209:
+               atl1e_free_irq(adapter);$

ERROR: spaces required around that '=' (ctx:WxV)
#5067: FILE: drivers/net/atl1e/atl1e_main.c:2220:
+       struct net_device *netdev =3D pci_get_drvdata(pdev);
                                  ^

ERROR: spaces required around that '=' (ctx:WxV)
#5068: FILE: drivers/net/atl1e/atl1e_main.c:2221:
+       struct atl1e_adapter *adapter =3D netdev_priv(netdev);
                                      ^

ERROR: spaces required around that '=' (ctx:WxV)
#5074: FILE: drivers/net/atl1e/atl1e_main.c:2227:
+       err =3D pci_enable_device(pdev);
            ^

ERROR: code indent should use tabs where possible
#5076: FILE: drivers/net/atl1e/atl1e_main.c:2229:
+               dev_err(&pdev->dev, "ATL1e: Cannot enable PCI"$

ERROR: code indent should use tabs where possible
#5077: FILE: drivers/net/atl1e/atl1e_main.c:2230:
+                               " device from suspend\n");$

ERROR: code indent should use tabs where possible
#5078: FILE: drivers/net/atl1e/atl1e_main.c:2231:
+               return err;$

ERROR: code indent should use tabs where possible
#5091: FILE: drivers/net/atl1e/atl1e_main.c:2244:
+               err =3D atl1e_request_irq(adapter);$

ERROR: spaces required around that '=' (ctx:WxV)
#5091: FILE: drivers/net/atl1e/atl1e_main.c:2244:
+               err =3D atl1e_request_irq(adapter);
                    ^

ERROR: code indent should use tabs where possible
#5092: FILE: drivers/net/atl1e/atl1e_main.c:2245:
+               if (err)$

ERROR: code indent should use tabs where possible
#5093: FILE: drivers/net/atl1e/atl1e_main.c:2246:
+                       return err;$

ERROR: code indent should use tabs where possible
#5098: FILE: drivers/net/atl1e/atl1e_main.c:2251:
+               atl1e_up(adapter);$

ERROR: spaces required around that '=' (ctx:VxE)
#5111: FILE: drivers/net/atl1e/atl1e_main.c:2264:
+static int atl1e_init_netdev(struct net_device *netdev, struct pci_dev *pd=
                                                                           ^

ERROR: that open brace { should be on the previous line
#5113: FILE: drivers/net/atl1e/atl1e_main.c:2265:
+static int atl1e_init_netdev(struct net_device *netdev, struct pci_dev *pd=
+{

ERROR: spaces required around that '=' (ctx:WxV)
#5117: FILE: drivers/net/atl1e/atl1e_main.c:2269:
+       netdev->irq  =3D pdev->irq;
                     ^

ERROR: spaces required around that '=' (ctx:WxV)
#5118: FILE: drivers/net/atl1e/atl1e_main.c:2270:
+       netdev->open =3D &atl1e_open;
                     ^

ERROR: need consistent spacing around '&' (ctx:WxV)
#5118: FILE: drivers/net/atl1e/atl1e_main.c:2270:
+       netdev->open =3D &atl1e_open;
                         ^

ERROR: spaces required around that '=' (ctx:WxV)
#5119: FILE: drivers/net/atl1e/atl1e_main.c:2271:
+       netdev->stop =3D &atl1e_close;
                     ^

ERROR: need consistent spacing around '&' (ctx:WxV)
#5119: FILE: drivers/net/atl1e/atl1e_main.c:2271:
+       netdev->stop =3D &atl1e_close;
                         ^

ERROR: spaces required around that '=' (ctx:WxV)
#5120: FILE: drivers/net/atl1e/atl1e_main.c:2272:
+       netdev->hard_start_xmit =3D &atl1e_xmit_frame;
                                ^

ERROR: need consistent spacing around '&' (ctx:WxV)
#5120: FILE: drivers/net/atl1e/atl1e_main.c:2272:
+       netdev->hard_start_xmit =3D &atl1e_xmit_frame;
                                    ^

ERROR: spaces required around that '=' (ctx:WxV)
#5121: FILE: drivers/net/atl1e/atl1e_main.c:2273:
+       netdev->get_stats =3D &atl1e_get_stats;
                          ^

ERROR: need consistent spacing around '&' (ctx:WxV)
#5121: FILE: drivers/net/atl1e/atl1e_main.c:2273:
+       netdev->get_stats =3D &atl1e_get_stats;
                              ^

ERROR: spaces required around that '=' (ctx:WxV)
#5122: FILE: drivers/net/atl1e/atl1e_main.c:2274:
+       netdev->set_multicast_list =3D &atl1e_set_multi;
                                   ^

ERROR: need consistent spacing around '&' (ctx:WxV)
#5122: FILE: drivers/net/atl1e/atl1e_main.c:2274:
+       netdev->set_multicast_list =3D &atl1e_set_multi;
                                       ^

ERROR: spaces required around that '=' (ctx:WxV)
#5123: FILE: drivers/net/atl1e/atl1e_main.c:2275:
+       netdev->set_mac_address =3D &atl1e_set_mac_addr;
                                ^

ERROR: need consistent spacing around '&' (ctx:WxV)
#5123: FILE: drivers/net/atl1e/atl1e_main.c:2275:
+       netdev->set_mac_address =3D &atl1e_set_mac_addr;
                                    ^

ERROR: spaces required around that '=' (ctx:WxV)
#5124: FILE: drivers/net/atl1e/atl1e_main.c:2276:
+       netdev->change_mtu =3D &atl1e_change_mtu;
                           ^

ERROR: need consistent spacing around '&' (ctx:WxV)
#5124: FILE: drivers/net/atl1e/atl1e_main.c:2276:
+       netdev->change_mtu =3D &atl1e_change_mtu;
                               ^

ERROR: spaces required around that '=' (ctx:WxV)
#5125: FILE: drivers/net/atl1e/atl1e_main.c:2277:
+       netdev->do_ioctl =3D &atl1e_ioctl;
                         ^

ERROR: need consistent spacing around '&' (ctx:WxV)
#5125: FILE: drivers/net/atl1e/atl1e_main.c:2277:
+       netdev->do_ioctl =3D &atl1e_ioctl;
                             ^

ERROR: spaces required around that '=' (ctx:WxV)
#5126: FILE: drivers/net/atl1e/atl1e_main.c:2278:
+       netdev->tx_timeout =3D &atl1e_tx_timeout;
                           ^

ERROR: need consistent spacing around '&' (ctx:WxV)
#5126: FILE: drivers/net/atl1e/atl1e_main.c:2278:
+       netdev->tx_timeout =3D &atl1e_tx_timeout;
                               ^

ERROR: spaces required around that '=' (ctx:WxV)
#5127: FILE: drivers/net/atl1e/atl1e_main.c:2279:
+       netdev->watchdog_timeo =3D AT_TX_WATCHDOG;
                               ^

ERROR: spaces required around that '=' (ctx:WxV)
#5128: FILE: drivers/net/atl1e/atl1e_main.c:2280:
+       netdev->vlan_rx_register =3D atl1e_vlan_rx_register;
                                 ^

ERROR: spaces required around that '=' (ctx:WxV)
#5130: FILE: drivers/net/atl1e/atl1e_main.c:2282:
+       netdev->poll_controller =3D atl1e_netpoll;
                                ^

ERROR: spaces required around that '=' (ctx:WxV)
#5134: FILE: drivers/net/atl1e/atl1e_main.c:2286:
+       netdev->features =3D NETIF_F_SG | NETIF_F_HW_CSUM |
                         ^

ERROR: code indent should use tabs where possible
#5135: FILE: drivers/net/atl1e/atl1e_main.c:2287:
+               NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;$

ERROR: spaces required around that '|=' (ctx:WxV)
#5136: FILE: drivers/net/atl1e/atl1e_main.c:2288:
+       netdev->features |=3D NETIF_F_LLTX;
                         ^

ERROR: spaces required around that '|=' (ctx:WxV)
#5137: FILE: drivers/net/atl1e/atl1e_main.c:2289:
+       netdev->features |=3D NETIF_F_TSO;
                         ^

ERROR: spaces required around that '|=' (ctx:WxV)
#5138: FILE: drivers/net/atl1e/atl1e_main.c:2290:
+       netdev->features |=3D NETIF_F_TSO6;
                         ^

ERROR: code indent should use tabs where possible
#5155: FILE: drivers/net/atl1e/atl1e_main.c:2307:
+                                const struct pci_device_id *ent)$

ERROR: spaces required around that '=' (ctx:WxV)
#5158: FILE: drivers/net/atl1e/atl1e_main.c:2310:
+       struct atl1e_adapter *adapter =3D NULL;
                                      ^

ERROR: spaces required around that '=' (ctx:WxV)
#5160: FILE: drivers/net/atl1e/atl1e_main.c:2312:
+       bool pci_using_64 =3D false;
                          ^

ERROR: spaces required around that '=' (ctx:WxV)
#5162: FILE: drivers/net/atl1e/atl1e_main.c:2314:
+       int err =3D 0;
                ^

ERROR: spaces required around that '=' (ctx:WxV)
#5164: FILE: drivers/net/atl1e/atl1e_main.c:2316:
+       err =3D pci_enable_device(pdev);
            ^

ERROR: code indent should use tabs where possible
#5166: FILE: drivers/net/atl1e/atl1e_main.c:2318:
+               dev_err(&pdev->dev, "cannot enable PCI device\n");$

ERROR: code indent should use tabs where possible
#5167: FILE: drivers/net/atl1e/atl1e_main.c:2319:
+               return err;$

ERROR: spaces required around that '=' (ctx:WxV)
#5172: FILE: drivers/net/atl1e/atl1e_main.c:2324:
+       err =3D pci_request_regions(pdev, atl1e_driver_name);
            ^

ERROR: code indent should use tabs where possible
#5174: FILE: drivers/net/atl1e/atl1e_main.c:2326:
+               dev_err(&pdev->dev, "cannot obtain PCI resources\n");$

ERROR: code indent should use tabs where possible
#5175: FILE: drivers/net/atl1e/atl1e_main.c:2327:
+               goto err_pci_reg;$

ERROR: spaces required around that '=' (ctx:WxV)
#5178: FILE: drivers/net/atl1e/atl1e_main.c:2330:
+       netdev =3D alloc_etherdev(sizeof(struct atl1e_adapter));
               ^

ERROR: spaces required around that '=' (ctx:WxV)
#5179: FILE: drivers/net/atl1e/atl1e_main.c:2331:
+       if (netdev =3D=3D NULL) {
                   ^

ERROR: spaces required around that '=' (ctx:VxV)
#5179: FILE: drivers/net/atl1e/atl1e_main.c:2331:
+       if (netdev =3D=3D NULL) {
                      ^

ERROR: do not use assignment in if condition
#5179: FILE: drivers/net/atl1e/atl1e_main.c:2331:
+       if (netdev =3D=3D NULL) {

ERROR: code indent should use tabs where possible
#5180: FILE: drivers/net/atl1e/atl1e_main.c:2332:
+               err =3D -ENOMEM;$

ERROR: spaces required around that '=' (ctx:WxV)
#5180: FILE: drivers/net/atl1e/atl1e_main.c:2332:
+               err =3D -ENOMEM;
                    ^

ERROR: need consistent spacing around '-' (ctx:WxV)
#5180: FILE: drivers/net/atl1e/atl1e_main.c:2332:
+               err =3D -ENOMEM;
                        ^

ERROR: code indent should use tabs where possible
#5181: FILE: drivers/net/atl1e/atl1e_main.c:2333:
+               dev_err(&pdev->dev, "etherdev alloc failed\n");$

ERROR: code indent should use tabs where possible
#5182: FILE: drivers/net/atl1e/atl1e_main.c:2334:
+               goto err_alloc_etherdev;$

ERROR: spaces required around that '=' (ctx:WxV)
#5185: FILE: drivers/net/atl1e/atl1e_main.c:2337:
+       err =3D atl1e_init_netdev(netdev, pdev);
            ^

ERROR: code indent should use tabs where possible
#5187: FILE: drivers/net/atl1e/atl1e_main.c:2339:
+               dev_err(&pdev->dev, "init netdevice failed\n");$

ERROR: code indent should use tabs where possible
#5188: FILE: drivers/net/atl1e/atl1e_main.c:2340:
+               goto err_init_netdev;$

ERROR: spaces required around that '!=' (ctx:WxV)
#5191: FILE: drivers/net/atl1e/atl1e_main.c:2343:
+       if ((pci_set_dma_mask(pdev, DMA_32BIT_MASK) !=3D 0) ||
                                                    ^

ERROR: code indent should use tabs where possible
#5192: FILE: drivers/net/atl1e/atl1e_main.c:2344:
+           (pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK) !=3D 0)) {$

ERROR: spaces required around that '!=' (ctx:WxV)
#5192: FILE: drivers/net/atl1e/atl1e_main.c:2344:
+           (pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK) !=3D 0)) {
                                                               ^

ERROR: code indent should use tabs where possible
#5193: FILE: drivers/net/atl1e/atl1e_main.c:2345:
+               dev_err(&pdev->dev, "No usable DMA configuration,aborting\n=$

ERROR: code indent should use tabs where possible
#5195: FILE: drivers/net/atl1e/atl1e_main.c:2346:
+               goto err_dma;$

ERROR: code indent should use tabs where possible
#5206: FILE: drivers/net/atl1e/atl1e_main.c:2357:
+               err =3D -EIO;$

ERROR: code indent should use tabs where possible
#5207: FILE: drivers/net/atl1e/atl1e_main.c:2358:
+               dev_err(&pdev->dev, "cannot map device registers\n");$

ERROR: code indent should use tabs where possible
#5208: FILE: drivers/net/atl1e/atl1e_main.c:2359:
+               goto err_ioremap;$

ERROR: spaces required around that '=' (ctx:WxV)
#5213: FILE: drivers/net/atl1e/atl1e_main.c:2364:
+       adapter->mii.dev =3D netdev;
                         ^

ERROR: spaces required around that '=' (ctx:WxV)
#5214: FILE: drivers/net/atl1e/atl1e_main.c:2365:
+       adapter->mii.mdio_read  =3D atl1e_mdio_read;
                                ^

ERROR: spaces required around that '=' (ctx:WxV)
#5215: FILE: drivers/net/atl1e/atl1e_main.c:2366:
+       adapter->mii.mdio_write =3D atl1e_mdio_write;
                                ^

ERROR: spaces required around that '=' (ctx:WxV)
#5216: FILE: drivers/net/atl1e/atl1e_main.c:2367:
+       adapter->mii.phy_id_mask =3D 0x1f;
                                 ^

ERROR: spaces required around that '=' (ctx:WxV)
#5217: FILE: drivers/net/atl1e/atl1e_main.c:2368:
+       adapter->mii.reg_num_mask =3D MDIO_REG_ADDR_MASK;
                                  ^

ERROR: spaces required around that '=' (ctx:WxV)
#5222: FILE: drivers/net/atl1e/atl1e_main.c:2373:
+       adapter->phy_config_timer.function =3D &atl1e_phy_config;
                                           ^

ERROR: need consistent spacing around '&' (ctx:WxV)
#5222: FILE: drivers/net/atl1e/atl1e_main.c:2373:
+       adapter->phy_config_timer.function =3D &atl1e_phy_config;
                                               ^

WARNING: space prohibited between function name and open parenthesis '('
#5223: FILE: drivers/net/atl1e/atl1e_main.c:2374:
+       adapter->phy_config_timer.data =3D (unsigned long) adapter;

ERROR: spaces required around that '=' (ctx:WxV)
#5223: FILE: drivers/net/atl1e/atl1e_main.c:2374:
+       adapter->phy_config_timer.data =3D (unsigned long) adapter;
                                       ^

ERROR: code indent should use tabs where possible
#5228: FILE: drivers/net/atl1e/atl1e_main.c:2379:
+        * Mark all PCI regions associated with PCI device$

ERROR: code indent should use tabs where possible
#5229: FILE: drivers/net/atl1e/atl1e_main.c:2380:
+        * pdev as being reserved by owner atl1e_driver_name$

ERROR: code indent should use tabs where possible
#5230: FILE: drivers/net/atl1e/atl1e_main.c:2381:
+        * Enables bus-mastering on the device and calls$

ERROR: code indent should use tabs where possible
#5231: FILE: drivers/net/atl1e/atl1e_main.c:2382:
+        * pcibios_set_master to do the needed arch specific settings$

ERROR: code indent should use tabs where possible
#5232: FILE: drivers/net/atl1e/atl1e_main.c:2383:
+        */$

ERROR: spaces required around that '=' (ctx:WxV)
#5235: FILE: drivers/net/atl1e/atl1e_main.c:2386:
+       err =3D atl1e_sw_init(adapter);
            ^

ERROR: code indent should use tabs where possible
#5237: FILE: drivers/net/atl1e/atl1e_main.c:2388:
+               dev_err(&pdev->dev, "net device private data init failed\n"=$

ERROR: spaces required around that '=' (ctx:VxE)
#5237: FILE: drivers/net/atl1e/atl1e_main.c:2388:
+               dev_err(&pdev->dev, "net device private data init failed\n"=
                                                                           ^

ERROR: code indent should use tabs where possible
#5239: FILE: drivers/net/atl1e/atl1e_main.c:2389:
+               goto err_sw_init;$

ERROR: code indent should use tabs where possible
#5244: FILE: drivers/net/atl1e/atl1e_main.c:2394:
+               netdev->features |=3D NETIF_F_HIGHDMA;$

ERROR: spaces required around that '|=' (ctx:WxV)
#5244: FILE: drivers/net/atl1e/atl1e_main.c:2394:
+               netdev->features |=3D NETIF_F_HIGHDMA;
                                 ^

ERROR: code indent should use tabs where possible
#5251: FILE: drivers/net/atl1e/atl1e_main.c:2401:
+        * put the device in a known good starting state */$

ERROR: spaces required around that '=' (ctx:WxV)
#5252: FILE: drivers/net/atl1e/atl1e_main.c:2402:
+       err =3D atl1e_reset_hw(&adapter->hw);
            ^

ERROR: code indent should use tabs where possible
#5254: FILE: drivers/net/atl1e/atl1e_main.c:2404:
+               err =3D -EIO;$

ERROR: spaces required around that '=' (ctx:WxV)
#5254: FILE: drivers/net/atl1e/atl1e_main.c:2404:
+               err =3D -EIO;
                    ^

ERROR: need consistent spacing around '-' (ctx:WxV)
#5254: FILE: drivers/net/atl1e/atl1e_main.c:2404:
+               err =3D -EIO;
                        ^

ERROR: code indent should use tabs where possible
#5255: FILE: drivers/net/atl1e/atl1e_main.c:2405:
+               goto err_reset;$

ERROR: spaces required around that '!=' (ctx:WxV)
#5258: FILE: drivers/net/atl1e/atl1e_main.c:2408:
+       if (atl1e_read_mac_addr(&adapter->hw) !=3D 0) {
                                              ^

ERROR: code indent should use tabs where possible
#5259: FILE: drivers/net/atl1e/atl1e_main.c:2409:
+               err =3D -EIO;$

ERROR: spaces required around that '=' (ctx:WxV)
#5259: FILE: drivers/net/atl1e/atl1e_main.c:2409:
+               err =3D -EIO;
                    ^

ERROR: need consistent spacing around '-' (ctx:WxV)
#5259: FILE: drivers/net/atl1e/atl1e_main.c:2409:
+               err =3D -EIO;
                        ^

ERROR: code indent should use tabs where possible
#5260: FILE: drivers/net/atl1e/atl1e_main.c:2410:
+               dev_err(&pdev->dev, "get mac address failed\n");$

ERROR: code indent should use tabs where possible
#5261: FILE: drivers/net/atl1e/atl1e_main.c:2411:
+               goto err_eeprom;$

ERROR: spaces required around that '=' (ctx:VxE)
#5266: FILE: drivers/net/atl1e/atl1e_main.c:2416:
+       dev_dbg(&pdev->dev, "mac address : %02x-%02x-%02x-%02x-%02x-%02x\n"=
                                                                           ^

ERROR: code indent should use tabs where possible
#5268: FILE: drivers/net/atl1e/atl1e_main.c:2417:
+                       adapter->hw.mac_addr[0], adapter->hw.mac_addr[1],$

ERROR: code indent should use tabs where possible
#5269: FILE: drivers/net/atl1e/atl1e_main.c:2418:
+                       adapter->hw.mac_addr[2], adapter->hw.mac_addr[3],$

ERROR: code indent should use tabs where possible
#5270: FILE: drivers/net/atl1e/atl1e_main.c:2419:
+                       adapter->hw.mac_addr[4], adapter->hw.mac_addr[5]);$

ERROR: spaces required around that '=' (ctx:WxV)
#5274: FILE: drivers/net/atl1e/atl1e_main.c:2423:
+       err =3D register_netdev(netdev);
            ^

ERROR: code indent should use tabs where possible
#5276: FILE: drivers/net/atl1e/atl1e_main.c:2425:
+               dev_err(&pdev->dev, "register netdevice failed\n");$

ERROR: code indent should use tabs where possible
#5277: FILE: drivers/net/atl1e/atl1e_main.c:2426:
+               goto err_register;$

ERROR: spaces required around that '=' (ctx:WxV)
#5315: FILE: drivers/net/atl1e/atl1e_main.c:2464:
+       struct net_device *netdev =3D pci_get_drvdata(pdev);
                                  ^

ERROR: spaces required around that '=' (ctx:WxV)
#5316: FILE: drivers/net/atl1e/atl1e_main.c:2465:
+       struct atl1e_adapter *adapter =3D netdev_priv(netdev);
                                      ^

ERROR: code indent should use tabs where possible
#5319: FILE: drivers/net/atl1e/atl1e_main.c:2468:
+        * flush_scheduled work may reschedule our watchdog task, so$

ERROR: code indent should use tabs where possible
#5320: FILE: drivers/net/atl1e/atl1e_main.c:2469:
+        * explicitly disable watchdog tasks from being rescheduled$

ERROR: code indent should use tabs where possible
#5321: FILE: drivers/net/atl1e/atl1e_main.c:2470:
+        */$

ERROR: spaces required around that '=' (ctx:WxV)
#5347: FILE: drivers/net/atl1e/atl1e_main.c:2496:
+       struct net_device *netdev =3D pci_get_drvdata(pdev);
                                  ^

ERROR: spaces required around that '=' (ctx:WxV)
#5348: FILE: drivers/net/atl1e/atl1e_main.c:2497:
+       struct atl1e_adapter *adapter =3D netdev->priv;
                                      ^

ERROR: code indent should use tabs where possible
#5353: FILE: drivers/net/atl1e/atl1e_main.c:2502:
+               atl1e_down(adapter);$

ERROR: spaces required around that '=' (ctx:WxV)
#5370: FILE: drivers/net/atl1e/atl1e_main.c:2519:
+       struct net_device *netdev =3D pci_get_drvdata(pdev);
                                  ^

ERROR: spaces required around that '=' (ctx:WxV)
#5371: FILE: drivers/net/atl1e/atl1e_main.c:2520:
+       struct atl1e_adapter *adapter =3D netdev->priv;
                                      ^

ERROR: code indent should use tabs where possible
#5374: FILE: drivers/net/atl1e/atl1e_main.c:2523:
+               dev_err(&pdev->dev,$

ERROR: code indent should use tabs where possible
#5375: FILE: drivers/net/atl1e/atl1e_main.c:2524:
+                      "ATL1e: Cannot re-enable PCI device after reset.\n")=$

ERROR: spaces required around that '=' (ctx:VxE)
#5375: FILE: drivers/net/atl1e/atl1e_main.c:2524:
+                      "ATL1e: Cannot re-enable PCI device after reset.\n")=
                                                                           ^

ERROR: code indent should use tabs where possible
#5377: FILE: drivers/net/atl1e/atl1e_main.c:2525:
+               return PCI_ERS_RESULT_DISCONNECT;$

ERROR: spaces required around that '=' (ctx:WxV)
#5399: FILE: drivers/net/atl1e/atl1e_main.c:2547:
+       struct net_device *netdev =3D pci_get_drvdata(pdev);
                                  ^

ERROR: spaces required around that '=' (ctx:WxV)
#5400: FILE: drivers/net/atl1e/atl1e_main.c:2548:
+       struct atl1e_adapter *adapter =3D netdev->priv;
                                      ^

ERROR: code indent should use tabs where possible
#5403: FILE: drivers/net/atl1e/atl1e_main.c:2551:
+               if (atl1e_up(adapter)) {$

ERROR: code indent should use tabs where possible
#5404: FILE: drivers/net/atl1e/atl1e_main.c:2552:
+                       dev_err(&pdev->dev,$

ERROR: code indent should use tabs where possible
#5405: FILE: drivers/net/atl1e/atl1e_main.c:2553:
+                         "ATL1e: can't bring device back up after reset\n"=$

ERROR: spaces required around that '=' (ctx:VxE)
#5405: FILE: drivers/net/atl1e/atl1e_main.c:2553:
+                         "ATL1e: can't bring device back up after reset\n"=
                                                                           ^

ERROR: code indent should use tabs where possible
#5407: FILE: drivers/net/atl1e/atl1e_main.c:2554:
+                       return;$

ERROR: code indent should use tabs where possible
#5408: FILE: drivers/net/atl1e/atl1e_main.c:2555:
+               }$

ERROR: spaces required around that '=' (ctx:WxV)
#5414: FILE: drivers/net/atl1e/atl1e_main.c:2561:
+static struct pci_error_handlers atl1e_err_handler =3D {
                                                    ^

ERROR: spaces required around that '=' (ctx:WxV)
#5415: FILE: drivers/net/atl1e/atl1e_main.c:2562:
+       .error_detected =3D atl1e_io_error_detected,
                        ^

ERROR: spaces required around that '=' (ctx:WxV)
#5416: FILE: drivers/net/atl1e/atl1e_main.c:2563:
+       .slot_reset =3D atl1e_io_slot_reset,
                    ^

ERROR: spaces required around that '=' (ctx:WxV)
#5417: FILE: drivers/net/atl1e/atl1e_main.c:2564:
+       .resume =3D atl1e_io_resume,
                ^

ERROR: spaces required around that '=' (ctx:WxV)
#5420: FILE: drivers/net/atl1e/atl1e_main.c:2567:
+static struct pci_driver atl1e_driver =3D {
                                       ^

ERROR: spaces required around that '=' (ctx:WxV)
#5421: FILE: drivers/net/atl1e/atl1e_main.c:2568:
+       .name     =3D atl1e_driver_name,
                  ^

ERROR: spaces required around that '=' (ctx:WxV)
#5422: FILE: drivers/net/atl1e/atl1e_main.c:2569:
+       .id_table =3D atl1e_pci_tbl,
                  ^

ERROR: spaces required around that '=' (ctx:WxV)
#5423: FILE: drivers/net/atl1e/atl1e_main.c:2570:
+       .probe    =3D atl1e_probe,
                  ^

ERROR: spaces required around that '=' (ctx:WxV)
#5424: FILE: drivers/net/atl1e/atl1e_main.c:2571:
+       .remove   =3D __devexit_p(atl1e_remove),
                  ^

ERROR: spaces required around that '=' (ctx:WxV)
#5427: FILE: drivers/net/atl1e/atl1e_main.c:2574:
+       .suspend  =3D atl1e_suspend,
                  ^

ERROR: spaces required around that '=' (ctx:WxV)
#5428: FILE: drivers/net/atl1e/atl1e_main.c:2575:
+       .resume   =3D atl1e_resume,
                  ^

ERROR: spaces required around that '=' (ctx:WxV)
#5430: FILE: drivers/net/atl1e/atl1e_main.c:2577:
+       .shutdown =3D atl1e_shutdown,
                  ^

ERROR: spaces required around that '=' (ctx:WxV)
#5431: FILE: drivers/net/atl1e/atl1e_main.c:2578:
+       .err_handler =3D &atl1e_err_handler
                     ^

ERROR: need consistent spacing around '&' (ctx:WxV)
#5431: FILE: drivers/net/atl1e/atl1e_main.c:2578:
+       .err_handler =3D &atl1e_err_handler
                         ^

ERROR: spaces required around that '=' (ctx:WxV)
#5509: FILE: drivers/net/atl1e/atl1e_param.c:41:
+#define ATL1E_PARAM_INIT { [0 ... ATL1E_MAX_NIC] =3D OPTION_UNSET }
                                                  ^

ERROR: spaces required around that '=' (ctx:WxV)
#5512: FILE: drivers/net/atl1e/atl1e_param.c:44:
+       static int __devinitdata x[ATL1E_MAX_NIC + 1] =3D ATL1E_PARAM_INIT;=
                                                      ^

ERROR: space required after that ';' (ctx:VxO)
#5512: FILE: drivers/net/atl1e/atl1e_param.c:44:
+       static int __devinitdata x[ATL1E_MAX_NIC + 1] =3D ATL1E_PARAM_INIT;=
                                                                          ^

ERROR: spaces required around that '=' (ctx:OxE)
#5512: FILE: drivers/net/atl1e/atl1e_param.c:44:
+       static int __devinitdata x[ATL1E_MAX_NIC + 1] =3D ATL1E_PARAM_INIT;=
                                                                           ^

ERROR: code indent should use tabs where possible
#5578: FILE: drivers/net/atl1e/atl1e_param.c:110:
+               struct { /* range_option info */$

ERROR: code indent should use tabs where possible
#5579: FILE: drivers/net/atl1e/atl1e_param.c:111:
+                       int min;$

ERROR: code indent should use tabs where possible
#5580: FILE: drivers/net/atl1e/atl1e_param.c:112:
+                       int max;$

ERROR: code indent should use tabs where possible
#5581: FILE: drivers/net/atl1e/atl1e_param.c:113:
+               } r;$

ERROR: code indent should use tabs where possible
#5582: FILE: drivers/net/atl1e/atl1e_param.c:114:
+               struct { /* list_option info */$

ERROR: code indent should use tabs where possible
#5583: FILE: drivers/net/atl1e/atl1e_param.c:115:
+                       int nr;$

ERROR: code indent should use tabs where possible
#5584: FILE: drivers/net/atl1e/atl1e_param.c:116:
+                       struct atl1e_opt_list { int i; char *str; } *p;$

ERROR: code indent should use tabs where possible
#5585: FILE: drivers/net/atl1e/atl1e_param.c:117:
+               } l;$

ERROR: spaces required around that '=' (ctx:VxE)
#5589: FILE: drivers/net/atl1e/atl1e_param.c:121:
+static int __devinit atl1e_validate_option(int *value, struct atl1e_option=
                                                                           ^

ERROR: spaces required around that '=' (ctx:WxV)
#5592: FILE: drivers/net/atl1e/atl1e_param.c:124:
+       if (*value =3D=3D OPTION_UNSET) {
                   ^

ERROR: spaces required around that '=' (ctx:VxV)
#5592: FILE: drivers/net/atl1e/atl1e_param.c:124:
+       if (*value =3D=3D OPTION_UNSET) {
                      ^

ERROR: do not use assignment in if condition
#5592: FILE: drivers/net/atl1e/atl1e_param.c:124:
+       if (*value =3D=3D OPTION_UNSET) {

ERROR: code indent should use tabs where possible
#5593: FILE: drivers/net/atl1e/atl1e_param.c:125:
+               *value =3D opt->def;$

ERROR: spaces required around that '=' (ctx:WxV)
#5593: FILE: drivers/net/atl1e/atl1e_param.c:125:
+               *value =3D opt->def;
                       ^

ERROR: code indent should use tabs where possible
#5594: FILE: drivers/net/atl1e/atl1e_param.c:126:
+               return 0;$

ERROR: code indent should use tabs where possible
#5599: FILE: drivers/net/atl1e/atl1e_param.c:131:
+               switch (*value) {$

ERROR: code indent should use tabs where possible
#5600: FILE: drivers/net/atl1e/atl1e_param.c:132:
+               case OPTION_ENABLED:$

ERROR: code indent should use tabs where possible
#5601: FILE: drivers/net/atl1e/atl1e_param.c:133:
+                       dev_info(&pdev->dev, "%s Enabled\n", opt->name);$

ERROR: code indent should use tabs where possible
#5602: FILE: drivers/net/atl1e/atl1e_param.c:134:
+                       return 0;$

ERROR: code indent should use tabs where possible
#5603: FILE: drivers/net/atl1e/atl1e_param.c:135:
+               case OPTION_DISABLED:$

ERROR: code indent should use tabs where possible
#5604: FILE: drivers/net/atl1e/atl1e_param.c:136:
+                       dev_info(&pdev->dev, "%s Disabled\n", opt->name);$

ERROR: code indent should use tabs where possible
#5605: FILE: drivers/net/atl1e/atl1e_param.c:137:
+                       return 0;$

ERROR: code indent should use tabs where possible
#5606: FILE: drivers/net/atl1e/atl1e_param.c:138:
+               }$

ERROR: code indent should use tabs where possible
#5607: FILE: drivers/net/atl1e/atl1e_param.c:139:
+               break;$

ERROR: code indent should use tabs where possible
#5609: FILE: drivers/net/atl1e/atl1e_param.c:141:
+               if (*value >=3D opt->arg.r.min && *value <=3D opt->arg.r.ma=$

ERROR: spaces required around that '>=' (ctx:WxV)
#5609: FILE: drivers/net/atl1e/atl1e_param.c:141:
+               if (*value >=3D opt->arg.r.min && *value <=3D opt->arg.r.ma=
                           ^

ERROR: spaces required around that '<=' (ctx:WxV)
#5609: FILE: drivers/net/atl1e/atl1e_param.c:141:
+               if (*value >=3D opt->arg.r.min && *value <=3D opt->arg.r.ma=
                                                         ^

ERROR: spaces required around that '=' (ctx:VxE)
#5609: FILE: drivers/net/atl1e/atl1e_param.c:141:
+               if (*value >=3D opt->arg.r.min && *value <=3D opt->arg.r.ma=
                                                                           ^

ERROR: do not use assignment in if condition
#5609: FILE: drivers/net/atl1e/atl1e_param.c:141:
+               if (*value >=3D opt->arg.r.min && *value <=3D opt->arg.r.ma=

ERROR: code indent should use tabs where possible
#5611: FILE: drivers/net/atl1e/atl1e_param.c:142:
+                       dev_info(&pdev->dev, "%s set to %i\n", opt->name, *=$

ERROR: code indent should use tabs where possible
#5613: FILE: drivers/net/atl1e/atl1e_param.c:143:
+                       return 0;$

ERROR: code indent should use tabs where possible
#5614: FILE: drivers/net/atl1e/atl1e_param.c:144:
+               }$

ERROR: code indent should use tabs where possible
#5615: FILE: drivers/net/atl1e/atl1e_param.c:145:
+               break;$

ERROR: code indent should use tabs where possible
#5617: FILE: drivers/net/atl1e/atl1e_param.c:147:
+                       int i;$

ERROR: code indent should use tabs where possible
#5618: FILE: drivers/net/atl1e/atl1e_param.c:148:
+                       struct atl1e_opt_list *ent;$

ERROR: code indent should use tabs where possible
#5620: FILE: drivers/net/atl1e/atl1e_param.c:150:
+                       for (i =3D 0; i < opt->arg.l.nr; i++) {$

ERROR: spaces required around that '=' (ctx:WxV)
#5620: FILE: drivers/net/atl1e/atl1e_param.c:150:
+                       for (i =3D 0; i < opt->arg.l.nr; i++) {
                               ^

ERROR: code indent should use tabs where possible
#5621: FILE: drivers/net/atl1e/atl1e_param.c:151:
+                               ent =3D &opt->arg.l.p[i];$

ERROR: spaces required around that '=' (ctx:WxV)
#5621: FILE: drivers/net/atl1e/atl1e_param.c:151:
+                               ent =3D &opt->arg.l.p[i];
                                    ^

ERROR: need consistent spacing around '&' (ctx:WxV)
#5621: FILE: drivers/net/atl1e/atl1e_param.c:151:
+                               ent =3D &opt->arg.l.p[i];
                                        ^

ERROR: code indent should use tabs where possible
#5622: FILE: drivers/net/atl1e/atl1e_param.c:152:
+                               if (*value =3D=3D ent->i) {$

ERROR: spaces required around that '=' (ctx:WxV)
#5622: FILE: drivers/net/atl1e/atl1e_param.c:152:
+                               if (*value =3D=3D ent->i) {
                                           ^

ERROR: spaces required around that '=' (ctx:VxV)
#5622: FILE: drivers/net/atl1e/atl1e_param.c:152:
+                               if (*value =3D=3D ent->i) {
                                              ^

ERROR: do not use assignment in if condition
#5622: FILE: drivers/net/atl1e/atl1e_param.c:152:
+                               if (*value =3D=3D ent->i) {

ERROR: code indent should use tabs where possible
#5623: FILE: drivers/net/atl1e/atl1e_param.c:153:
+                                       if (ent->str[0] !=3D '\0')$

ERROR: spaces required around that '!=' (ctx:WxV)
#5623: FILE: drivers/net/atl1e/atl1e_param.c:153:
+                                       if (ent->str[0] !=3D '\0')
                                                        ^

ERROR: code indent should use tabs where possible
#5624: FILE: drivers/net/atl1e/atl1e_param.c:154:
+                                               dev_info(&pdev->dev, "%s\n"=$

ERROR: spaces required around that '=' (ctx:VxE)
#5624: FILE: drivers/net/atl1e/atl1e_param.c:154:
+                                               dev_info(&pdev->dev, "%s\n"=
                                                                           ^

ERROR: code indent should use tabs where possible
#5626: FILE: drivers/net/atl1e/atl1e_param.c:155:
+                                                       ent->str);$

ERROR: code indent should use tabs where possible
#5627: FILE: drivers/net/atl1e/atl1e_param.c:156:
+                                       return 0;$

ERROR: code indent should use tabs where possible
#5628: FILE: drivers/net/atl1e/atl1e_param.c:157:
+                               }$

ERROR: code indent should use tabs where possible
#5629: FILE: drivers/net/atl1e/atl1e_param.c:158:
+                       }$

ERROR: code indent should use tabs where possible
#5630: FILE: drivers/net/atl1e/atl1e_param.c:159:
+                       break;$

ERROR: code indent should use tabs where possible
#5631: FILE: drivers/net/atl1e/atl1e_param.c:160:
+               }$

ERROR: code indent should use tabs where possible
#5633: FILE: drivers/net/atl1e/atl1e_param.c:162:
+               BUG();$

ERROR: code indent should use tabs where possible
#5637: FILE: drivers/net/atl1e/atl1e_param.c:166:
+                       opt->name, *value, opt->err);$

ERROR: spaces required around that '=' (ctx:WxV)
#5638: FILE: drivers/net/atl1e/atl1e_param.c:167:
+       *value =3D opt->def;
               ^

ERROR: spaces required around that '=' (ctx:WxV)
#5653: FILE: drivers/net/atl1e/atl1e_param.c:182:
+       struct pci_dev *pdev =3D adapter->pdev;
                             ^

ERROR: spaces required around that '=' (ctx:WxV)
#5654: FILE: drivers/net/atl1e/atl1e_param.c:183:
+       int bd =3D adapter->bd_number;
               ^

ERROR: spaces required around that '>=' (ctx:WxV)
#5655: FILE: drivers/net/atl1e/atl1e_param.c:184:
+       if (bd >=3D ATL1E_MAX_NIC) {
               ^

ERROR: code indent should use tabs where possible
#5656: FILE: drivers/net/atl1e/atl1e_param.c:185:
+               dev_notice(&pdev->dev, "no configuration for board #%i\n", =$

ERROR: code indent should use tabs where possible
#5658: FILE: drivers/net/atl1e/atl1e_param.c:186:
+               dev_notice(&pdev->dev, "Using defaults for all values\n");$

ERROR: code indent should use tabs where possible
#5662: FILE: drivers/net/atl1e/atl1e_param.c:190:
+               struct atl1e_option opt =3D {$

ERROR: spaces required around that '=' (ctx:WxV)
#5662: FILE: drivers/net/atl1e/atl1e_param.c:190:
+               struct atl1e_option opt =3D {
                                        ^

ERROR: code indent should use tabs where possible
#5663: FILE: drivers/net/atl1e/atl1e_param.c:191:
+                       .type =3D range_option,$

ERROR: spaces required around that '=' (ctx:WxV)
#5663: FILE: drivers/net/atl1e/atl1e_param.c:191:
+                       .type =3D range_option,
                              ^

ERROR: code indent should use tabs where possible
#5664: FILE: drivers/net/atl1e/atl1e_param.c:192:
+                       .name =3D "Transmit Ddescription Count",$

ERROR: spaces required around that '=' (ctx:WxV)
#5664: FILE: drivers/net/atl1e/atl1e_param.c:192:
+                       .name =3D "Transmit Ddescription Count",
                              ^

ERROR: code indent should use tabs where possible
#5665: FILE: drivers/net/atl1e/atl1e_param.c:193:
+                       .err  =3D "using default of "$

ERROR: spaces required around that '=' (ctx:WxV)
#5665: FILE: drivers/net/atl1e/atl1e_param.c:193:
+                       .err  =3D "using default of "
                              ^

ERROR: code indent should use tabs where possible
#5666: FILE: drivers/net/atl1e/atl1e_param.c:194:
+                               __MODULE_STRING(ATL1E_DEFAULT_TX_DESC_CNT),$

ERROR: code indent should use tabs where possible
#5667: FILE: drivers/net/atl1e/atl1e_param.c:195:
+                       .def  =3D ATL1E_DEFAULT_TX_DESC_CNT,$

ERROR: spaces required around that '=' (ctx:WxV)
#5667: FILE: drivers/net/atl1e/atl1e_param.c:195:
+                       .def  =3D ATL1E_DEFAULT_TX_DESC_CNT,
                              ^

ERROR: code indent should use tabs where possible
#5668: FILE: drivers/net/atl1e/atl1e_param.c:196:
+                       .arg  =3D { .r =3D { .min =3D ATL1E_MIN_TX_DESC_CNT=$

ERROR: spaces required around that '=' (ctx:WxV)
#5668: FILE: drivers/net/atl1e/atl1e_param.c:196:
+                       .arg  =3D { .r =3D { .min =3D ATL1E_MIN_TX_DESC_CNT=
                              ^

ERROR: spaces required around that '=' (ctx:WxV)
#5668: FILE: drivers/net/atl1e/atl1e_param.c:196:
+                       .arg  =3D { .r =3D { .min =3D ATL1E_MIN_TX_DESC_CNT=
                                       ^

ERROR: spaces required around that '=' (ctx:WxV)
#5668: FILE: drivers/net/atl1e/atl1e_param.c:196:
+                       .arg  =3D { .r =3D { .min =3D ATL1E_MIN_TX_DESC_CNT=
                                                  ^

ERROR: spaces required around that '=' (ctx:VxE)
#5668: FILE: drivers/net/atl1e/atl1e_param.c:196:
+                       .arg  =3D { .r =3D { .min =3D ATL1E_MIN_TX_DESC_CNT=
                                                                           ^

ERROR: code indent should use tabs where possible
#5670: FILE: drivers/net/atl1e/atl1e_param.c:197:
+                                        .max =3D ATL1E_MAX_TX_DESC_CNT} }$

ERROR: spaces required around that '=' (ctx:WxV)
#5670: FILE: drivers/net/atl1e/atl1e_param.c:197:
+                                        .max =3D ATL1E_MAX_TX_DESC_CNT} }
                                              ^

ERROR: code indent should use tabs where possible
#5671: FILE: drivers/net/atl1e/atl1e_param.c:198:
+               };$

ERROR: code indent should use tabs where possible
#5672: FILE: drivers/net/atl1e/atl1e_param.c:199:
+               int val;$

ERROR: code indent should use tabs where possible
#5673: FILE: drivers/net/atl1e/atl1e_param.c:200:
+               if (num_tx_desc_cnt > bd) {$

ERROR: code indent should use tabs where possible
#5674: FILE: drivers/net/atl1e/atl1e_param.c:201:
+                       val =3D tx_desc_cnt[bd];$

ERROR: spaces required around that '=' (ctx:WxV)
#5674: FILE: drivers/net/atl1e/atl1e_param.c:201:
+                       val =3D tx_desc_cnt[bd];
                            ^

ERROR: code indent should use tabs where possible
#5675: FILE: drivers/net/atl1e/atl1e_param.c:202:
+                       atl1e_validate_option(&val, &opt, pdev);$

ERROR: code indent should use tabs where possible
#5676: FILE: drivers/net/atl1e/atl1e_param.c:203:
+                       adapter->tx_ring.count =3D (u16) val & 0xFFFC;$

WARNING: space prohibited between function name and open parenthesis '('
#5676: FILE: drivers/net/atl1e/atl1e_param.c:203:
+                       adapter->tx_ring.count =3D (u16) val & 0xFFFC;

ERROR: spaces required around that '=' (ctx:WxV)
#5676: FILE: drivers/net/atl1e/atl1e_param.c:203:
+                       adapter->tx_ring.count =3D (u16) val & 0xFFFC;
                                               ^

ERROR: code indent should use tabs where possible
#5677: FILE: drivers/net/atl1e/atl1e_param.c:204:
+               } else$

ERROR: code indent should use tabs where possible
#5678: FILE: drivers/net/atl1e/atl1e_param.c:205:
+                       adapter->tx_ring.count =3D (u16)opt.def;$

WARNING: space prohibited between function name and open parenthesis '('
#5678: FILE: drivers/net/atl1e/atl1e_param.c:205:
+                       adapter->tx_ring.count =3D (u16)opt.def;

ERROR: spaces required around that '=' (ctx:WxV)
#5678: FILE: drivers/net/atl1e/atl1e_param.c:205:
+                       adapter->tx_ring.count =3D (u16)opt.def;
                                               ^

ERROR: code indent should use tabs where possible
#5682: FILE: drivers/net/atl1e/atl1e_param.c:209:
+               struct atl1e_option opt =3D {$

ERROR: spaces required around that '=' (ctx:WxV)
#5682: FILE: drivers/net/atl1e/atl1e_param.c:209:
+               struct atl1e_option opt =3D {
                                        ^

ERROR: code indent should use tabs where possible
#5683: FILE: drivers/net/atl1e/atl1e_param.c:210:
+                       .type =3D range_option,$

ERROR: spaces required around that '=' (ctx:WxV)
#5683: FILE: drivers/net/atl1e/atl1e_param.c:210:
+                       .type =3D range_option,
                              ^

ERROR: code indent should use tabs where possible
#5684: FILE: drivers/net/atl1e/atl1e_param.c:211:
+                       .name =3D "Memory size of rx buffer(KB)",$

ERROR: spaces required around that '=' (ctx:WxV)
#5684: FILE: drivers/net/atl1e/atl1e_param.c:211:
+                       .name =3D "Memory size of rx buffer(KB)",
                              ^

ERROR: code indent should use tabs where possible
#5685: FILE: drivers/net/atl1e/atl1e_param.c:212:
+                       .err  =3D "using default of "$

ERROR: spaces required around that '=' (ctx:WxV)
#5685: FILE: drivers/net/atl1e/atl1e_param.c:212:
+                       .err  =3D "using default of "
                              ^

ERROR: code indent should use tabs where possible
#5686: FILE: drivers/net/atl1e/atl1e_param.c:213:
+                               __MODULE_STRING(ATL1E_DEFAULT_RX_MEM_SIZE),$

ERROR: code indent should use tabs where possible
#5687: FILE: drivers/net/atl1e/atl1e_param.c:214:
+                       .def  =3D ATL1E_DEFAULT_RX_MEM_SIZE,$

ERROR: spaces required around that '=' (ctx:WxV)
#5687: FILE: drivers/net/atl1e/atl1e_param.c:214:
+                       .def  =3D ATL1E_DEFAULT_RX_MEM_SIZE,
                              ^

ERROR: code indent should use tabs where possible
#5688: FILE: drivers/net/atl1e/atl1e_param.c:215:
+                       .arg  =3D { .r =3D { .min =3D ATL1E_MIN_RX_MEM_SIZE=$

ERROR: spaces required around that '=' (ctx:WxV)
#5688: FILE: drivers/net/atl1e/atl1e_param.c:215:
+                       .arg  =3D { .r =3D { .min =3D ATL1E_MIN_RX_MEM_SIZE=
                              ^

ERROR: spaces required around that '=' (ctx:WxV)
#5688: FILE: drivers/net/atl1e/atl1e_param.c:215:
+                       .arg  =3D { .r =3D { .min =3D ATL1E_MIN_RX_MEM_SIZE=
                                       ^

ERROR: spaces required around that '=' (ctx:WxV)
#5688: FILE: drivers/net/atl1e/atl1e_param.c:215:
+                       .arg  =3D { .r =3D { .min =3D ATL1E_MIN_RX_MEM_SIZE=
                                                  ^

ERROR: spaces required around that '=' (ctx:VxE)
#5688: FILE: drivers/net/atl1e/atl1e_param.c:215:
+                       .arg  =3D { .r =3D { .min =3D ATL1E_MIN_RX_MEM_SIZE=
                                                                           ^

ERROR: code indent should use tabs where possible
#5690: FILE: drivers/net/atl1e/atl1e_param.c:216:
+                                        .max =3D ATL1E_MAX_RX_MEM_SIZE} }$

ERROR: spaces required around that '=' (ctx:WxV)
#5690: FILE: drivers/net/atl1e/atl1e_param.c:216:
+                                        .max =3D ATL1E_MAX_RX_MEM_SIZE} }
                                              ^

ERROR: code indent should use tabs where possible
#5691: FILE: drivers/net/atl1e/atl1e_param.c:217:
+               };$

ERROR: code indent should use tabs where possible
#5692: FILE: drivers/net/atl1e/atl1e_param.c:218:
+               int val;$

ERROR: code indent should use tabs where possible
#5693: FILE: drivers/net/atl1e/atl1e_param.c:219:
+               if (num_rx_mem_size > bd) {$

ERROR: code indent should use tabs where possible
#5694: FILE: drivers/net/atl1e/atl1e_param.c:220:
+                       val =3D rx_mem_size[bd];$

ERROR: spaces required around that '=' (ctx:WxV)
#5694: FILE: drivers/net/atl1e/atl1e_param.c:220:
+                       val =3D rx_mem_size[bd];
                            ^

ERROR: code indent should use tabs where possible
#5695: FILE: drivers/net/atl1e/atl1e_param.c:221:
+                       atl1e_validate_option(&val, &opt, pdev);$

ERROR: code indent should use tabs where possible
#5696: FILE: drivers/net/atl1e/atl1e_param.c:222:
+                       adapter->rx_ring.page_size =3D (u32)val * 1024;$

WARNING: space prohibited between function name and open parenthesis '('
#5696: FILE: drivers/net/atl1e/atl1e_param.c:222:
+                       adapter->rx_ring.page_size =3D (u32)val * 1024;

ERROR: spaces required around that '=' (ctx:WxV)
#5696: FILE: drivers/net/atl1e/atl1e_param.c:222:
+                       adapter->rx_ring.page_size =3D (u32)val * 1024;
                                                   ^

ERROR: code indent should use tabs where possible
#5697: FILE: drivers/net/atl1e/atl1e_param.c:223:
+               } else {$

ERROR: code indent should use tabs where possible
#5698: FILE: drivers/net/atl1e/atl1e_param.c:224:
+                       adapter->rx_ring.page_size =3D (u32)opt.def * 1024;$

WARNING: space prohibited between function name and open parenthesis '('
#5698: FILE: drivers/net/atl1e/atl1e_param.c:224:
+                       adapter->rx_ring.page_size =3D (u32)opt.def * 1024;

ERROR: spaces required around that '=' (ctx:WxV)
#5698: FILE: drivers/net/atl1e/atl1e_param.c:224:
+                       adapter->rx_ring.page_size =3D (u32)opt.def * 1024;
                                                   ^

ERROR: code indent should use tabs where possible
#5699: FILE: drivers/net/atl1e/atl1e_param.c:225:
+               }$

ERROR: code indent should use tabs where possible
#5703: FILE: drivers/net/atl1e/atl1e_param.c:229:
+               struct atl1e_option opt =3D {$

ERROR: spaces required around that '=' (ctx:WxV)
#5703: FILE: drivers/net/atl1e/atl1e_param.c:229:
+               struct atl1e_option opt =3D {
                                        ^

ERROR: code indent should use tabs where possible
#5704: FILE: drivers/net/atl1e/atl1e_param.c:230:
+                       .type =3D range_option,$

ERROR: spaces required around that '=' (ctx:WxV)
#5704: FILE: drivers/net/atl1e/atl1e_param.c:230:
+                       .type =3D range_option,
                              ^

ERROR: code indent should use tabs where possible
#5705: FILE: drivers/net/atl1e/atl1e_param.c:231:
+                       .name =3D "Interrupt Moderate Timer",$

ERROR: spaces required around that '=' (ctx:WxV)
#5705: FILE: drivers/net/atl1e/atl1e_param.c:231:
+                       .name =3D "Interrupt Moderate Timer",
                              ^

ERROR: code indent should use tabs where possible
#5706: FILE: drivers/net/atl1e/atl1e_param.c:232:
+                       .err  =3D "using default of "$

ERROR: spaces required around that '=' (ctx:WxV)
#5706: FILE: drivers/net/atl1e/atl1e_param.c:232:
+                       .err  =3D "using default of "
                              ^

ERROR: code indent should use tabs where possible
#5707: FILE: drivers/net/atl1e/atl1e_param.c:233:
+                               __MODULE_STRING(INT_MOD_DEFAULT_CNT),$

ERROR: code indent should use tabs where possible
#5708: FILE: drivers/net/atl1e/atl1e_param.c:234:
+                       .def  =3D INT_MOD_DEFAULT_CNT,$

ERROR: spaces required around that '=' (ctx:WxV)
#5708: FILE: drivers/net/atl1e/atl1e_param.c:234:
+                       .def  =3D INT_MOD_DEFAULT_CNT,
                              ^

ERROR: code indent should use tabs where possible
#5709: FILE: drivers/net/atl1e/atl1e_param.c:235:
+                       .arg  =3D { .r =3D { .min =3D INT_MOD_MIN_CNT,$

ERROR: spaces required around that '=' (ctx:WxV)
#5709: FILE: drivers/net/atl1e/atl1e_param.c:235:
+                       .arg  =3D { .r =3D { .min =3D INT_MOD_MIN_CNT,
                              ^

ERROR: spaces required around that '=' (ctx:WxV)
#5709: FILE: drivers/net/atl1e/atl1e_param.c:235:
+                       .arg  =3D { .r =3D { .min =3D INT_MOD_MIN_CNT,
                                       ^

ERROR: spaces required around that '=' (ctx:WxV)
#5709: FILE: drivers/net/atl1e/atl1e_param.c:235:
+                       .arg  =3D { .r =3D { .min =3D INT_MOD_MIN_CNT,
                                                  ^

ERROR: code indent should use tabs where possible
#5710: FILE: drivers/net/atl1e/atl1e_param.c:236:
+                                        .max =3D INT_MOD_MAX_CNT} }$

ERROR: spaces required around that '=' (ctx:WxV)
#5710: FILE: drivers/net/atl1e/atl1e_param.c:236:
+                                        .max =3D INT_MOD_MAX_CNT} }
                                              ^

ERROR: code indent should use tabs where possible
#5711: FILE: drivers/net/atl1e/atl1e_param.c:237:
+               } ;$

ERROR: code indent should use tabs where possible
#5712: FILE: drivers/net/atl1e/atl1e_param.c:238:
+               int val;$

ERROR: code indent should use tabs where possible
#5713: FILE: drivers/net/atl1e/atl1e_param.c:239:
+               if (num_int_mod_timer > bd) {$

ERROR: code indent should use tabs where possible
#5714: FILE: drivers/net/atl1e/atl1e_param.c:240:
+                       val =3D int_mod_timer[bd];$

ERROR: spaces required around that '=' (ctx:WxV)
#5714: FILE: drivers/net/atl1e/atl1e_param.c:240:
+                       val =3D int_mod_timer[bd];
                            ^

ERROR: code indent should use tabs where possible
#5715: FILE: drivers/net/atl1e/atl1e_param.c:241:
+                       atl1e_validate_option(&val, &opt, pdev);$

ERROR: code indent should use tabs where possible
#5716: FILE: drivers/net/atl1e/atl1e_param.c:242:
+                       adapter->hw.imt =3D (u16) val;$

WARNING: space prohibited between function name and open parenthesis '('
#5716: FILE: drivers/net/atl1e/atl1e_param.c:242:
+                       adapter->hw.imt =3D (u16) val;

ERROR: spaces required around that '=' (ctx:WxV)
#5716: FILE: drivers/net/atl1e/atl1e_param.c:242:
+                       adapter->hw.imt =3D (u16) val;
                                        ^

ERROR: code indent should use tabs where possible
#5717: FILE: drivers/net/atl1e/atl1e_param.c:243:
+               } else$

ERROR: code indent should use tabs where possible
#5718: FILE: drivers/net/atl1e/atl1e_param.c:244:
+                       adapter->hw.imt =3D (u16)(opt.def);$

WARNING: space prohibited between function name and open parenthesis '('
#5718: FILE: drivers/net/atl1e/atl1e_param.c:244:
+                       adapter->hw.imt =3D (u16)(opt.def);

ERROR: spaces required around that '=' (ctx:WxV)
#5718: FILE: drivers/net/atl1e/atl1e_param.c:244:
+                       adapter->hw.imt =3D (u16)(opt.def);
                                        ^

ERROR: code indent should use tabs where possible
#5722: FILE: drivers/net/atl1e/atl1e_param.c:248:
+               struct atl1e_option opt =3D {$

ERROR: spaces required around that '=' (ctx:WxV)
#5722: FILE: drivers/net/atl1e/atl1e_param.c:248:
+               struct atl1e_option opt =3D {
                                        ^

ERROR: code indent should use tabs where possible
#5723: FILE: drivers/net/atl1e/atl1e_param.c:249:
+                       .type =3D range_option,$

ERROR: spaces required around that '=' (ctx:WxV)
#5723: FILE: drivers/net/atl1e/atl1e_param.c:249:
+                       .type =3D range_option,
                              ^

ERROR: code indent should use tabs where possible
#5724: FILE: drivers/net/atl1e/atl1e_param.c:250:
+                       .name =3D "Speed/Duplex Selection",$

ERROR: spaces required around that '=' (ctx:WxV)
#5724: FILE: drivers/net/atl1e/atl1e_param.c:250:
+                       .name =3D "Speed/Duplex Selection",
                              ^

ERROR: code indent should use tabs where possible
#5725: FILE: drivers/net/atl1e/atl1e_param.c:251:
+                       .err  =3D "using default of "$

ERROR: spaces required around that '=' (ctx:WxV)
#5725: FILE: drivers/net/atl1e/atl1e_param.c:251:
+                       .err  =3D "using default of "
                              ^

ERROR: code indent should use tabs where possible
#5726: FILE: drivers/net/atl1e/atl1e_param.c:252:
+                               __MODULE_STRING(MEDIA_TYPE_AUTO_SENSOR),$

ERROR: code indent should use tabs where possible
#5727: FILE: drivers/net/atl1e/atl1e_param.c:253:
+                       .def  =3D MEDIA_TYPE_AUTO_SENSOR,$

ERROR: spaces required around that '=' (ctx:WxV)
#5727: FILE: drivers/net/atl1e/atl1e_param.c:253:
+                       .def  =3D MEDIA_TYPE_AUTO_SENSOR,
                              ^

ERROR: code indent should use tabs where possible
#5728: FILE: drivers/net/atl1e/atl1e_param.c:254:
+                       .arg  =3D { .r =3D { .min =3D MEDIA_TYPE_AUTO_SENSO=$

ERROR: spaces required around that '=' (ctx:WxV)
#5728: FILE: drivers/net/atl1e/atl1e_param.c:254:
+                       .arg  =3D { .r =3D { .min =3D MEDIA_TYPE_AUTO_SENSO=
                              ^

ERROR: spaces required around that '=' (ctx:WxV)
#5728: FILE: drivers/net/atl1e/atl1e_param.c:254:
+                       .arg  =3D { .r =3D { .min =3D MEDIA_TYPE_AUTO_SENSO=
                                       ^

ERROR: spaces required around that '=' (ctx:WxV)
#5728: FILE: drivers/net/atl1e/atl1e_param.c:254:
+                       .arg  =3D { .r =3D { .min =3D MEDIA_TYPE_AUTO_SENSO=
                                                  ^

ERROR: spaces required around that '=' (ctx:VxE)
#5728: FILE: drivers/net/atl1e/atl1e_param.c:254:
+                       .arg  =3D { .r =3D { .min =3D MEDIA_TYPE_AUTO_SENSO=
                                                                           ^

ERROR: code indent should use tabs where possible
#5730: FILE: drivers/net/atl1e/atl1e_param.c:255:
+                                        .max =3D MEDIA_TYPE_10M_HALF} }$

ERROR: spaces required around that '=' (ctx:WxV)
#5730: FILE: drivers/net/atl1e/atl1e_param.c:255:
+                                        .max =3D MEDIA_TYPE_10M_HALF} }
                                              ^

ERROR: code indent should use tabs where possible
#5731: FILE: drivers/net/atl1e/atl1e_param.c:256:
+               } ;$

ERROR: code indent should use tabs where possible
#5732: FILE: drivers/net/atl1e/atl1e_param.c:257:
+               int val;$

ERROR: code indent should use tabs where possible
#5733: FILE: drivers/net/atl1e/atl1e_param.c:258:
+               if (num_media_type > bd) {$

ERROR: code indent should use tabs where possible
#5734: FILE: drivers/net/atl1e/atl1e_param.c:259:
+                       val =3D media_type[bd];$

ERROR: spaces required around that '=' (ctx:WxV)
#5734: FILE: drivers/net/atl1e/atl1e_param.c:259:
+                       val =3D media_type[bd];
                            ^

ERROR: code indent should use tabs where possible
#5735: FILE: drivers/net/atl1e/atl1e_param.c:260:
+                       atl1e_validate_option(&val, &opt, pdev);$

ERROR: code indent should use tabs where possible
#5736: FILE: drivers/net/atl1e/atl1e_param.c:261:
+                       adapter->hw.media_type =3D (u16) val;$

WARNING: space prohibited between function name and open parenthesis '('
#5736: FILE: drivers/net/atl1e/atl1e_param.c:261:
+                       adapter->hw.media_type =3D (u16) val;

ERROR: spaces required around that '=' (ctx:WxV)
#5736: FILE: drivers/net/atl1e/atl1e_param.c:261:
+                       adapter->hw.media_type =3D (u16) val;
                                               ^

ERROR: code indent should use tabs where possible
#5737: FILE: drivers/net/atl1e/atl1e_param.c:262:
+               } else {$

ERROR: code indent should use tabs where possible
#5738: FILE: drivers/net/atl1e/atl1e_param.c:263:
+                       adapter->hw.media_type =3D (u16)(opt.def);$

WARNING: space prohibited between function name and open parenthesis '('
#5738: FILE: drivers/net/atl1e/atl1e_param.c:263:
+                       adapter->hw.media_type =3D (u16)(opt.def);

ERROR: spaces required around that '=' (ctx:WxV)
#5738: FILE: drivers/net/atl1e/atl1e_param.c:263:
+                       adapter->hw.media_type =3D (u16)(opt.def);
                                               ^

ERROR: code indent should use tabs where possible
#5739: 
+               }$

total: 2487 errors, 91 warnings, 5564 lines checked

/tmp/atl1e.patch has style problems, please review.  If any of these errors
are false positives report them to the maintainer, see
CHECKPATCH in MAINTAINERS.
