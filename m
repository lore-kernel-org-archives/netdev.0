From: hayeswang <hayeswang@realtek.com>
Subject: RE: [PATCH] linux-firmware: Replace the old firmware
Date: Wed, 15 Jun 2011 10:38:50 +0800
Message-ID: <EEA878018465476FBC12F5D8C6EADF58@realtek.com.tw>
References: <1307956516-1203-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <romieu@fr.zoreil.com>, <netdev@vger.kernel.org>
To: <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:56017 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753709Ab1FOCjf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2011 22:39:35 -0400
In-Reply-To: <1307956516-1203-1-git-send-email-hayeswang@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 Hi David Woodhouse,

Please give up this patch. Thanks.
 
Best Regards,
Hayes


-----Original Message-----
From: Hayeswang [mailto:hayeswang@realtek.com] 
Sent: Monday, June 13, 2011 5:15 PM
To: dwmw2@infradead.org
Cc: romieu@fr.zoreil.com; netdev@vger.kernel.org; Hayeswang
Subject: [PATCH] linux-firmware: Replace the old firmware

Replace the old firmware with the new one which is embedded more
information. The old firmware needs the old method of parsing, and
the new firmware needs the new one. They are not compatible.

rtl8168d-3.fw replace rtl8168d-1.fw.
rtl8168d-4.fw replace rtl8168d-2.fw.
rtl8168e-3.fw replace rtl8168e-1.fw.
rtl8168e-4.fw replace rtl8168e-2.fw.
rtl8105e-2.fw replace rtl8105e-1.fw.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 WHENCE                |    4 ++++
 rtl_nic/rtl8105e-2.fw |  Bin 0 -> 2144 bytes
 rtl_nic/rtl8168d-3.fw |  Bin 0 -> 1584 bytes
 rtl_nic/rtl8168d-4.fw |  Bin 0 -> 1408 bytes
 rtl_nic/rtl8168e-3.fw |  Bin 2804 -> 5568 bytes
 rtl_nic/rtl8168e-4.fw |  Bin 0 -> 3984 bytes
 6 files changed, 4 insertions(+), 0 deletions(-)
 create mode 100644 rtl_nic/rtl8105e-2.fw
 create mode 100644 rtl_nic/rtl8168d-3.fw
 create mode 100644 rtl_nic/rtl8168d-4.fw
 create mode 100644 rtl_nic/rtl8168e-4.fw

diff --git a/WHENCE b/WHENCE
index d2abe41..8eba04a 100644
--- a/WHENCE
+++ b/WHENCE
@@ -1613,10 +1613,14 @@ Driver: r8169 - RealTek 8169/8168/8101 ethernet driver.

 File: rtl_nic/rtl8168d-1.fw
 File: rtl_nic/rtl8168d-2.fw
+File: rtl_nic/rtl8168d-3.fw
+File: rtl_nic/rtl8168d-4.fw
 File: rtl_nic/rtl8105e-1.fw
+File: rtl_nic/rtl8105e-2.fw
 File: rtl_nic/rtl8168e-1.fw
 File: rtl_nic/rtl8168e-2.fw
 File: rtl_nic/rtl8168e-3.fw
+File: rtl_nic/rtl8168e-4.fw

 Licence:
  * Copyright C 2011, Realtek Semiconductor Corporation
