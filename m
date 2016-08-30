From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH] rtl_bt: Add firmware and config file for RTL8822BE
Date: Tue, 30 Aug 2016 09:08:01 -0500
Message-ID: <1472566081-1072-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: linux-wireless@vger.kernel.org,
        Larry Finger <Larry.Finger@lwfinger.net>,
        netdev@vger.kernel.org,
        =?UTF-8?q?=E9=99=86=E6=9C=B1=E4=BC=9F?= <alex_lu@realsil.com.cn>,
        linux-bluetooth@vger.kernel.org
To: linux-firmware@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:33891 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750881AbcH3OIS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2016 10:08:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This device is a new model from Realtek. Updates to driver btrtl will
soon be submitted to the kernel.

These files were provided by the Realtek developer.

Signed-off-by: 陆朱伟 <alex_lu@realsil.com.cn>
Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: linux-bluetooth@vger.kernel.org
---
 WHENCE                     |   3 +++
 rtl_bt/rtl8822b_config.bin | Bin 0 -> 32 bytes
 rtl_bt/rtl8822b_fw.bin     | Bin 0 -> 51756 bytes
 3 files changed, 3 insertions(+)
 create mode 100644 rtl_bt/rtl8822b_config.bin
 create mode 100644 rtl_bt/rtl8822b_fw.bin

diff --git a/WHENCE b/WHENCE
index d0bef0d..a9d7c97 100644
--- a/WHENCE
+++ b/WHENCE
@@ -2755,11 +2755,14 @@ File: rtl_bt/rtl8723b_fw.bin
 File: rtl_bt/rtl8761a_fw.bin
 File: rtl_bt/rtl8812ae_fw.bin
 File: rtl_bt/rtl8821a_fw.bin
+File: rtl_bt/rtl8822e_fw.bin
+File: rtl_bt/rtl8822e_config.bin
 
 Licence: Redistributable. See LICENCE.rtlwifi_firmware.txt for details.
 
 Found in vendor driver, linux_bt_usb_2.11.20140423_8723be.rar
 From https://github.com/troy-tan/driver_store
+Files rtl_bt/rtl8822e_* came directly from Realtek.
 
 --------------------------------------------------------------------------
 
diff --git a/rtl_bt/rtl8822b_config.bin b/rtl_bt/rtl8822b_config.bin
new file mode 100644
index 0000000000000000000000000000000000000000..a691e7ca258b0e7dc4ff2bdbdc1d13f2a613526b
GIT binary patch
literal 32
ncmWGtt=ulfaGQbAX&)n#faGpQMq3vKHbEt07gmOw42=2!f)WPF

literal 0
HcmV?d00001

