From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH firmware] rtl_nic: update firmware for RTL8168G
Date: Wed, 6 Feb 2013 23:18:59 +0800
Message-ID: <1360163939-3625-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <romieu@fr.zoreil.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <dwmw2@infradead.org>, <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:57132 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756951Ab3BFPTr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2013 10:19:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46ile: rtl_nic/rtl8168g-2.fw
Version: 0.0.1

This firmware supports new fw setting mothod for linux kernel.

Add MAC OCP settings for:
 -phy reset
 -PXE in ALDPS
 -pwron sequence
 -OBFF

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 WHENCE                |   3 +++
 rtl_nic/rtl8168g-2.fw | Bin 0 -> 4896 bytes
 2 files changed, 3 insertions(+)
 create mode 100644 rtl_nic/rtl8168g-2.fw

diff --git a/WHENCE b/WHENCE
index 96142c2..34a0bba 100644
--- a/WHENCE
+++ b/WHENCE
@@ -1841,6 +1841,9 @@ Version: 0.0.1
 File: rtl_nic/rtl8168g-1.fw
 Version: 0.0.3
=20
+File: rtl_nic/rtl8168g-2.fw
+Version: 0.0.1
+
 Licence:
  * Copyright =C2=A9 2011, Realtek Semiconductor Corporation
  *
diff --git a/rtl_nic/rtl8168g-2.fw b/rtl_nic/rtl8168g-2.fw
new file mode 100644
index 0000000000000000000000000000000000000000..944d44e6a66a266ee2f92f4=
eb8215acbf58bf3c0
GIT binary patch
literal 4896
zcma)=3D3viXi7035}xd|bLaFeXzk&xV^5TjK{f&&yShM2?~hql&nv{0rAPo+goF;d53
zJw!05pj0U$qNWOp7DIj1VQ5M&BnGug4Yt0=3D`M`kIDuFr%L^S=3DK`+XNK8J#JxoZa(2
z|2@0=3DCB_)DsBz(>vI&!}KCis4bZqI^vT$knxY7yZ%ElwpKf-uCXiS^AeA<Na^6^va
z7R|c0ZqD^{=3DhZdLYMgUTU0HeQr1J8*YZu%wXPhed?3f0UAB>&7;JR?x#K~pllh2=3DE
zR&5-uUROP+{|Ahz*fq33j7eprG13_sj1VJ>VHr7+WQ;55rMgCPT}MW_K`C%kq{vN`
zF>acax#{vFH$(Q;hGfW*ELphN%Kq9MNjp4TqWL3b-`#nV)|D^O--M+hQY6twMoUY6
zu?*T>g6tew_|UnM)HPPjj#9~azFZcY^JU@36U6D71aGpKmJ69rVO~K#m9jXuN}OFa
zVzx(QL-M7pry>6_^2=3DmK%H?vf@d~*q_ey!c=3D4WEEXGrqlnR2Z07t#@_m(Iv+Iks}H
zd^C5yI33rB`RgyGC1s)XG+rk!);37Wkwwx~+bDyMES8rdH_6M9n<dj-0{xvtA|e@X
z6LgvEuDzZ5R=3D~eghIFlzf>C$Nu2rkWjJj7kR;`iDQEMf-YMnUldZ~?UkOONTCdU?X
zd{hnxHp=3D-ukIOr?n<e+~Q<C4YMdmiPN@wk##U6Q9ayy=3Dv`nfO2al1{N<J)DZ+a|+0
zc1V3=3DRHC)J<cuSolG)KEvm0NMosm~$_J&twYGe=3DebxG^kE5W>fO8v?=3DCFs5_XXd>=
t
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

literal 0
HcmV?d00001

--=20
1.8.1