diff --git a/rtl_nic/rtl8105e-2.fw b/rtl_nic/rtl8105e-2.fw
new file mode 100644
index
0000000000000000000000000000000000000000..c19d8288e4bfdb0549a88e0fdc5ae1c3e79e32
db
GIT binary patch
literal 2144
zcma);Z-`W76vp4ZGp@U}<VuDX9(Ra^mI$0t+ZI2~LdFtpMH#xRFhj1XX|-rbAFNKb
zK~S3%T1YL8x&$SXv{6Yx`>BWs?T?XcA13HS`=ty;qBghRGxuJaZdeVxoO|E*oaa2}
z&wK7XxcT9omC?<+M|VF^=_?g)tgOGIGO}y?o-Mm7#lBT*LOF!c8ijBu6nj^eR<A6T
z3Z>q)YkJp~`oj1~cgTk>*BTwY+C%Gd4=<aCM_Jnwxy}6GfO*$m-fxR#3o^KQ{qcBj
zVHtTdt4Xi(Zr-ab?0dH&L%g~+nEzfe&%J5BaoBuC(R>6s_qzGacjimbd*h7xmB<}m
zm@h_N@ea?Y%sY5)ecQZ6TsE5LB{!L01BUimlD#~8!W}G`pJj<>0nYiVxp=K^;;FdW
z6wgyExQ6>!_|fV(Vg403vab&&{=mq_B+Sbby((Baa0*-g!pXg5eie2@=qyFn$w3EP
zpJUB|eS~~mm*LbYPGjap_!Y4ED08kFv>(G4=Q-j{IsZ*klN-=E`HguL%+Grqi(^|5
zE_N$2xDjWU{SREl9F3E6e4KxRx+QrIgXXI;n2Mzhf9i+#Ce5d)@5T9;O9B1x80%j1
zbx97(?3ELJ;dkB@*Q|k&V5K#4a#z2{{Gn;{1;i-qKfsoK8Gou>6+Gp93A`FT1BPTC
z8J_(297e~`fx|5LIq<*b{bP7Ol5m{{yV%s<6Q|-_U!-T{+c}T6fzi}gX)bnV@}!#P
z4xpRlLwDr^;!E$!EIxHtj(%=FOpN2mA><BX-hiy(dq(oJnCn?Lzkp49Qky#XMecU7
zsW<D&^ZI|*O!*bhHgc%D5hZtFA9#wZMqD-Z@sRo9iuoiym49(kp62kaUTo+pu6L;;
zc%9XFhIHXmy+4I*Za<4N_3;Acg7d8Vt@+Rc_w-${U+SI+Tm99Y$!S_+@tB53W44XN
zzLncc={IU{|9_lQSLIjO;db+M4mM^VXU%hO5xJUIti(4=Y@3K{D>5Q>_5Km^HbK6g
zM!tenO%EbxU*bH$lAi*8eqb;EY*L>)!91GWFP>Y_-P6>MduNz|^I(AWJ@#enZyGRP
zMo)jzA9L59?u+_B^H6=5%1`%E=P%7~#Xk3<d4J7(4DQ0JV)rUoJ-5U-dhelk^`7Eo
zXZ4TxOtDjW93TD6_3Oc&NP4vfRs@#_o&&7?_(}C8b8t*+w~*(b!JTKlkmzYodP|X-
zqrW~M$9n)@r-@_HA^PfT@<v>K+WZ7LiVmB<kN?JOz^9(a&^gDM<S$5lQ&fjK{L&bo
zLH8uS)3a&L&Sm(v!=r6o%%K|&%gE`q_?|?*2JV>z*Rf6KXIh8F*!JK<{>s!S`>j(>
rrzXvR0we8}^gEF4yWh}J-(C1H{$}aBCEofE5TfN?)c*iIC%-=d;3S|Q

literal 0
HcmV?d00001

diff --git a/rtl_nic/rtl8168d-3.fw b/rtl_nic/rtl8168d-3.fw
new file mode 100644
index
0000000000000000000000000000000000000000..17309e299a23991bc8ea7aa64d371ba381cda7
70
GIT binary patch
literal 1584
zcmb7_&ud&&6vyvOW{#;*GqpmA5fh{<p>$^2skEy>LTzo*v|=T(n-*030|ZlO;oFQG
zTMKSPagn5`AR{EGD_wMUZmm&5#gx8IlL{@&xY9|QPW+si_h@w2f$+WOo*(ynzvsN0
z*GBi}OQn~Gi~0P4-TBh)Vj=wJSH?P<3gOF;-@m7@cTb@(T-bN8R6JPP7cRfGD`dlv
z218aMSO~TEzIFTW&8!qmL0PS}OwDyuW72e&b%XtTU<956TenP;=ZWbz9Y~pG(yWbj
z&NSOg{EPp~BPPk4AaABjEV<P~rdprr<7w0Mk}3U}X`I+?^Vl`h680Rvl-D0OwLdX!
zJmCDSX?+cB!1r#9_rSX8_BqpeIBx&S^z?R9dC@fDwMR@lsWpdPb-UWN`#EcbSoe>y
zuKF6^E6!noyX-I>t8_IObA<P3jN|eCi5OpX+%z2pBQOtE&}yP!T4|dux^}DhE}4q4
zZ*s4xPED`9>j~3eZ^HX|;#N$nADJ$b<2)jG_<1X6>{y9RQ^(Moo<xs#_i}Tb4}a$y
zp`&AV%Jlin!}ysDK5DqH2VehIA35_`(*itN7fcs8ci{`uGV4T(!{qrq907eE{O-=l
zF*QNoXX(i`lYTM1GZgoP9{K#VxZAMb?GAT~_tL-8*YCS=O?r2#NDtNRVGrCknU^Qg
z@;Pchdy>As&AePeGxD5E<+f??i0PX*m=R|04%pfM)0AUB;gLa``VS9tn)vF}@}6~S
z9HsYO<Ed_q&OSBj?0au2aE?a1>p(5n$aV2P<i<eyH4h4XeI2n*H16A~G5!XB?u(e~
zN0|dZ>sH=WAUE|cnsLtRMbjm;eTjLkH0UWa(TR(>rUp$J&c9MMeI3VSJcigXj&8n3
z-6__yJ#c%b%WaW4SSp)dNAqcTF7CvhBj?Ai-NsJ7#g_9rZ8`&wbiymPJHErr3%-7O
znD+iV?|9E=#p~BjnT~U>Lrv4bvgz6lVpGfm->mzi_f4m%;cw5x8D@@mpkuGX1A7fk
z@AGEWelnGbt6b$<KaNh+7<|n1^M|HhzWqOVC%zkCuI`&2w5dnlR*t<1|CrxDaNf!{
zv%w70+jKC!fR2tgu~W?G4Q$7C&Tmq`c9s~{1J~jFJNkaW-Zs-!zmvZ~aP{}@Q|{a*
zFH7xBbWOo4fPVk$m8?z(?LmJFe**({ZaA&5+`}6_#IxO}<PG0|PiK$+0m<)QUJh0t

literal 0
HcmV?d00001

diff --git a/rtl_nic/rtl8168d-4.fw b/rtl_nic/rtl8168d-4.fw
new file mode 100644
index
0000000000000000000000000000000000000000..b35fb1b70eae2bdadad668b79462c9b94c0b00
8f
GIT binary patch
literal 1408
zcmb7^OGuPa6vyw3^PSAB86$`?bO>n|%}kAzD;Lts$COl<Z4xTlv<wmwj@l+oXcx55
zX(5HdM7gR(L5sGTffyx?IvNy=t;%Q9?|MH=mwlUa&*Pr+KmT*S+uTqcOD5~0iCFCD
z{#bH<B5pQ(wP>k;G3_Q+eIS1DKs+9eAF4?vYLZ7x-{mUfnMy4;o*E;@44-;t^`8Y#
z)rcDPbYWgJzbN|6N^IYeQ^;G$`DxL?4$-nQ(b4UqW3{4nb)ua?^tb3~(V-!yXV3@3
z&Y!_Q*yw!r{Pei!n@-X0JT;q~4CA+YxWTule0j#n!YN<YBeSBDG0}Lp=<gPA<wR$C
zM0>%w>Pv_o#23DRJ|$X8?$#>NiXWmmaNo7P%z&fM$3eb`tw)|LvWdIqrfA84%a_JB
z7~u@QfW=GvO=Q1E`~w#sB0kc;&R2vl?0f-y9=_5H+&rc3BhhC1Up@D(<Kl#?VNSX{
z5!*YMT95+)(UEVW?~Q1sGLx%rMs_Bx-|3B>W~081-acR(hU=-{Zgz<|QN8G9*v||*
zz*i`cd#mWVJ)&23i#}woAMQ~T&Zfa~5+2T%ixxjYa=&|4^s8@w4<8ms8XPY|8}D4P
zu{H-YtM_wk8(Npcx7(OmX4627<uuK?)Hq(U@Y0AqM;$9eaF?T=J^$su2#&Y><3D8i
z&x;0`&HwB{mOY5sypy8W;?#lb9{997k^x8lu&a@!-YQn&%E8)C+z`EI9uo7|#pKab
z<jT-T7T)Z+i23iZy9725Y_+3sJ_gRSqHjCt8~vr#xnuPeX67w(9}Jf)j!AH}fh*|i
z;L4((@O>@pOGViES8e!5u-SYiUDSOoI(J(1^D)thUF`6PXcxJHC8GQA&u96cE{V30
zZ>0sDotyFX5I7bWz_o;(Jg;g+Pt#K%ExIWndWZcOeaAadEV}EH=+blkN%ktV;_$Cw
zyat{eF>ClN=G?D;`Z9VW+?gmmg3atjM;5-IQ>QRNedH2vQ#<=*v5XV*k$!H2dGi20
zVH>+HdZP<`+?`8t@4o0VeD3rduASrv81myE@8%s;?jTd#i9~~HJ{R#eR`MKf(Y3d6
J*~VKN-yhTU5+48n

literal 0
HcmV?d00001

diff --git a/rtl_nic/rtl8168e-3.fw b/rtl_nic/rtl8168e-3.fw
index
cb494071d0273c7b3102b97552f4bc7b756c0e17..d3497e897c447bce05859be45cd7ca3f9ad7a2
a3 100644
GIT binary patch
literal 5568
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

literal 2804
zcmaKuS!|S56vyvuXDEwdX=z8WolZ+xrAP=!Vq#-Nc`(M9m<Srf13vJiQ4@-BIfa&`
zMS>d`6R?UeXp0DaGtxc~Ow<@#AOWSxH%JAQw21-A(sulv@B5~F;_~q2-gE9*{^x(s
zJu}W#sjG16T$w8jxh!jsTkSNBzTQ=$cQ3}A^PHP)Mp<?7_Vv!~b}qHVg}!E6^Ecaa
zhfmgFTN>J?u(?)9sXFmvo4q7vYMSp0SElP4GJ2TRHD>fnTi?j&5!S;mW%Q`YZ)UX1
z<d-uVi<N20Wi-K>U`?@(F3G5{4)4oon)L)SwfH$4IpT&j{MJ>M`xqL)kaQJVo32nd
zmeFOlj%KvBf^`JhR%G8V;^Xi!U9={r)D{;VUM=cT<8VP#+eHtdi(eBhi;2c;pA)Sw
z?jICg!`}SjJ4FwwXqzXR-!8hN4f{&uyl7=BI_%n_I_ypNR#dl3v>n|y<p1iBXwxat
z3;RXi!KQ6MwD(=n?u6*u&7v#F*;|9m`d%mxB1?<tAT|?NyVr?s$Jbp3TSjy@`@tK+
zJ+hL+YU~}uj{Wv%Ov4(=Nn(1}1Dx4T{7QqpakQ4Y5{;rIU`!bYKZ`!FS#&A;k^4li
zCyC>Uc2d{fS<x&!wq3vud0vy~Li71fbpE}>v3-~5`}i!j{kNhoMEoaJi&jVcmvJ@=
zJMWU{F6zpG?OF=Ha)DgTI|2MP5x?2sDxRfkMQg(|4@?$kPBG4$JL1%d)<xo61@m~E
zxuSC;XRpG4azyk7ybaw1;|9@f#5Vr=o)7r`tzL9F_$%@2rnal0JQ=xiTA;fg)lCm{
zx1zckfo^YA5X<-Fek|Uu=7?@47|`wHzT(*CxUbe<xfgn{6h4-KYlxgrgJ=I_^lAEM
zIr_EK@ezI8iy!^ySnIpl{|TonME4Adj?zEHT7RHctM?}L#^~Lyr@+Gbhar|uYI}5^
zXtTxG%YBh!UWe$9&mhxJ)tmW{JGe)CXOEN9!}i#5aBd|}pJ?U`-&xUfVC<)-(|kL2
zh^_}q`Z>`l1<_~W*uniHmDrx+>lZzL1Ra>VW1@S(WAEn>y>aXw(c|>!R`T@0-I=85
z*)VR=_XxR8UBMrWMeJ7p5Vei%;X6UUk8<DO_Rfp`^1J9C#7x6q0zR|g@ZkGmsP{O_
z(;uU(N%I4%^-@O@@1*YbzLY!j^(~@zWpD4Tr+xi4c&g>S!PA97V$BX$YVvWsCi*&Y
z{e1U}u4KQMyY8F?Pb-6at+u;39o*+;<AfR0F$o>^LR{0uPx98b1U1^5Zp{-DKAPz1
zI^xBt`_mkEIUL~Xq>dEWYw#UDi0ypQmazZL_H%e%P_(7C6!lCu+l$yP4Bkp@7<VIi
z7h&5vKz?$L&lGYb;Hnxwk2AwkjgMC%dWAmE(ns-x=m*3$t~$w60*9^aJBX72-wgA;
z6=180_~t_2o4h&S7oJPtdEA$nTksu$-+$x7n?Nst+n*(tgPtG9H&JwAb1*Mb?Ysdy
zkMLu@m%wke_-6|u_&Cc_XQJpA;mZ6RH5ShX76m-GkD2kD*^EC;&DQrL;2-23%|40V
z=DW=&<J_ZHP4CEIcXfa|uF?mwP(F%02{|6hUn3`wE$@g6_^=re-@u#UtYr{i^foI-
zcrV76=^SsW*|5;FzRu%K2ycemu_}6Rzvuun$>b#Qi*bsx#&X;uM+^NsM4Y}&<Redx
zFHQ~qoVpzJ^$hEAW|qyHRZ~Q()-VIWbF!cJ1~>im{8Vz-`~JVLoPJ1tB3k(VpR;cq
z549yM4sWVk$qW8X<XXk|Uzp~?dm}aE3&HPpjQ6?tvjF3!v&>}THF4M7;BBXOiog9s
zF>vEIZ8AI_W~DZNKJ5$Yws{?ujYFHW#^(WkJG!`Y<!z7G1&-)U&tto>L9`)HUyyrg
zPV@=(`B&iJVbPyF^k9Cnhkmj>Slwfy59L$Fqy2}R%G%R#hg|&c<--4_g@POZZ(97n
VdHX+Uxf?6kf6?+D|9>1#e*sYqwB!H)

diff --git a/rtl_nic/rtl8168e-4.fw b/rtl_nic/rtl8168e-4.fw
new file mode 100644
index
0000000000000000000000000000000000000000..1ded93185fff12bd206ebf0762471b5b1434d6
cd
GIT binary patch
literal 3984
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

literal 0
HcmV?d00001

--
1.7.3.2