diff --git a/rtl_bt/rtl8822b_fw.bin b/rtl_bt/rtl8822b_fw.bin
new file mode 100644
index 0000000000000000000000000000000000000000..b7d6d1229491314875b3d4a7266462c47998c0fb
GIT binary patch
literal 51756
zcmeEv31CxYy7oEANt&c-ds4atC=k+uP>MoZa2eFJYz0z8R73<#DD{*qEmm+`20bhe
zI2H#en}~Bm+M+^1NLt2w?|5%4-~#0iq#%lVr?Si~Nm^2<FylW?{^vbuXmK59`RBj)
zPT@Ptm+yS*`)%+0KJPcP)aqDVT2gk~=()S(49mzEIg@jzYI1GiD28EtcQTA=6&|kr
zeOaQI&mCLrF>PJ!UA(t2e|f%m<T0-aZn4L5nz29Tu{1@W@jHALdzaw4r2G0fo*(x{
zuRq4~kG;|B6L@~Y8@)b>=O?|<>r;4s%1hVQ@I+T@c!5h*Zpw8ATEmaHEP0l^;$Uld
zvWvMwewAKlpfImBJi*r*F7+{23UlY<?Ge09_Bp%`#NqHdadmcI%kf<9r7LT<2cy6A
z_?3Gr@JmJabrGKBwrK%Zc$QCYbA|6mti>+Y?h9{mQErNTzVHJsQ|_98FTB+y=8O5o
zAz%1GDQ9Z})`m5K!hBzNHbT85<!m|Lw&LwU--8~Pn{%vbcQtKyuW3KpzP)L7V?muW
zuqIG&$Pm8AWeBgA;&lcL;hDa|T=@A!{lCeWQd4-oYdUJ%6fSWU<6i8=^>ncpey68*
zU+=>6UEb(*2A*elqu0Cftk}%0WiHA~n9^Z)^5QH;CtBd{h1)ld7a5gKWGuWmAe|R8
z5_RH|AMs*6{EFqgcrH#SjzO3%+z;t_aWC!({dln%zu%|f#e?xW@q&sM%hWot^9Ek5
z)#$|c6$pp>+e3NLf^a$|!r?v=_iebB#_?h+?jSUAO)4**K%CqA^WrD?X3bb$T#es0
zBJ5t=pUcKO;ufFKiR+O534|Gfy8-Ds5ypowzwgV79NzD{4c};`c=aO6c85$SuEuv&
za0#~~Y=Tbw2;a0O>BN(2UL1yR6u39zejfg7@$KihZ@^uFJl4ZM754_*wVs3qORZ}w
zXLAI!M$=XIm`Czh$DUwSFyg2RGBz&L(8k&n9+TV9#*{LpGhEDGN_RWTMm`#kA-vd~
zhOd(=IjgCboikf79aMTO?l|~yGiM8|-OyGZpmw1=M@raZj4i_}zHGi(bhe)>soB*Y
zDX$MU2X7dW?zOz!ezv5B-V7sB@%H7}v#*BQo7?-2WT!R<)N{^SdEPuK_1xJy(YdR=
z{$ixO`C|M{?Afy}3Z;}n>E?7;SsTkUHg+xY4%(QY(}@ds&<5@io4LarGPj2U_n&93
zxW+J7YR0_T-g1t)BIYw!R^&&n4zee=ZwV!bo<DDBa|Gz!5puMzJHINo=Up^ALd<1$
zuA`l?DXd~~q}b6OnKxUA){)*b%3*X`I+r(DI#)Gm9hS~oJgsg@aL#Zrc1vd+-kxtt
zcRqn%O7Oe`&Ib1aoCD4YR}NPJw+QZ0xJtOknxgSjT}Et5Z&kpQi+>+mUPdl$lsl%h
zsD{}au~Dw;gH?g}#`p&9epBx5P<*2)w>eZCst-9s>PC%M{In{lZm2>{7Y7Y(mQO*m
zESxM7VIm9@iAeE8B40)#kw5;SByPU)xZ+s<y{t{_Eb@t+^L%~L!Ub+_p}wJSqu4nD
zeow;9@iF@T;}XhKrC(DT#LlPTJJ;7odQV2kJAAHA2V8M?$VBOvxXrH4a`@imQ?65>
zM{^}q#y{M_iy>AghHz)lzaw}~!JUKC!=W~8j7^S_TkbWqnU3UuzJ|duwxT>$!=vX=
z*Pp~SPRL((-qOrYm0B{OnbT>dS{#RP3*d;liCS4utHNm7ro%Yu2$(*hxTXFD%2yc^
z5JJS*33{+Q0twj~yz}@%WwdOQg&91_jjUaU5sbdufWG^yY@K*ZicVB{T{W!Tw5>iU
z%jE6OfDG*-%j7W5_oTrvJTt%6axMO3W4y<*GjeqRdZ6X-MYOFW5a*?~b_P^o2C*o-
zrjMo4m%d2l#dz~8^h<8NX{YIE)StD>yK}>oeu*%$ue{5@^3HwbU4<NcQ_39G^vBHg
z>0&0GkZbC~$lg{38l=3?9BbOf%rsb*)w6b@&#EBbpvrXBQwbstbGx(sX|sYi)khpp
zo3CCS<Ye@oiRN~dH{uYTCX5PIf!zU6_yNUc))pP(pJJK)Z*|Ab9YdUDRc*|rWCwk@
zS70usTzg8p_N4EAip>;6%cDKM@H)3IyvU6>oMOH+#9U&~%MG1Ax1rPOR%Ti9js}rW
z$C{v$x8$k9tmA0#g-}(nK4|E)G|kULs3wDl!Wue7ip6HhTNBJ^ury~N{{zgHU5>y~
zq3B3quF75<oF_cmM0tE|XBukCS{Rp^VSgf!;!O@rIoroua=K41-$comhp*fo=dlOn
z4p;c`CRccKlh*T`yDC`P6t_9nKU6wqe+KI0oKh$H96Iqc%uj82F3#e`xs!FG)CToz
zm%LJL74;F8DOGGnkCEofFG}L)YmTdr-RQY#A14sC5tWIZrQ4@wQqJS-=Ah!92^K@x
zT-$m{<rwPS5}^DtmmYGnmA6<J{k;>FEz4hW3yfa<5mVmq8tYJ2yT^FOtZdhZ8D~{H
zKg1BOcj4Re58IR5cb{zyFRbBcRIiae*3X(SM{i}j7<*MPInxlXqHy*nLJ1AYLFc(>
z$apEF!m7rMBB#-uXKnGDHS5$EACx5nQSQa#G1sp{IYHmj7<H^aW}{ii-w118kJvfU
zeS=Z&St<~vn06K&LGABk^y@p!ZA#-Sf~Hwzla0~_;_$qvRwea5)~@7x-W2F*GY-xZ
zUfUUwsA!NmZnIJvov_|mtP?4H$_KRp)pc2Y<gtDh9(maBP8)&}Io}K>G@?Z3-`pu)
zD%`av5T8A*mNS;r(rl~9j%$=5-lxYh<vr~}@lu&?Wm$&eO!8Q^vW_H=*u>Zpc-OAa
zt`2h4hqR4v?%orU=U`NGpvQHUy?klJSK>n}55xN67Ss*JN%8%k67_u5@wj7pPhW3I
zV5n8^5x45SF9rvXknK!w9KfeH6iyr;>Sy&4MOTcUG`=mxI`MpFNM~JEXQ`up5(>3m
zPMNE=jBicw$cxvVq0v6nwof=SOubpPE)I30z<e8i7;6xW&pB}S?aEx0i+coqG^SIT
zv>uFzozFJK<N8#S2G^&XOr1Z0TMG9~lcGV{NHOzNFDM6nw-samCzuCfberbEYT-0v
zOWBv^WnR(-2W0xL>gJ?cWp=J5*{f(_?JI;YoU*R|<+Ya+DwHh-eXcXkpWsRGY6BR1
zKT`0q8R0+Ed#H*jos0RCVa8!dl`$EV?+6oSm^vnwZn|fjozhL+$J&{f)(Vc$z${8R
z%_?(nCv**p6JI!22xl%|pKip)PMsFe2I@djz0>~WYiU!OmrDB2?{~Z}jc_(|sH#kl
z^$PV5#-{Rb@+6!b_`#r4niI)w1+5!APqZfor<~RLr@6Enll=}?TFXXPyNf^38h*a6
z+*S128?N_X<8oFA@%~cuqWBM<6PkoRAEcZz=zlXgwI#LMDA3aiAz?$~YsD8RMT5To
zRP%*Cn{oovFPN?{w%HwN>qlJhT{Vs#HacZ<a>s)mZ1(xK<Upc-@)m2MDl<7)j+t}d
z2AR!t&|rI?kFS=#3Z_*j2c8bFBM>&2)KU};8+wt#ZbaBa2HQXLhH#lndDC6viHiR?
zM`=~^k;i0cLmAJG;1-^8rLB)R6wWEX)s$8R-V79%2886mUAa{O^O!H%*_+O{wF$}X
zfp(dNomv&(=B$5BWr-|STL)Gn{sV(H7;Gi{_)xr`!zfnkk}r%uso9*oA#EdfDq*uh
zzq^RaFE`2`Wi7IW+6}GYDYa~6l2yA|#kGd(US;%W-cD^%t!EuR?8B-86LP2eQmY4{
zoSgq=kHW7!ZmI=^InG>R$`4*nt4QspF~m7o@xa}d8~7Wsc92!_){(fgm0BymQ8QAr
zp~}WCoE^$)z-W4ob!=?v!)rGp?K*ijYa6(E6tAhSvds==Nb>+|U(z&igBCSAoR8nA
zuqAG)&z}>b`j0p?8<RFGT9PqGCTuY1|8*MYS7Z;YM%V*me91huhwM?)LC%_Q8?@1M
zNX>JPa#o#f&}P%Sa(+<tK!oeRx!=0J=(CCFv%aa(afj%y0dvTk*h_>;ZkRvx_>d?a
zwx^tYOL%wUl<B@53k1et3a>nBxWY8}4&vH)uBPTW)=_nlxi9sU(%KI-l(OMjr?$K=
zpRy5@yYQCw*3UB<lP}bL<_quK-gjP{1@~nu;j3+|4{36;Y$+R3H*<da#-M+pFH`z)
zvhVYhy_U{3E-}pHyi@a~koLi<8dF$&cXiF+6R+18P9Clq^g*zu@2RSq0Vj6XWSsnY
zjU02i{=|zl`b}#(%pLj<*41$3Vt)FGwKeIR*IYDTOg}ZVrt`J_{_2{@)eM{Y;=mLA
zH*~&dM7yngDDxDRE^~9~bk~jn8`=Y=PM6Q1mruF-y$sZ@e2PryyQ!cxVl%hB-5M6m
z7yF$uR`=nn99sg0&-uobP068k=WFW!qg^pl+{P}Bx5yW(L6u($rtpMcze3k~`J6VZ
zyfV>(p1D0fhrVp>N|C7G72(whcNdFwtDDj`=oALMtjO46tY$jXj0XMKhnZ5DF~L@m
z?(5<_md?A}@;MsYvsbAGr*7ve<(A~ihp!H@f`YcQm3?qOw4LHOJcH-nLb}{;P*a=O
zrS;HwVG5h-ruYW&2L1A>OlhQYDdp@)oCWn-1DfA%(2q`Q5-7i1J$+~DN{M|}JH<D7
z!rfC%?jm2xdYaq56y6LNx>O!h_~5H?j^@y#<wrW!<|nr|p7Di$QYW(&V{fr0i04DX
z<fYRrHLE61G247%{i~CoEMD=RtM1*&OQ!Gg`F04C=S^$&(eF;P(<j!xI(cF7i$41O
zf$4Afe0zk+_f326J<G0DlS|DD-=p6jE#4sgZk^tU@6(;9e7>-4yDw~iI|Xeu^kJjl
zxc*BaS#J8UH9WOI+*yP2tp0Utxa##~M+$e!9EC?(U;5NDb?3W+u_f~qqhI_~s-LSg
zR%dQjSQb@kE%Hi@C7oX(yo$BWMVqXA2zq9!-^jD}V`zazO$PljD^p5!SG&ug_urMW
zVWlo*L!wPvE~|LfN%YJ4qqUik_PmQ)VdZXv{!7&OB3=7yjP2Ee<wD=$f8WpO2O2ql
zqLD>^`4vVKnd52O7tWHf65~l~1<hDW|LT_*z1*0((bSnNh4V<^mP+B0dxaaX`;=O3
z54GB>(Kg#6uYA~|s1(CV7PhiA+}AqGrI|AaR5{C6Bdo=^ubE<OiRR7}W|gL}EKbx9
zlc#KqLw>d(9n+S+n~c>;|16j4gD-_RKT#a(_`<37-&0c)PAS*;P2qx9<8du~wf1sy
z1@)v{r`B)KrxY=c2x>IWDzm+Ud=+43K&XR6rLJ)QY)aKs_wK~Ir%yo(ekr`?0|nNB
zlHQ0>A@zV)`6n7?)ygn0#9|p_tH!)N>tM}y<o^29sa6W!ky3w$QeT?=C8hl;sCjaf
zniuob^Y5NcIq>ax(DQuLdrki}an;0kCoa8fiuuXut*?spz8!(46^D;>`!Bg`p4mzM
zwZ0vprZr9f(e1zRt_RHbMZ@p8*tGia`-h|Pl-~8I*$RK(4zaeY=~UCkrd3<?&Q+&Z
zZ&`hM{cGzFSHD($*brXrf@|9N+Q!3F&%W@q7&W)ZZKe;6)s*krH&QmOz+EOoi^UoA
z_f6+|)ppXgdWzO|951s`O&1)>qS`;yy2Tehyq(6FG*@1Y@dFxZGEZf0Hf~bem8be{
z=34q=<)k{L{vhs{=2-l3t$!)LF07$8PoTE08Q-bJdMZVt%|!nz0*iPH4yJCV(cYkc
zxv#eThRs9Q4OvS&wv>`vvG$~W2(4#%W+hAOWtwMhFI0#$&(xcB;?)w}eEwKjE&6~!
zJ8(vSKlp-TxKDPOOIjtvr;A-Hh+$3kJ<>d?vX;42SU+?4<s<y^3__Z^-^a_=3Xf;c
z-%=p0=Ebnm_=u}#-=1Y;?Bmgc%bFPduRdfP2L0P*OlgwwPLI`{K`~USEswaKwXqII
z!1s9uO0=VFlJAylzj9Xk)e)HF%f}l38TUNF5MI<oxr{?P^vht0doanDgWsQ(eqY=~
zc~ju`!BU<k`G#P`EO0Nyx3dp$;3o7p4)TcZfwroEtTNSF<T7JNG(ak;8tL_L1sI1i
zTgG$Qtb@@XxgESX{i%YLCI$LxveZ{Ow35<4ev9mix_o<Qzlu12;TDy@V2j#6VGH$3
zjbFE!ms&=R`TiO3D5yPVBu9Cs+riJHHu-%?!hG%V_+z)Bp3LsV6HFPcOH2nB@Hg*E
z_-sNA>ztHZAGpuBR#2h0|8u7Lq^erIaiVcTjk#SpghrKlBRB=KFrF{Kd?d4)wtsHq
zxZ%=zUQ>QK9W#e*_JyHX-7LgBVRIWZTf@(}6GH=YOqZT_vy1y#lOEGsQXWgQBtMp9
z^@ZoSwb|*&ONCoCf^sCA!&%c&yR+PiY>wN9^o|T>%h@TInJ;J_IA&Gxl!r}OD!*!d
zqBr5J=>S_qvo<&TpR9@13|2h}o3-oWrFw`%Jy0EdI7}xtFiMF|X|Gg!XLO&E=5d85
zy9XFWeS)0oyRexlHRu~y)*<RIf=ZJb`36S+=D*W#pZ*(NZyHan)3_ba8T|~n+7*aH
zXo}duV>%q&&0wts-p~^xbmBI+JG%Gj+%fQc+$O0PsEourjes`fpz&XfU>wM|k2n}n
zP6+W)X&;pgzPrh0*;XHjI1=zpJ=TJ1V^y$ECS%tkJ^Ge)X!!_YQybNYe;}Te_VR!%
zTj?dvN|YNw@vVd-S|B>0xMLjLXbxCMEbp<jum7F7?)TU}bKqW!i?x}9dgLc#pXDP)
zUw<d(@9(vI)Zfdk7hkrxOjnoZKa%%i&>Tb?1-TJvwA-C#In5)l)W=heyoYl*LZ+?i
ztVi-pR||8?11#!=>PE)LqnB{mD3|n2&kmIMcJG0{6TtH(ezhs3r(B|bwz4-LgvvS)
z{Gi!x1L7Q&odH^#?dB>+U==Xj(hr=Oq1n-I^wcLS(!I0BhC0~k3o3rsA?}JelRKJ1
z$yO7%CH1Ix;+oV4lQKp9Zy2<`gOz$KTCf!RO|y6e`x=Qe-LtQi#zfFVtPLnX+%d*}
zE86c?(D`DwA$*^kb?PLU(O9oobEKm=@M2zla8aH!upW0yUgYzE#S8N4v9FB-KZU!8
zv&Ko|kcyY1?&#SZT$w*!SQEhh4mr$hM7)RQ=NS?Il0#8WeT>oupyqo<%w!`|#^}oi
z6IBx}^*p0&-TmsKRR;+IaYK`hytk%Cjd89%F#dq4Ho?m}W?|>#s*z8<H-8Z5b4`G#
zj>DdVWHv-|w6~|SQ=2UU{guH<bHeeYW6Ab`p4PCfNz}iJHp}oZ?hK5S86F=T2M&{I
z>mx$^ke`kry4Vw7o#+Q}jGYB9HpLUSuyreX$X4R6amV9Ms6Nn~ia*KkQ(&AlUQWe4
zmRzAYt~{phUbSF!T$hBLsU?0xEKk%QBpL!8<uFVmjgizwOvWtqZ#85T%f`oLWjMA3
z<0RgdvSG!?OvXIJav|ErC%SoaPiF99tY2^fea)RrX)p?=ZQMq7YF}dnwZm3or>Y;Y
zaIK)@89i@gN?EiWdNO!_;FxSBo{`2I-(Y$f^(dvXPUxX}rj*k95N?JAG>`m(EzA&K
zOxMWTbsm}H5sV1LZAxk|ZDXfWi&GkmO}qb$uw2k!jHdOd3S1#tb8d37cFrRlj`ADx
z!9QZqMzwIaj_E1OAoTG#8|Z4GBcM4Ee=^}z^Mzr?Xzf^BoS$aDILy1~+1=w&8lTeO
zs!j25_WB_DbtYObZ^w20IuSjMau>Lh#?g5OZbQOm&4&1mjDGLX<Go58>oY_<)JCzf
zi_uSiL+az8GO4ZfFa7xX_q0&&_X+ie%NoqRrfs!u`_75(9b@E660Lo(W0z*DpsIVe
zdd4l!WbKwqOR;{az7_*hO6!|&$)NcIj}JIDp<e8gBw^c3fo0oHL%_&X`oevz%r;rM
z{j~|MA+CNccJHJymY3(}&ChEN-k$mFk{?;M_VNq9Ff*J7_e$ws;MLj`Eph%yuAd6$
zE^`$s|72HFxZiYIc^A1f{wc0_|5O+8d=mU-SE9ezmE@o9;{A8Ibp9ExWdGf+KK_}m
z6#qT0RR6s$n)}oIBYgcfiu%LywL(Aakv>V^D^&4)mSBZsos>IxTYrCTt)3%}$G`ac
zZ+LbwXJPE0b){9v`BE2)JMWm_;!fNF?v{Ross-x|?3|6AOnKaiCtaYN<7)8R9HICV
zFTAEbF}7jIxs}@!{Z+w)mWeLTk%V&aD1i=nPe$JRAnz&2JLN0Y-*0`S@(v5?dEqUA
zVV>j*L(a5@i?DLY$J{@4dwiwNnkCWWNF#ChGq$s~>1{U+djY$mF9$PD_`E%gkCmu@
zb)U!d*a6c{n73NOb6;1?(OUX#=;LI;RTym@TtR;9R9xTZ_<kD=`Zvd|6|~plmt$Z2
z$ULTW(B^^b24E!MF-DOrgZezJ5vZNbw{`QHArG5SpCy>k+BcweO|Cwbdh2`_W9!2&
z7}MCgye_G{IrMg&4xCys|7d7Wh|3Z6JF#kzIFF91KuI8IHMw+^Dyz!##Lhxjc|eYt
zhC(p<6OXSGz-#W7h0&TMIxkG9=Y&?!YKC=H{qlT9?>zRi{G>{~CEaLsB{>orZFyC}
zvOMQ`*UPV;F@0R%(s-vzoU18kEjux<9;Olw8A-Gs8-rtVuqgjL$rFK0<)xhl{f|>Q
zMWiyx0$ISWMDVTALQ`kAsid7HYS=|`UKU*W7)LzDw~mc*k%dgzP{_U_4sA%$BI+lq
zxRcyQMfGmX08+1NGf2G(tqtB-A1jwTz&quvX=kEQmDj()dCv0kgTW}Dar_0=ayRkt
z7n(0%&LN&?n`ZWLYvfVJCbL9rIRU=G)XaMmjILe3Jmb4slmB9S^?CWdaaPu;ZE!W4
zFzcFjnVNe>N+ZS#YD<#;QTcxY_XONiaF<K^&etDLKNi7yoUtqYOFT4|S(+AmWrC%%
zss_3tosO4j_rcm#E$S8}|3bir`G-N@RGqYYCT!LE?U+{|ce9VBTDNr9B%l4MP_{>^
z!(b`OJ>_g`_+dA#{z+~)7bCm{vWcXHNpnylDyMxO{Alc3E6kQ+GlaXOm4IAmZ%g&3
zZiv`YTGq7P*WjxyZV+n|PuzoR0$uBC1#^4cNiOGZJXZzc{4+cTNVh~u!eb7VhuFEV
z2v30H6yGugJf|sM@xYx8rm(kGb25Dh<HXa!i&y(ObRQ(267^x0_ZK$s>s|FMBz9}s
znM-}mQ8``mX5FT79<+wz*cj8!Kiq5%%@clhSXr&z#DHh)3}~y5bT~VFSDVJZH}+_I
z>ZTKU&i0h*C-AJ^q|Iw@KicMOPiR-IjZ`FV;_zGi+Jx#*yK9VV%<jPAF~{<>V>N4?
z?IYXqTSq1&L7@)cSmuf)&o|cDVc0tuJ`6NdTw@%0{HTOr9H@2x)j+VgeM|nDU?>>3
z-U8hkXGc`RQryvZvwmGV`g8*N^leyk(7Fqf?nsPoZ$#UVg4+N$1TIDsJ0RN$VNUHQ
zWA>A*=QjMd4vyq1>*1t+gRx+S*R+djgE-NeIi@51ti_%sJLMzHXjiq7bxeZ<XPSp`
z(A9ES#!rFNx(G7X2{bR-3cdFoF~Mh|hp}6l;D?<~3iUb22@9ol1@=lcipMxBYaa*7
zP+pT>Xy$~hx8W;Mf4|DoG}e=~RgRqyJD6RVhgg2@wsh`x=U_f%?3{4~)^_ZJPY6Rj
z>&~<H8p5gWEdslEi@=Rq(`E>7a)ZC%UY$?R8{9XxSK%q*sA@|aX=t=`)`L4U-n}P~
zlx;w4G$IVb?jr-wd$2003d%>|d8ZtErB$jM94TJ(lA2Tx(}Xp8xCHt=Sxq{mo=jA2
z)1jo~dPX?N(@>Yx7Ss;eaMTt#aMTvmR@7gq-)6yO!ckwPHj0j0sQEH&C^~BO%bq8c
z?UcrtU_y6aTk8g2$<64ubkLej?BpG;U7USEKnp1}(X+NaHjYs`YthcXD@mH4cszl4
z-wS1nn=g#DGF{qNG$%>!8Gp+3p=M+J=81J_#-chAqt|_P+bWf48`_yJZTfMYik}4^
zj6n8e$>)hWl)h=6F#7OPL1r_ACmt|dW^g}uV8#*U$#~E5t#O;w>s6aE@(<?xkap^4
z?>R0cZBAU50Gd^SW~pw7_6!EyH5r&;+nx3aLQZhhV-W{$o$r2XM1j}0YngkLy`+i9
z%CRbFZE|5P_w-nq!^~$wvXbeT$m<>}va(x^xg^u*Yn0)dKPS#Q=qihKJ0zo*AZ6lH
z=EPZIKC&*xR@}y1G3I5X3~Bsu>>L@Jx^kFTZhhAA`~i+<9mQu~2#E(EQNxHv8Ww{a
z4Ejsh^$Y}kMC_5NjzA(}T!)=`cFtaC1ocBqH((dNN`*D9Z4lr8u?(wmv~hIR1^IC1
z5>qDQF=myyI+fUQkZhkgq?{wc^M!NS=Y7H5NU2bO?*;zou}{*OUQ%JK#n88BV(+&A
zdwA0QqPaUZrmy$(Kbi5t0zrhfM-}a@9Y6Por^Q`^y87B)4CEUh?$Tl9GpH+VabIjp
z#@DQF_`+#A$U?5S3M(ILm%5yF48PQ`LMQDQlzv?`Rv`M)ec~?Gc9DM;^c`no%N)?9
zlVSBr`}U_j(oV36Df5N(+0hm434VFa<BgB+PdxE>gXthS)`8kPx}<T-(alH2|5ywk
z#z{0vW!JUnsuMT9e%9z_Y_s^g&njw@oGWYV+YS^m=(Q;y96wuAD}zKhA?uNb)>`(i
z)`M#W-mk-q`<OcEWYR`mHNSpdgSPZN!MB60*pYu@X(;r*aQxhRg80rX%pRUGq4q@l
zdh)#MV9JKQ!b@jY?8pgKU6kEa-00eE-tYPkw*04Kn%j>FvXSP-Q@f}A^3<<?Hij)H
zA9m!2Z%l6d@aT*A*n5R!IRy<&y{Um|mP=CU#0`HmFAwa1F4j819J&+pOm^P5MspBz
z<Dnb#%)znw<`C^eZ}Z-9vv}aPyrHAbLGy)tP|Vo<Yc5#cab6g+zx5qMc+4SXwqkg!
zJ{TuS)8xjBS9ynwr<saoDW-G?`q?bEESsn^4y)*X;A9#xOMKycyDO<&*)qUu2yd)W
z`G;TXTM>7{5WW{&O|>5y0d9>y71ww__WEw3DXl*`hOuS+*E3BS63>XS^`1Xs`~~Wd
zL|?QIp}ofz+<yT_^8?Kd)Mu-4r#WRK+*-Iza5Q(s_-sih4fT+sfbTQ?f`0fEj|}^~
zLi9~XKqvA0CxW+kH{^_*gSpZVdsc0?T;OgOYaHzpUt_uyi{%!ktMB4G>yJE>c19}W
zpqnwaT<c7#egxbuD}S>zo6Iwgm2`>*VLz6Sy4X}RUntDgWEFt+93kRHiU;Hpry!0u
zIh@@-GD&;I5Vkf&97}}(=DoW{@JtuGI0vh8jEwfI2GdS6^jj7k9)$Ye?@k;dlenA;
z#N-HcO(QKBLl`_ba1b@%eK-RgB;ce674>&PyJ9c2D+Wue3TP7|cD21cq|8x!?%9bw
zMSwLv?~8Kmh*uR?5?hZ?m>iuKNcV#3*?{{F=rcz5d;dBCJY+o|7u)4ArLlQ>w8ylZ
zxgw5cu4InB5q!+a1?*JjiYbq|Qj({;hqdyy*c)@t69UbaR1)~*GFQgu%4RAoMyylC
z&c1F9pEPrjm$TBF)-C7hu5l+LCW{nSHB)IV8vi?rU3w?Y7yB8!NqUBiKGBbrzGE6j
zkbNiF^4q1lPqJwPMY+X6)NKX*#+Ebsk;feuIgbH)Ke7FQ2Kt`FH%Y)fRxZ^ES7$$I
z#9*9gE2%zBP6M@48PmlqbnP5*0c-L0oObatSFDw0y=Tp0C+G^JjLDe>eHo?0wKEnX
zIx8~Z{`}$CG>1_TvCdXu1S=V=>E`@sW_Ma64%K?mUUk79%n4eW?nIbqF0poo4&O6q
zlb^!H@|fnO+~^#pmtP3U!c4g~fN&0QGW1JYY9VVY8N9&3I4vmik`~Gry=y%2UdB-?
zSWX)-lPzgEC{QZe?sO=X=pK#q6&Yrl#P8_e(Aqh<wzcz-TGE(XD$F=Qlr%Iu%~S7=
zRQ!5ksN>FuQY=T7GqZG-_uYS}2z4af_^vzDp}Fyp+wf4F#o1KeRME7kN$h<6U_8&*
zRURka%fW}58xMXz)(=w-M7bhNDYZig{W(@frYuX~a;JPIX;eKn+%hoCpvP&$3|0dL
zrV03k$|dg9^Bnx*QG-=MlTCmYc=T6Ch;_#C3EA`(aZLFPdZwU|B`v<4GKt@IJiUhw
zh}I+JRUNDpqK60DYwd#EXfJ5nwH=z1@gEF!97ioLX<?k2&8*`fo<|-Z?~K3pJi!_D
z-FLFUX{ac^2;T9<XsCi~zf5xS*Znf-+Aoux+5j{L?X2UB;OPEtvQv(kTZ1u713ii_
zpn(&=esGw0Z;2Jk<22f;{5`828cU^mJjU3l)kJ+>JjZ=1?A_51b^d%!_K+24pnqC}
z9mXi;ihNX(QS6*nL-GmS59mO_)7*2~XxAv}ztkj$u(R)6>IOHq6P%k7tR45JIQad-
zy|s<aIp4<UKRKQpimm*jZ5i9YYWFcOu|-M4ME!roV~yh2C#d%`6%vQ+SnFjKY8-3b
zmwNV;q{scrO+9?EQXxxVoP!-o)H2_~wNTBP-lx7k-pN(7jtNfF5qg8~dp)r*rLpum
zVTdpoy+Qi=1L^DcC_J@9<SJ8P{#wgCBeg^{4Qjt2G#*&na_IXMUqruyz5}&4eg6z%
zrIfj9(~;h3ca@~iPdlD^414$TstZx7GCAg;C-N<<llrbUFxNr;d<*Z_29o^zdhs$-
zKF3kqO@rEwq-uHjT!-`8JM|f8FrXxf(32tROY~bBMEyqi#tkNZ@;ZUB%Z2emKGu;$
zZ4&iKqao=KP-zEM925$WDvgBE5r`@4DFq9TwkEUZox{5=4_r;GqKR`I;~AjUW}mZy
zJ8UaxNX8t$F<#fgZ=%vILFtk<&Fy~Da)xlSLe$@&O;9GU*HtHFzapHj|L1z-!y!(u
z>VV$&Ls6aYD(HMCTB(&(mzeToKgFa&OTQ3$OW1N$SDn0m{P3@T%T)Ay{X0R9)#bo_
zai?VH9m_fgN<Bl>qLBKA(ofR8#Pv%B;#0@@XYV53waWj%u4SEr%7<UlSE&7Sc2O_V
z_*r|Rr}Qv!PTvw<+C3px>n%Pj9?@d1dTO`j@KRy+uJp}m>r%0s(3TtoX5ckA>Tkr;
z-42%mmjQRBq|f~1<2v-f<%JXSGz#bW4f!jNtUeN5+so&4Sw;OMEekz%C)V)v3`zgh
zL6s^?VV*4yoQ3A8xp!i;o!iXX7kopAw}dB;MnlXy`l;}fJp=Y^*>mfj^s}^=kLu!&
zfG&P?#!POX4V}~b&Le)Cxm`DJHZ;S41NnwjpXyHaq2@1zt#3T@##_RhyCb$w1x_%x
zeX_?9$SzGNjX(doP+t14zh$lvC*i=@4?AM%-1<gQ=}uw58~^?pbEWlW=E~Wd?<&0@
zL|XAC<te#?^6|iLDIagPn>%z5CAW{n7jL#-fd1KA|7E_Ywj8*qwyFfhxf@2mAeb*K
zJFDb%58q)Kf_Lo3&nALK;zm)wF}EQWP$&b6Azz{yXNLwfr;%tbUTGNpsh}D)Y&50T
zxF_Ml2YbvHME#rb>jWB0c@H%4{a*_Ay+ITc=b!b)+u>x1YNDfQpUuhZbZBKw$pC@r
zWNi1nhke6){6bw>OFFePwRx16$l6ri2}e|WA;b6(dt&{&TH4o{KJ4KQ5^Y$v)4aNS
zj0?{(9mtgH<Oj+7Oxq)s=~hS>$}C%X&wTK;wZZsIj!SGz+Ar$UwMxHoJ+vj?E<239
zA~+SMgoTHD>s*pdf#RpN9i<tg#n@OVwSR~^k=;0=VZ{ENU%EaqY#XsR$7{Zj<2f1#
zK~Eej9IPfrb{vIPy*YS;hbc3I2ednA`DB$TVpkJdLmIUdEnNQK#&zdS&5CNa$k8@%
z_C;&Dx1T3{f1k$m24|odaYZf<vgZV=AWchZ=;NjM`gqLHWun+<H8jvsm^(d}2mfNJ
zuxh;8Y^eu^;c)M9lws6NbUnhbF+2ru6kn23Dd8#VQN}j7*WjY_-6YQ>Z{_Jp-X(Ag
z;T&)kaF4)Q;GTec8g4Q$Pm`lp$SnVI9rm#v!&h|JbD_hY>xIm^X4Ht$-k;Z`WxZIF
zk`-U`vzpgy-mPIqEo)s}^GJ<rjBl*DZR7bTf4dgkMxsu0$66tUXPi2$>xib+7){Ht
zej~bKN;!^^#?*AJLOD-Zy;IcN5-=+eAK-95)PD@u&=<Idp7}V(4(!uFUTh!0i=V<3
z7<e%O?_bjU2wrT&`zyEd;zYc64Fa!dDDYZ@^TC>obmK|RPHVFmMuK#DiN<1UwOI{B
z6@yO>EWfYezQ$R<oaJ?WV%nBn`aW@+ffKs1^d8SW`-clhCHflKarZu=wVXhd%I*SH
zL}`q1Or8KLn>u;_v{FZ4YU4_9;3w{L?JDpdZ5!EU${qhpQ?8?}xXo6YSbCc$)HZJa
z?zTG{nbXZ}^=)fP9c{aW-EFLSr%)dnIF~v7ku`VkYGEXHWksd03kf06V_AJ$D3lNq
zPiuwdkT#UNcPI3YcjKKoEp9C<{S8nIIi=BW5<+Sr7P=mx>qGGfOWzJ{7`hi|htte!
zIi=#(`nEw`OmTfE1zZG_7JNSX{&gwd-f2bC=?h+R-@QF)3>QM7k%+UZqe`giaC9Ve
z_)hn%OBX>;J4*j*Ac^q5oAyEf5F*lRv=1;$2D}C`vA)1CgPG{qMEi117?d5ABlhVf
zWz|XCP#vVKx?a9o$u|MMtRoJbhNuLV(J#7nE#$B<S;tV&!Z%?hV&e?6a8a4oW3sOm
zz@^mdvN;7|0o0!1XV@v0rsz5%;Q@17yS1mc_W?ciUjLgUoe|C`>X}5Q^fCVSZW_xi
z7xgRQBkF&Qm5-+U7HEzPKFK&Uq}3JnY~VBI1Qhlr>^I@(9KDx%k)vaVtB-L&cbG%2
z)=r&0CqO&WL3T&Sv9b6?nn8*?6#UTclr%``H;^KUdNcSUgMme}0EtF;v{m1OMI-!K
z30w@1=D_o}W6>D>^DQK+!aml~)ArQor1l35P`%8>o%*9x$H&qnX)*MqB>oudFadv>
z0v!SDu=V%mtPBv^A;YF{%m(N73#Z|#rko9HD@b0V0V0O6X}r*K?&iLs4KU9U-hlWo
zqmTw+U<!bl?3v?|y3<SP=Er?CJ)oSB-t1tU#3xoFjTp7`j&m^LB)aSiZGyhw@{z8?
zP#{Z0@cXJzmNZYnPO;0BD}G)G-Kf4slcWI=an=X=;Mpum{ys(9V?_#ylsV{X<}yY7
z@8Lt7Uec?8u0S^~hja|8P##L3bRkya9_<s+z918Hkeo9P(gu(jfeYEn*b^`-BzTtt
z$7~`bAhe+C17iLf(h<<#Hxk-Ik{l^kGN#l8n!Tl*N1ZW^G1|A(Mr`V-vx5UAsoc7q
zkMArA-DJ%`AIljb-&(r0pNHu@=H^CG{4!g8TXSHPz-14fa7$bAh58H72658b{nA@p
z3s>C-T05@rYPTyq#Z7qP@fS2!?8V$N)D|@1@*Ztv^ua^eQT4)%m`3YF($h&96&=3`
zKgWQnBQqEnt$}9}4Nzt<V7R~^4ImguzLYV{>}VKx8VE(l%+N8PGs(;!%iuGEW%wit
zV=^d<3Jr?k6AVnzB*RLk2w|rhnBSRkpKdTQGYovyOaqe)jgC>X4a|%=2441%ff+_|
zCrWv+_!x_Z@*>?SEy@GZ;Io)GhOsPQvhX7P;TeB?1~XVBfBH*gwl5!yxd(R{+|R~h
z;KN<BNSr(|lbI#!!#vORVOm-GZ6vb{=#w*7jEuOP!sHuttz!)zKXIF(z>#LSan3D<
z)xHVFQI;Ds@1B^F`PlziEdH);oFR1)%FZy4Gmp>u%HQXoU%9GK#;Mfl`o4V;<nzxN
zMtY#|-G9E=9S;R~9?z|QdW4B#who@Yv-_vN=`FejS^_;CVC=i`_=~Z=isJ5B>;-|s
zhur8f_;tGje@lEmagBaBIv@L?Z@}e8G5A!5a{L~}>VF-VzsS1?zshZ`VW+D%LZ3LM
zF=W0k`~*<+&VVocRJYxL7&_k>m=8Q@VV*Diq;Ed1Px+vI>LRQ@Sr8zEz6tRVM+I7|
z&@z75CzIaq#rs3Pd%gD}?R&lVL00jE+;N&P`S+l{A-8kQ#C@h0*V8k-@H>4^_ci)O
z>^sZp`|vegXW`nje&Z%zkICPDOB9p;48}AOj^ueHqp3@b;`4_CBTx8z42u#z{{r3#
zpFb}R_;=jT^HF^M?FmtQ{+Ec4@cC?J6rWG{N5bddj&&j7^M^zKkMQ{uaVLEKOThKV
z@cA24qWJtLlcV_jA)}-C{M`sk`25nFqxgIpe-9-^@%c;RcyR)FuFoM1;q#9pKZMW!
zG9TY)Q5J^LzmN537v#mx!MvESi0ZWw-@g;z5I+AcZ4{s19v{W$e+hrW=O-X;!sidb
zo$&c1aVLEKKf?yWCrInh!Rb@F+fi?ZABfYZ`R5-v{eR%}|5Tj*hm)c>{r7PH1ded}
zVcc8cy5K;6*WvVIGXB37PM_#J0Xv4jB~G8xpcTgaKNF`<@<5Ca--**_pS&KYPw%~P
z`t;r#r%&(Shtt0<UCgi(zJk+__sWQWXS2L)ZYR!7RnQz%X97jkuJjO=>&JD)b<@t?
ze~8+U_RfUgxW*$~cmtm^_M<b*FBa@b_Z-+`+PXr3mR^M^kl2z~O(>#1;QT9Fu<Dk0
zRRyl)m;00(FDszYSm<J>sQu%i%{T$tj1yf^$*an<Xlu!Zli<=WI^Dy`qP_j^h?e@`
zPI?)nm0@oV4%i?51+*0&9%TvL{N-<5zbX0k%6Dh{qVHZKbSBxUGyXHqraXcD!ZA}F
z>sWr7E06OR)FI_Mq+5q{>yU08b{Ue)mql(B(7}g}H}bmtvZ5EZinT#T(XEFe<pFu2
zaW$q_z~~#sVFip`TEjRQR>8PBNPg8Y&M2s)dx~FxtX)<iG=@4R4TY4%!IJzdbTo9w
z)j`vnLt^>S(6iIo=|@A6E_&BqqUTQhwiJ8#4M*O+N?hffP+=$eZ#yEt!r*<&5e5i)
zdoX2_IY{~>#lbj)Bb<=s*Dr+R_T~_NU&ys6>?1?UmJDctWeJLtaV;w7Qheb&dr4hB
z8xr(E(9mPUY*~DpHe|ZW6lp`gPPPbqhps_*Mox;>w8eE%`sR=ca+zs?lp~Pyl_dmj
z3G0ir0q!claPE;?j-*s0bxHc$i99(1{KAm|qktTcUP&m|?hFk;&cyd_Xt-goX`421
z!`=jN>xMSK&H~aVpY{Mm`H)+L;7`0x?rOqR#YyD{aefu#fnPY~msQs|olNOGp@DST
z%CNuD`^IV8mkMw0qBfxCPlaFYA<Zv(-Y1Z>(>IQjYR2^jwFvq5Nc5YBMd@oU=sObm
zJ=XOyW(J;V-}Se$VL@wN#-0cMSKeQRlQ;NloV<bH<PH2zYZU1i4`S9RQl%YmDt5ro
zhPdX-OTIeE8io2gYZM9BS)*V|X)PDyyOB&j#%K9G)?{Rp;w|v)2n!bDA^%UXJ3-@b
zbno&HyA#*!SU~6g?`d~}_8clWvOAH8d*tE2-0sAi81G~HI(JCgG>Ipos5mG8Bg_~I
zBV8kvtgXb#l->Fl;N(U$lHH3QoZK*p8w1_XKMN<<SJH|4ew-Y1r?11wF}B3&Z^FsZ
zoJV`NZ^O&|5DXjbF=%|f9!J)LGyCS>dvqM=_ZaW$?}am?H6h{5hA6)YXO_rG+DF}d
zJu2(><IL!rABHnK{{wMmRByyv?B*%{ufUm6d1-E<vQwLV9cO0rv`RR$d8mIDtCvB<
zZvy(va(Ez6X9EeJ3)I=b??s)ZOQ^FH@QG;_?LnROkx*x6x&~nV@@=TIsQyWeHxkP$
z^*LILnBa&vOzU83yC^ppvfDoqf3~nsk8TS0{}6u`<@*zw;)cBgjW=NQEOUdK3M+Wm
zqp(@~U=Qh5L(T&2%|X!KRQhQpF6$atUU*4YF@zWOA;>dKF4z^Yq(Z;E2wH{H0w!N7
zX|+3E46-9gYV%GLWD?MY=!r{vEiPkMKg5+>K`VaffnSp!P@R*GIn_1Q?@I7^z8RP9
z3MY2s(hZO(bOC+t3M;b3EsSKzDlPLNa45+>%slLS@@z`~T+9n3r#D{Bz<wf4N;wX?
zCs#QjBWbSz^v_>{W}ig$iBk7Qvlm{&tA7)k{kChr_Mq7z1^!Mn`;GYh+tBPcd=1TR
zq~3z|?m@GYW-VL!r=r;tQFo>-F*N&`tMczfvlB0o+D)3DFdkD|#&GT3<J`8%Hf?}6
z_9uMB;eN=WCd<;)*HaD&4&*43eYC3_<A4?<5Y-VoZ0Z0{T@@hQw4<$$fw2RTe7FZs
zt%X0NF1_&7u*erhwsw#Alqbp$FN=;lGzL+gJ}*g~pK`p<u@X<(iN2>Oee7WtQXUjS
z^99(tu|9;_T56n!Yozi?3%A%{wbUsdONCbNy%YHsnS-z9PTViqnUXo&ms3E|N!RRK
z&GanW`XE2gHt`S#$$PvE`hK<-__X!1%51Bl&RVy;?x3rtj&DgiktiV<5<W=Ukhn2n
z6JM>Y;7%3%QgKRkLVZ&6LE$C7qUo}xT+%UVQA*lK@&4O9E1-iZA@TJ8JeVmxo}RW|
z0rcB<#jLDAeou|K7Bj`zbU7Wl=Ai)?C&}{S{aKz>-7&wKZUn}e>VCL{B88?|wbl=m
zdyPZFk@mmV4rzQ};7I#^2ac3>^SyDT+6`$N`fdh?Lc)>4YQ?%f*wx3EP#a0K(@jTz
z0KXwNPttr5+YA0ZaHT}Q*JDZv!$&AZ$PBU8mi8aLu!uKWGoV8bJYu&N`B3AxArt#t
zhfG``M~pnQyd1reiJD%>L<;d$WMWkJmh`VFAAe1p@oT8}<Ity!_TL!pG3z?qqro!B
zm<(zWF=I#V)uxXi9Ax6xaFFrei-W8k8N~uFK)TUA-QNxiS*!g22Md{n@_ri@GFlJB
zW6_5Gr(>(gRt;gRVm!Tn;6Ia3!S2};|6A~%qtO1jaD?Hx0q)!IpF}5w<sl3YVR>TX
z@82K)xnKGJ2mUiN?$5!066TZU5o(7VIBE-$6H!~l@SikRkq#GOLSy*P7(em9KNd0*
zXr&*9h5YPF(htHy(i%C24dG8@)=sFEJ)rT6Va_6(BZgVa{lJAC11`=jsBKm4u;MbN
zIUp<F9XQglPpE1q-B?4IbO`p=>>O3q2Hg2&Q?0Dh?CEb6FE6jvXYqqMAQ4lu4B_K7
zBIE@}Lx%9W0}4FV<7w>y73_WPt9ce-$iFYIA8ZE_6BzjHanef7pjSV|I1Ks<ti%bU
zwzfur9iD0wR^w92DOmZ~xp*Ky4N3}UP_mBr^|3fcT#ExJP4LuTazkUnO;&565rO9i
z-Gm5V6J(%W?hJ@_=$zSAlI<-<zkF~FPzWraZ0Fajn7x9y6Klk-_?GzUc|xMY00c9w
z8b>bV%4v5;QZ3DTIaadPE6Va^T?4wYEI_wZb0Z9T<tU~!zB-C)881ZfyQJ4-Dvs_4
zIPi^$AHl#;o5bdv9TGkjyIC9ALc_|{UITp!(`(OmrB@m(&vxnUB>|0P`?Tr7dozJm
zt;{B@YUQn#0lH_qGAh#%VgN#Lxc7$@!({jlsO0fBs8VNvDuMn~;#vVBG<^kZWI+`{
zKNENIe-QrIs_2_>m+Qv6ehRxi!0cfk{)Ka;ckt&Num=4qVtRLst&<n8VO@RULEXA_
zKY{)TxKR?;H8nembv@1(x_;d7<Hkfk&d6vYC+*prA8(l5Y&v>>^Ah;<AUhMQ7q%7x
zseT{-XzP$D&h>&}^qLDR#;2TE*BZmQmUZJ?*9kg551i|7m4tKUt99!i-k(_db(HG^
zUqiX>6JBavu>+QMfpWbIDA(!NP_D;;a=i;E*Xh?#uE!;m>(pK-*9i@V`tc2hX8AO%
zm4gz>HTWu!-fqFsUfAF|I5q!{{SHw0rgx_2J3_O@INE`ye`j37L!(>==j2byb%Y#&
zn}G$q^_RN?;=5}CxBQZM7dD>WQNn_APhH$3QF9N<mF8lgz$K2ZEIX$g<vIYojUf`s
zb=l_{pj-{#h;k*4qQ+0xcz*`2QHiIhr;!>c*Nu?QAIjKddZ#za706N`o83TOf1XZz
zAmVe<+(-0Edn4K}ZNuFSNAn@gg*1L|#+~NSm*5EZx)rWB-j&f4Hq+>RQQG6lD#utW
zY6k5iZkDQLzF^v(ojt(AZM|U_EIsX1ZNl2q$(rj!3!HCuXq@8V<c@#oU`N8DaQljO
z?1&GOCAO=ax`leBj%3ZpOxtOPxgC<i9)63unlvC+2%vEA_qx%fz>>!HeKfzscnGoi
z{2w^cf8a#_e4MCE^G!I>F#1A_zW#v|{XU%N_Ao0+`=i{a-Z)VjgQ9!W7*6yf^`DCq
ztx^BAaH4B8e+o{N^a;n{?4OwI>K`~!!Z~O=M7<34_jR1;kKp_F#fkn%^W8YnqniKM
zI8pXeg48p<A1BIQO8g6OqH`zmq6v=r8w0wngNtGFuIYe%2TnAk>A{JHG~b64y*|WW
z2Pb-coUaJ~Q*fe3HQ$C4eMs|dIMKn~=we#^sr)_KbzjGcQae+dM|rPb#fduOzY8Z?
zi*I9l@*jp1eM|FIoak@kug8fJPnhB-Jw&3%7%j%eQmhtjK->I}!HMog8AEXOaMAhh
zzdKI!A<ehrM4iCJ#c-l;X<|509_UfopMVn`0E||n9#{gn+wpu7cRJVaJOsxBaIW7N
z=;*ftM?kuyo&CR#6Q#9TOjq{XaH2#1ffN0!;zT)&G2e$1r9KeDiN^Xu4^Ff%WL=yP
zlXVRN63^t0p+;eY?wW2y@^_#{6TcHRN@LA1<l&q28DrzlpNkvqy&o8V4L7<26#oQo
z>PB<kRxavq1Xfzq55P)DQ~smx!HwqsVBF~N?vzwW=_Sbcz!!p^MOHU%lu)Ba=XalB
zxT7h0b|GO$=^Vo!fE#VN%}F@eS>-(l(x`oOqK#IpJ*bYla3_9QRF~w3VMr}k2mDDG
zQsQaEFr<Bf>*<;Q{(KB+?>K)C3=z$ze+h>4XP|@YF{C@-^UWC2wI~mzPZ(0tJ&4h2
z{K+gqtpBI3l(HAw^uwZBM6k`ai-mRaJG{)1D02FCXhsmqRWORLGtNWcea1P?3l>=C
zidh>QX&vJsYhzruwXvCeuA~`xw{i3}J7YIpvoof?W@l_|x0Nwvx0SKA2ckB{9__X;
z_S&xDl7+F6*1?j6F+;b7v9iM%;C=0PCwzm2G1zy4eKGY{?2FAfK-R_R?6$#XvSvj!
z6))LD>&BfzQ$tZgddtN7Azsjg$=_~M3^v)pqrzPDSH|B)*H|Xl^^Kj=_ZG0*rq|Fy
zm5fbk#T`7Z`M?U}6xJA$T{_>=c`goT2*owBQ&lsQL;KE&A9n#a0ZU<R(1R*10*{%8
zD}!TjG9~#&pL@=Q?D=hJlLO&sjX`Uus=zD4-3JSEXC7p1_Z(D{1ykr-mDJn|zeNY{
zJIE<uxdhyBC3-Dc;G#Mt9vYR!pl=7CQq+IIlO|ms=#0~8X+?QD*z~3R^4I6rMmFM2
z2VMwiz2e7O@4N%RxxwN^g4YT+A8r8<*`()i%TqeBcbT-vFXj17VC+VY=S3FoBiJ^%
z02iZmOPy(lQYb~bRe_X-Dd$Y?^TP51)7u3*+>?~$1#fdLq;0D>RpeS#@T#fk?e|<V
zP)h%Cvf?7w#Lo<{ay;ejA{SS!*sPgaeAe=AZ@jWAq7XkUxoiIP<HfL-GzvD*UJ(r8
z1qWsJiMU%1GG!W^Ak-wN6rz4Z;#B|C^{^jcceG`;spXfg<AuTCgmeCPE)A%FZFk4d
zovuz@x$^i_Ngqbxp9;ByA?$P0xq~AY)(CfPp1!Uax+=p;V&l^M+FBvmHt<2UC9YxV
z!KON#)H{^&E-%K3v{H>RrBpw$wYYqO$@Q~RhY+!q!x9?w)DEy^^Sp9O`I4;sol9xp
z?{mj!Z=i&Hh2${zqrc5?1K(kcN@UdhJ)UW9GjKp+IMqO5u)DLZ<!fsvx#qhPO6vvL
zyiC_YS6i(O=eNi$mb@aN7^i5m4=%O%az_S0Sqou9F3iqZVi_NN%qn~MQOhoTQ*LRh
zWfrPnQz_q-m7i*Uv7_`x)_H3~{Y69gMD4koZz`1o6OvHceDQtZ=*3;adqQ*jYh#?H
z3h4ykBk)t><f-P1_0lgL)Ax>PzPS6M0l)6P$UO+V$p=~M)6Lu*nKjEh_efU5t0t-^
zW%;WnV}r6d`pgf;X`W4wxeT7vB16Mo0eVviV`&=LFs7BBAO(O0eMm3Lcn{TC>m^>Q
zGwzsDsxyT@UaBo~n|xTbW};G{iuB}O)=5e3L+wYhAR2F0f?qxkbUguX8r)PkGn@lX
z8W%9vlZF0RdlJpZXgg8jnR6$Ym$+&b|H78)v!*NTT+VWXNxNnEl&cuo=?nt7LDVPf
zdY=+dg}7t#rWt!pTl$^of0CV=@j(Jks@N+O$84P8EV*k|&bE-|8B;oGbiehcu#!`j
zTii*Q8|ZAH2?zRBn{dAE99VFm_lXDkZKV2=73<_H1Rk`1mQQJs2`SaXjMKJG`wV%U
zGti<2<>!%>A8=tm2fY=zm`h2hPd(18ne0-*Uc4HJuqZNYJnY;Tx)LP~v;@D2=QoIY
zPPb3E3B3!40OLs}7(CixGQ`AO>W^5`E4X7Z>#)OkHKbU*Q!-qVBMfYSeospMHum3?
zvECF|E0By~Pa<T3`e{k)gdWroQ%Ymf?=jv`o5s$pxD6}NETPZIln=^qb_R!%(piBw
zdvMOg8I9lMPWVjjz{xx{KX+Pyzf$=}d(>xef|mQYm$(Y8)ce(b%?53?sdj!%{05wx
zUF!&p&&JqcgKgf~r>sK}|7c^u_B)-c3e4?U&`M@8W_3OBMe!)3Y$`Ngc|*gJGmoBg
z)rqxxLIWF@oOjjLhm1L_B&|w^jqDY{4yzosqVp<GC|WFTqUX4l0=IZ6zWleB7)eJJ
z{DF=9e%Nk9iBlvCsH}8uNzWM>F<SmM`W<eHu6IQJzN8oh6HR~h9ka_;MYg(|(v^Ia
z)~K#0<;UorXqM_a#yc;l8!FscZtnPEI%=iky@Q+(XI4o)nZ|Ej$FkQkcKdo(l+igh
zVo%&#AAAcZ(j*Uov=?<2Dc2f5b%}24q!)v6BbFC3`mN(&Yq;C8{k7Rv8b@Pk6W?CL
zt8(MX3h35-h-d4#xbiq7TZEJF+=XqItSr!MGkRI?kIuz3*T(v8WFf~?T~L-&PgyI>
z6UM@#*>K2WnVF0|*^2qE=I7&=2h^7M#-iNS`BToXJMY`-+U7d#`y?_=L8Fj8Iuns>
zne3lX+%z{*IctR#wW9tuo-3wuC^jeCr$LJ~dfv*l^zFKRRY7q(u#<CBElHl$`8dgS
zo3cDQAFhR6z_p<E;rt^$W+rASi)lMM)$}%N>plN{J<U1am}YGLp)xOkt?IQxwA{)T
zCFZzjI*&KqCE3u=3G`S6i?$i&GGXOJ)1e&H)$`*Rr@>a_(|8I#WNlM?Q+?BXW*@Cr
zCVYrfacz@6ERt-OMbAi5p*~`1XG(g$Bva>%gV9QKx`bh$=_Pim(tlI72#Ro<w&ue!
z4{r|LU@UN<Z<);PUliliR<o$r^XB#pqjEh18;~jc&!NTXloUnws!Mw8UC0V#QlqGU
zjt2tNt~P2Lp|?<nQvsi%^$!c{q0ur?TPe|2F_|Nc<*Bzr*Bo;|tX&=vU_Avjzlk4$
zHc(`*753q6U($hImQubNc3)EOu$%baVO1VAEQzVTPr_j%b((RgyuNVNX%T0K7vK!<
z4d_$vQNMy4^)&VixX0qpk}v}CCw1O40`qb*sB@p7Dpz2|v~?VJN>R;iR%FMoA0@;Y
zEvFT{K(o%Y_F>FIns-(SclXLMQ%dnlYfGR<&7rji>I1L_#_i~)gu4%L9L*E3kSDDs
zdu;VaaSB5O%a#!zD>JKJj%yS@6kn<O7^l@svs+IOkEYR0GgznNMC&b@%o?Hj71_`o
z!XMIoA1e1R`$g5K*8hxt+0(ZvZ`XepOKBNWvUaER_3$uJp*QHTr+_WIFS4T})%9^P
zr7AD`GH0mTvg~7=F8*OO<r%%~QN`*77X6N4SEkR?sZYuT-nblfO=E+qT)m!l9n(I9
zO{<ryK3tAAnP*@=?mfCt9RGdn<ZSA(lk<aZ<T#bzWhZ9@<JaXd;h{G&YSY(k=DhHY
zHgm=nr0H)d$j!g4VC*g93hur4S9t$7y!-Ipg!hAZe+TdH;r%e)=eIKV%HaOmwswx0
zU{5G}I`jAXljgQ#&tWEh&ih=q{hgISvaIwz2mK@X;mX)?ZHhiW=lv;se%gIqh38e?
z=yf%oS9_z^=kff!H+uaUo`2?zUSGiT3*P9p3eT<KiLTc00+&iU;q062?yQik+q8x!
z_*%oIl1-cWc?gHM$-brDXAs9T-B;M)KmDvXdWDYCX~J@S)lc-&FQRuDuFIsW99m|s
z@GPI)<_h1BSc_qm%opC`>ao2;R;+yCtu8TN%rAyM*@HNHg!~?BSQ9ABhpw4#Ij&n_
zcjup6*W2A$gT3^OgNE=gy6x`J`@ML7$XAN`EX5fboMTP9t7*G?P5aUI?M>Fkf;uP8
zNh>&HX|UjQ0z>#7e7PQ$f7ZYvr6D}iSC|VwpQ!&r0X{)^zH2t(AzMB7<9@#v*VFfV
z;dgp=_w@lhKj4jC=iqscH+p>#&kuT|SDZj|dah?KcHVPga}wh!_L^LYtMGdJJr`iJ
z<_Tb<-p87kfj$t~?zs=V_KZZGxCVCK$ac?17#Pn%H>en4$ac><@ZQOG&js+@oAG;N
zYSebm?_u+YZ1>!q6Sdug1KB0pJqp-$v>@DIWz=@h?YK*}dtmdYmC}R_jR(NTKY=)x
z!tUcIu=g_(Hg{Izw>pF++dUU<jN0xY{iAtE{{+G;iHq9qS&A?|ggJ@)knNs@$al<k
z59u<A;4|KVz1cF9BZTir=2Q<i1nXHJ%6<XglO3NiD912-UkW=y&A5LKf3oAFKssc{
zClz<H<1++zvg5N)7q#QF6m@tE@tgqPqE5|=Yv2^%oIQ&39b}m}3&KX$dZOo2{y8>(
zD6iX5Hx!Eod(y@3H0;%+6Ul06MQA!0L)>yRae|ZG(1tw*%1q__-(mA7H);<N*Og5?
zuFo~4<NDL4(YUT^ipO<z(=6CGwsbz<^c3D=Ty3(B_}!dss&lH#h)wCO3Yc>7?_&#D
z<U^Zc4PHvJjtJqsaPnPMAigoaLA&3SyE_!$Xv%F46+=tb8B#ZDyyB--L3KkFY|a)3
z!MFPqG!JukWIGlo7QynI6c21_!UWwPl{gttBn%*~OPl1l+M8ne!2LSAJ9J*fShzpM
z?oJWHErK(&u{NR@($iHKP1|&mZ4c8Y6gSaY0@l-iOS?Oi#$RH0XOHy#ciY`b!&+Qs
z@8OHmdvCit^xoU<4!wV$-JR>w#mxHGu)EWGC0!aFVrz6$ZBp3+Sh$uiij>c>C>G7O
z#Lb>%8MO}@+S^qQ)>a>ynZ?0!_L=dfnw%kX#;|y9ZYRy@HS%`_L#4^Gz0>lNc??&+
z`|M9^nnSnbK>vF?kF(t6S@{O#qFl>6HJoEY?$OXs53DNe=h@zA+Dg=0X>L5T{S|}$
zGX?Zq`B=Qmg?F)kp|};N43)$+<*nEYZRf#HmK(K*Ph)XGyZl|@U&a{pzfo4T%XkJ{
zh3of~#2bt0sAowh(T5I3d(8IjcRFxNCaloNCYalBwi_&Q%Z9K;<~GumjW{Rda#QOA
z>NE9$@j;EhpM`iY+2FmnwkO%*PSgjK(Ag&4&>>+pbheW!)GhJIZ2@#4;;SPLM@Vxb
zmv0JLw(BgUP1+w{5|=CP1Te^sAz>Z9;lUdz0KaM=Prnr9_MsE&wsOXGLh5IxKp*8>
zf+=jSOEM;6++8H~7&Yv`hS+riPWH5}!<zodKc;@BS>JQw0aIFwxnKk4S>j_;*=a9A
zBL+@WhCD7y##Ti47T@L{)5Dof(vpP>1ZL;`;3wy_nRX5wmD83JFki^VsY*B(t~TPV
z57u8u&$=7WDOodcm1Xh6Sw3;_^oC`ftLrscj03h@^?&>z3HI=(;^e%fYS^APOm19W
z$1YY_!Jp9c{r3rr`AB(l0O!GlnnQ}L0>op_S=PDX5YCti{V3~4h-+5ue4NR!tn=Q3
zKLW1)kh?Wp>-LS^-O(D}f#=C?7fyLQ+Rk7FwL8Ft8D~A6<=uHNPI{kYxykd2VA?sO
z*$`e<JIu4J^M3dG{HdWN3*@{l$`ixAWC8!+Rj%B4NiAul7r+Mk2!0?!Zg8uRkDqL1
z#(+EAil@`be8izPZwZo5a_IRphR$tU*R|q$noz&2{oY(>dvUw(5|4f9tRsD3OI5Q;
zyFPxi`egJRt{xp3ru5%<X8%)gUtn&Jz%ghyYOgDJPRDpa<Ngf%PHnkzShO7tdL!g>
zj6OM?t^+dYDjz^+NDqU5v|VF;Io(sZ(^Ahayer@cn3@@!Uu$Wy)N<gMXfj3pNg1pm
ztv57TT+#D&Og@~Qj55UIROe-#o88dqht$a8D!@t>-}|~bHIjsjDW!Z;9%E^dv}p(|
zGbt)HR=L@re<+<(%tPx=d3W_ryNl%))@ETvvIZ*>MfryTV`DPTJ8mBP(Rtr5xW{$Y
zVem`tIC=iS?$%2x=w<ic4?AJMZ4JL(Cm+c!X00-ufd^VdtIFs623FxMop-sXoQpWB
z0<t;y)h2&%g+QTzvJT225z28S2b^aX<Y_z$&oKHoCc1VqHq+a^OCafIPm1Cce+9Wq
z%odBGGYu_Qbi~z}VViQq*U8zY9%0IU#J?phJU^mwBRHRLHf3XMco8!fxTIG^>Es=7
zLT%=t>cNne!+8bHb7gdH-$J%%1x_?yD%9_yJm4(H4NHaHyNI9o#>AWuz3th>^?G|_
zm$Lg!y&fa*Y&lL$g}f(S=}3b8X|4CCHHnRhc(UO1Pjhe$osV-g-s{>`kF|YHz;vWX
z3mvj{nrG4f8{y`Ih8l3k*tnni{13H1^~OYVyXyazcP-FSRay4dFR7|jlFFBt5Rys-
z0!a$Y7ts-^K!SWK3Mxn=j8*(9q(0gKk;YaFaMadlL&9Hst)hxJ7=l8jlIfW>&cuK{
zw1k<E5EQ$6H7(eaR4PzG8hU!{$?Wr9y;K5fx1U~XdJU{w@00iLd+*+J&pqedbM^u1
zlgnZB9vQ4d%uXGjb6K#8v9()(&GasO8c643wlYu|=}4uJ|4R`w^X(Dk^|#?rWdVmO
z>q~K{-l;s?gvf*u#HmysaViyvQ}E>&Ih(+rP2_Q?)MId{;%>pAdKqn5heG2~2@Lqr
zSX4vMF$jxl<`e;oif`X$aozP9_&#7vhU52nejCoMv!y43J0p&v(SExrqw>47jmhuQ
z*864oU51foig23QjqRnH{3RP_`0he3DdW)7UdrxB+wWhNXiJbavczW`+Ttk$GQsu%
ziP_u%<g6B>$Lzg-;DMZJEyyTzi8YxqR`X!%U-GGL$lsXfUwqkpQi$b_UjCUy<}}(F
zw*_4N5o}YiC5k6W&H!#9EtFtgQajyit-3;2Jz_WVIbQJ9&ZHKjH^sjYbL;%etclsP
zYH+nPs*o(jZM~+xS$vimd135TF<VvfS;JL%L$uF~?-*?_HiY|RDz+8ikwo)iTSju-
zpe09g-L&13>!$dun1!gVH<IgyuF`#Bt{dTc%5_7%Aa59(>qe9@&=RodYi`Mrgl`|o
zkyJb?M^f=wF-MZ{+(?e3(Qh|4M^f=wF-KBc@9jB~iqC#gj-;*EQ%8K?NkWN83^c!p
z>vxPh9>yI!&f^Z^m&YAE9>yI!e$Us%9ZbH)?(Yn$L+mezJ9znb<NplYLA=Sly6*sY
z@YHvJJ1FNf@5S-b-&owicSqq4(!Pj0Nc#fr;JagR2kCrd1(9$EsXuSU9UNI}BGeIN
z0VaF4-ij<Eo;Y8*hw?;2>pBpnjR~)sNigd_!rPZeXN_iSi5HR|5aD$ZPb8iuc(K5r
zW5hS^tMk?`25ukSC+~tap8K!ty>G<ovCe__dTJkZppS)TM*~#`W4<F|Cl~oJJ)7P^
zT#NbUxPOZ)qk6XO_uwtK3(V<1EU`y5c*=Zb&ku5tA?pUUlXRhGH)Im$M}vujM=xCr
zt@p|cfE47FZb-MpF6S%~9;GKSM;EH2>uj5YvAkcPaAgdCrNW|ul|&ZSOd{)1l>1kV
zLni%Cu$lfjxPJ$)VC7c-6RWyY3GS%@iV0<vQ1X(R#1^HE94U|&aZ%W3iR6wflW2((
z^1ssa={;ypqduu_9^Q~{)<WB8^Q2DVrLlq7*2DqFr$23SU7LO6ZDi?Pcu1~aeMk;j
zQIQ|rDr7@u&d5ARF?)pnaF;~Fs7}hjAh9E_KnJUd)w+*hWexGV8eoOI9h4b_IfY%X
ze*GGv701*U#{H{6UsIh_-xp&jxk5={3?&63N3R1z$rV!PKg6%geLFOyIgm984e9hp
zq~mr~v$gU1StEEyx1u4nR?lspG4j_48d53R^H~r1-ynty?G~+H=Y9^`Y~J!Qx7~oh
ze;FFmq}$MtvM_ItMMIjvf9aQ_A)T5@dcwK#=Z%#8E0O#pM$nMfAoAnjP&&L9X75vW
zm+w<`SL`F5RNal0`5h$Vsj$ZQta2;{64?WZ&xrFa=Syo@9musHgT(=^<+XwA0%_B@
z)(P5i{@Imtg6S6c9U<r1oVj!Qk}Z{=<^&TgTN}-d6iFQnUi>V1g~~kVVysVAg;isY
zyC>Lp-1^Cs(Q|$1F|CVi$A?e|hp`FU(Kw8yuvr<0p6f6UEeFPt)Eootc(M&z{Lq$;
zsrX&VpH<^*nk^5<&vZ<|?}|}pC*t^r9eVseI_fO44G%rtf%YBx+firJaQtis=TB>;
zx79j<%!a#CTVzg>oy<)*wu8&wDjy+7mrlruOxU_k#}$&DNQR0?M}h_?*!&Iv^STt@
zNwQ4=#(=1!+zpyEdE(BoY8iB5<H<GJJHG%Q@>GthSJ|N2U8%3|Li3-r!>Z%#1#$&j
zAEPZlD5;fNj0b<Gm&^0`Z;0SS=6)-DNXk~d)Fa|Uew;0FO6Eg1>Q{fS%c8`Jua0Y+
zsO(nO$K8St8OM8s2pSC0Tr_BocoXsZAdBMp3GskKv&6O47|dNpKB`>_TrGQG*v7}V
z^Er~C?X}aqA!sOMhbBH`24WXk9FsAAq_9l5I+CzfVyqdqH}lwB&CqL9`nrLn96tZa
z2N7&8!t7Gxd6~FB%H|A6^JP3Xmmt~GSfFQ690}oZ(X&L0IAKMFv$24iv9;p6jQx8=
z7ofk3W9oJc%C~00iqvAhFup}z?|L2j`ps>n>q=e&zBcKf@`6<2v<uB2V~+PI@vbSz
znj(iC%6LFEab1b==Iml8Y!pIUNwtJ!CC|sa%ij|jZDb#%*z5^de^>;)j&i8bH_~^x
zxc`W{Rj0{>mbc8KL%oIh8KBK&9(iqnSyr2821?t3+<f7luZKY?g}*qwAK*bo?T067
zCGaMe!m=m9JSvP5(#MEKC_j+c{`8LWF82QdgOcct+JL^D`s{WL$|<mw)pWSHOyGdz
z0(CMMl%EU#uG~L~I+@9%PG$gg61;B|>SQ{PI=T8L<y(!QPL?CXbxO<s)VRE48Au{T
zJd7=}0+>7CXApXYN8P9kxI)OOx>vh19&3TB)uZ2?=!>T{&>LY=(%kYk_T}%eV+s^;
zObGrP^4?^>-fDb9zFV>&O%Drh0M<~mjx(&^VNHO)7kN0+(>0JE;R}oW*CeZ`TVnji
z*ZCYq@Oc>R!N}I0gAV@@$|AFXi-{#cUUp&J!goZw8qpTx_B<sXi|<58V(x1hwZ)dH
zJolTXHz0<D^x;Sp$s*enyo>SBnnMytE)X41nss(Xw_)&A%AY(WSbiwek)qxUdGznE
zY_nz}L#@{CJ|efR2^a<)gS_2nu;Ot0wOCl$IN!P^$Y(X<{L2Os11?UfSbUjrlY+qG
zz_^ani`T`4uZs;|cUivpa%8L%Po;Pi!o|4*<xR+eJ5b1Pon$zYx#_zrnsuKkYm<En
z3#>@CXFH4sKF_Cf>e>{G@r^?sTT`Xy%`(}Oah9Z7jfLK8*?=lMlOR)Wj>KlZ_6%l3
zPf%<<@ItJ4(lbJ<vsPuEozPX$43CxT{JP>B#=zD$WC+t>we6uK3wvXY`<27%ij!)&
zb24*jtvfW{a_C_B{&gk))SfC&gN6Cm@1^&oH>A}+w*k=uj^A8QeO#t(bW5<+I-hsT
z&)2po&Zq7HPCc;S|IvNYs_s_xN*v8sV$PpFtT}IQoB!Ji%&4;K<DI6#*xpJvVMWHn
zYg7xL&V=rH?!@l-?xgMo?&R);?sVS9pVH0Mr#B4OK4He!uAdQD;Y;kF^vT80Jj|`@
zEbXBM2V-gzEssz(Edk%~TE;<1&Ha6@(6}kD>}T8`vl+ZgGv3>w<#rvzyf`q9z94CX
z)Lgn@u7#@?YMqN(D}VFI{;ji>6D$1^hx=ru-}p;jL%L83gi>_@x0`0wAC#r{%*5zU
zZ<uJ9ti2eTe^7#XDmC96`r%uOM-$E5t|Vms&W65ew4`;@S<DlmAO5@$Sa)glaTARv
zR9bGgj{7%w4;EndP+$%;lcn>(BNxCm!rySWR)*fKbSD9MlWU+}&KyO36>qt&t7;Q0
z#{Gvpe+P<qvseZ?P1>jo(?gP9q*ERD<Vs+zfKC(i!d)^m^|c!Js{J;et_7+lYR%f4
zxpM+Ih8FWD@dc6zh;B@G3-n2PsHoo(4H-d0-xRZO8$2Ms8nckDVBFbFWA$P_rVC?<
z-s8K(EIf&CtDGU~%eP_{)^@#I8ejYEFbhkk(ukC!eMvqc%))tiCau#7`Y2hmG(jEr
zLW*3Gp1;ys9qyf2-hO&9v;*rejUM7yz`q^Eu{2?hr5O}8PU<t_EkeB!EJUh#xHjGl
zyZezi=$D|Y1<U%BzQn%ri=bq;=shdeBkGqT|3z-;>f9E$7rE$z3ZVBytN!m`Ar_$>
z>AR^tsa;<}c^>5jlu`D=_0o-<{nIV%y5=WptQ0M-jQP;`k$QK`-pa;Q{k%q3ZIWe4
z;~TY6zyu-*`<afX8kO3mI1`OCiTs((jTB9=(pvPvGgfJh4u12{F|fUSV$tcS-WcDu
z1JQd_^~$}%IuxuC+>*D?S|e6K!5&bF_ae-~tE;nD>CR?#37Ca3-7oma%0u2-Qmc8$
z;C&u)p8a+5enpn(p7@?9Z9#wgO??q_#Gj4p{h_bo0CUEkm)5Gg6_zceoi5*OjqUjX
z-gJ{kvLVH?uZbv1snF)bR?*D&_&{x#q8{_ed0Ad!TaPb7j<crtn)pYh=3z**HpKS0
zPGH>-Gk99}`quVFbE~^?H6In0(o6e@&hY9&PkIx2R{@7<qBY~3!a8gp?62#a(BtUW
zbfwkHr>?|bV1YQd!cWxgYF=Y~&~FU29MTLV_h@?`K`q*bq~4|2CiafYVGjK5<kg$$
z_O$MC=XG4-X70m9n7@(B9<w*QmS&=vSu@D(9k(Z~exV<^<f}iw)6Hl1ZVtX{tv?gf
z&{d}1<LFa2oWA0?(tfjJ`l;z>1}E$}SK=7VXxNPX_&tMzaeECoKGT1>Wa{9s(}8t$
zTGdS1d$ccMx4$G*7Q6T8z~^O0;laUfm`faeN%h)>#NEkz=M}9fuIfLABC*{-)PxCp
z`7MN9X7+aWn~I+(aRj2VGUf<OhCNDGq_~;#_-35z<o!vi`l0jk8ER<tw5nfIKPNQq
z{;001ep<86@I{{`Yk;C#h+uhoy40S%SGO|@{2~GT;_k2v4lk17QqYb#Ht)gyy(oSZ
zk>*LZAQ|HrO1hM_k=^My_A5|)C`5b2-$h=&vc*X2XjuEJ3#gYHPp4a!`<`r)6?~7P
z$Mh2WGFX(B`55##_@;dz)h>m9A#%nwEhaqQng?2zoUX!|2YG1}=b$qu6K}C?4m`ly
z=#T@!tJomN2$~N%i_-FIjG#RA@}T8DNXwjVn2)bw9Z6Fve80x}qkAaIZfv67MuuX@
zX0*o~_xf0ei+e&f**+7`a&c)Yb4QtP;sF`-UP-oOJw-A8*kc|#>M@|D5l^S58CLS>
zW^1l*=ckf~b)gi`KC5KoKC2v=bAj^Zd8w4PyF7K+4kJF=7<%3_Etq1^`OQOhhm4^)
zSbvPmr+$kIsPnVQ9)$hZ0`h!WK^9sE9_0M{AYOUM?&a`)(Di^gXADj3z$&l@_~x+1
zC8KqyfUoXUpg-m4Px9rVKBWF5j4kRz^6{a*C0&bn8Oe%bUlM;SK_P5K;%U^^Brgsl
zmr`6CdJkR)?Qg#`XbPIHbYir);qAB`|4l(fPF#rDULDvD|7{vm5xFoCv@yclQA1}y
zzEOQ{k~Q{2AaYrZjWT40kB1yG`zWn9D=o7dqky^B?g1rm&#C2(3E>Q_Q+TvzTEm9D
z3%ny*&%ixJ%<WWd3b3A2z5?qx9&Jkc`+v^Dj1PXJ*cH21y-U7_u%1U}8ZE>(A4Va4
zjPx+lV@RJ7?bD-iBr`3mJoy`x<^srhs+{eRr6o6+Ga6fX;y7j6@|N}^GTT<q6D6xV
zw9sJc1}q(JNMAJWOxm0cQcI4#Qk$@0o<(v%Up%|G4!L2a_$^%?ZOIaBOMOw-5QU*l
zULI{0&q$Fmsj83N(3j++=To(LuwJklRqd1(ndLeAk4_+my1nYsD?!%@i~)WG3|X@M
zI!<C>Yl*UkZNm%ffjHE-)2id{G9aRb@Dn;Fqs5<4LD#Cu(vIJdVbK@q;Ta;!Lniua
zsaA(y8Zk6Va0j@F+#c&g&ZW@!5sXRrzI6R^92*tU#@0Rzp7J2<4{KoSA%9Tf3F7)x
zJ&$L&#_EDE4EX>t`;Xz#>N=8jJ+0=oK&c)Wh8yLCVYo5PEJ>K-eaZg^2RtC{@^dc&
z-&}t~>I9M_kOvcZ89u5zp#f4jx9T{em1{y;`1JxkT~ciiTnq`88)knR7=*A!@EC+?
z`2sccYPWeewQg#QJGaSiJV`|YL`v70CtLTO*?Y$I?;CN3IYbVT(38**xBIP2daS4}
z)h@oI5O4_lPRwQ)@5$%SUJ`K#*M)HicUZOE36Nxll!QZ=(4ehf>DR11WxXAVaOrJG
zgvYG=FKvI*z#|b>VV*OMAQ5%}iO>Wj!i6J9gk3xm;eDf!2+RGf+307TG9I;?M<NWo
zX_3_I#3)5f_lf+Hds<<|3~hRUT8U|3I>s^lLEpc-<=#78C+;rEEiw(5`b$AE)7xI{
zH~-AhU)FZ<XSz_?`%(FdJh45PV=CIY&?n1bcC|yQRof3CQsFsuyJr&QgQXs6etsB>
zFdbNgddykKo^~S@ScDTW&+qmsyYnd8?wl_4FnqsM-LSR-i;#X}x?!31(0rxo7C0cV
z2<ur#25(&)jYTNhxWqY!#xIT8pJMwjC^Rq8oJ72^1zVcOT2W~3YD1whPxF?@ry~9@
zQI?tDMRJ}O;kyn;;@j`A%<#=ce0!9caV1WTV;y`_R%qcTfthKU9(lW(h+o<RMZ7e#
z$~wFF>&Lj~TXOgqcl}6=dnVen?Hk9qV}4t!M)bVO<_ty|RKACr$bKl%|L7KfAih2B
z6Xpn7OQLquVf!Zhl*ReH$Y<OJ4}~IjBd2IuV2S>|a>)Y793||=>XL+qBo;0F7lb4B
z&}J*mkCgL`q!M;xPO<bsg;`G#azkkzwKo32tQNV2jx-*bmbPk7B5E@8*D4>3vdo+F
zd#as3P5}+sKEV<1t;4vaZn7>e#K>>!l{jaD&zc6}k<DRVan%6&;PHs(f&D6?-#a2R
zq&ilxxy52D_C4-^h9o~noFt`3W!D54Rs}n(Dn66?mLA6yR{f%Jc)iMG2+|eIAuo~4
zOZFT39G5ef8BY&ca3y~pHQCs8iPJQ2`ilJu)wc!pF-~$e(>}ZS{$eF&>u0Pl&QY1n
z&9ESU5V7NQf)*)0?G(0Rdn?bmhthF3$tc72XH2wbbm)jas_};F-Ax7k(3!~o^qIU$
zGf01b&g2@RJcD#)st<N4ySqueg3jWqYI+~JU2k>OAody@ado!ZE<}^6mkn8l?aF!=
zV%Omb0_)!_TqCqzU4SHvXF(G$pa?pkh_&~aMlMf-?x^y*hF<Z?&{M3C-H;U?=#v;e
z?SnmQTOwvJ;aprG0ak6YaJh!&d1LfgL9B5NErd?s;(j3m*X0Z{wid0kEp9-P!>I4V
zvJKfA30Hu8^2NT>9B2C_^WvwtxR-#DB0)T!N{m<TYQL#P4^T8-q@8!+-t1yQMs;zA
zHRyHjrxo&Dh@Aiqs1R)?*3Hn4DLsd*4E&96a~#RLH32E)o(`M^U7&yQceLOd-phh$
zLlZFKujm85_vsq?>z`_MIpLZjZ=oh!C$+mK5P5Hs$r63*;M4l!InBXYE8@-DJ)b+8
zgE5A!p5~y^AhEyL@lwZ+I@IX%^&J@TwrHQVV?E^Bf7MiXD9|_ak&8sI5m1~VwWUaB
ze;M4#Ej{f`Qa(oc?6}DI6Ma*m^E>PMC43th?aTR==6#T=HGvhpuTe@*EZSPr9b50h
zTHA7a)fM4t%@s|9%(()sFCNo35>8;;4d$dCVUCCWF7Cf@E-IUG)!Fc}t&v(wAtRkc
zU-4c#JjakCJEnv(oj!ijT8=j<K5M@!j0RRMv5Q_p60G{Eb0Wub9M=@HY7I2->TC&(
z9Fmgz5F5YjvIXAD)n)wC<GN$_(09@Lpk~jC@Sa+(3#kzUpDB-timQ*G@~(CF(YB+g
z!RD&653<iBD-{-(Y1m{B4zJKyvOz`4Yr<E>b(2N>C)SOfarM*kBKI-p?RS1;rD*Qx
z^U28M`Ugk$%_!b;2>FwMOhCRv(D{99KZwI9q<SifV_T{&xlU`qoi`md!~XE_k<osx
zml5Z33Wel2!dQC`B^f0HMeI-Z6_|giu~-GNIUsMkxYXD`h50x3ith&VZ)}}^J(zzf
zJ*GaQ4buQ5awia0!aQX(73qq8WmOhVDIzLteLJ@Q{M)8}7dKP>Wte~EHxhVi5GWzi
z&$na#Q9o0k6Yr6C-HQ45axCc}Mn1k;;44HM=7a1QV@J!{u`lXRUk~%|wCq;QKUv&Z
z%)gVUo9ZW<Ej?4DMPW|LXqoTj^z*!_dWE;b>-E0p-R3oWSz-A_cNw)&`*c&^?oWU4
z+Z|Te0MJfj(dUHux*8nY#k~xVY!Q9#v`j>wy9<0JGA9u)rS`eUH?yVo<C!f_qO3=;
zqdbnX4#kYJ8Rcn|nedOA*>W#_@BL1EYvFk^WcKKW$~}Z&54rnvzRwMRdRe}Un+k*=
zsckakjL9vNeGcHPU=#*&Ta3TR@?9Ky!P5>6OqD+imL)UpB|5VQvQUG>mW8pJg>^S}
zEgkX$wVEkx4K@u5vxvcl7&{#>_23KkKFas?TGyE@VC!N3H<(`+=OB*l9<8e!xVD6^
zH)+!C_<CYIjEJpw4E;%RDA|_8IrwoNi7dA_(;4S<z_%^8mpMjDTNoMFnRAq+R#Q>7
zrmgk2YyP4AsCD+5R(Sg_tQ#2YJKAS1v$U)_?k=-q-_Uoa&wSk62Kn_uXWwIOb%D&~
zoqhBdcH!3~&5<{3HAS{##{ZBcIt?-&n6A*1`T3>wVZZxAdo%C?Ld<?9c=4ui1uPwV
ztAcZViiZ2z1_O3@T5E!x@a~@LpW9}<PzQ@0oiko2!V|>Wk!LwvJI?a8-`hIf=W@C)
z$oIPTD;fp^XM&||k-AF!CE>ct{6cN63-0}SWZ!aj4h{zLaP6yj($T<_);wI<jD15Z
zoiko2z+1cU*0?g5bsc`4fnA7QP4{KAX@bK0(%Yu{$Ma7}_6zU(>eWoY@j_B7R+5|S
zS6{u_e6{N8#R~~O<_Pj%L^UTMcQw7e${vwf&LL)!1OFh|mQg1oX6=jO)fg*cYK$Ys
z(r`%zN+u&&m@xfF9v1k|Uk2CDao3KK=zHQPWq6*5>o?jrT%<>~ep9u^XSD6G!UD%7
z<jWQ0tEckieIl6;zj<C3i2k0bZ_pBHha}W1@(K7hIA-y5Jl#o1PSx2{O@HH`0luEw
zI~O#5SD40U;cp~O(x@cw5Xk~$%pORA&k_BFXprWDl%68{#hVOQ7%<8W$9T;MoU0<9
z@U||KL=4$_UOU6@O2jfl&PJ5*czA#mBbIShyB@!5+O_yy+ddAz>)MO(Yi*CgZ*}`p
z8>=x7t#99gqdD#7p#>;56cb7n%Ka!0pe#aJjPfALL+y-vt%t2$g13lB^O5x_ktV3W
zNd~39jpjL)95zokIF?N7;+Ek31wKQ*A$;3+rG~A7*|6x5M-GsJY{~Yeu$KcL#_)WA
zyc9EP6!v8Uu`Q5!K7;2{Nb`7NVE!dFVgy)?x&;UwVXG1P208`dq>$Y}#Q2+l_}|EU
z_suc>M%VdA#2V8#ejAKGFIofArbFX54Y)hyIgod8hE{;Wo=M^O1oFEey9hm>F#gD%
zDU2P#!&izGTe*$d$(ur|hd<{5-cJgMYTHV;l^Q83)j{zGu2PKXUtoP{Dl{P2O(P?O
zt#yNzXE?QJGuA4O3G<=h8r6bj1DU+Pz|N*kO{;@<STf*GY$%W&SbHGd$A-E*@<OU#
zTGQOu87Q>M^Rp{v^d<H;_rpubL2~)kcgcGq3A&*>^peLNnvWUn)xey7wM9ezUYM&C
z`gJAWzsR`0_eWcA5%FGxJSxdT>=n_}KZ9mOJchp>9E?+6fP+CHzKq4OgWIyfKCzXe
zygVID5?l2XuKOx=Y~s)L?4|k~_N+9AEtMv*2qwm8{0q8oD%;BLVV~Tfd+AuuT-#`0
z#~A7e)sMx<Ff32iO<O)g_fq@4IZ?9YoDKiI(e?XA@!BLdsKCAY45r&Ujxl9&&Z0jg
zCMKtH#ii3{JiK&Sbxlo8RBqJdC_~iLsN$%S=qb^8(bJ;uh%SvTQyP?0mBq>uRjz8X
zDqmHgDpVDzr>OJP)6{pw<i<>nnHF<L%=DN$HPbYA#OB8qi2uu}G2&-$ZJWc`uL@Ue
Sr^9daZ&)c|i{*cO>VE-~#_dZ0

literal 0
HcmV?d00001

-- 
2.6.6
