From: alekcejk@googlemail.com
Subject: Re: Re: Re: Re: limited network bandwidth with 3.2.x kernels
Date: Tue, 14 Feb 2012 01:24:43 +0200
Message-ID: <1869678.5qPYfWRscm@localhost.localdomain>
References: <8633039.fHPLx6GNq3@localhost.localdomain> <1486820.tZrzp7eZ2l@localhost.localdomain> <1329174886.2523.16.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:45812 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754374Ab2BMXZQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2012 18:25:16 -0500
Received: by bkcjm19 with SMTP id jm19so4977317bkc.19
        for <netdev@vger.kernel.org>; Mon, 13 Feb 2012 15:25:14 -0800 (PST)
In-Reply-To: <1329174886.2523.16.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=D0=92 =D1=81=D0=BE=D0=BE=D0=B1=D1=89=D0=B5=D0=BD=D0=B8=D0=B8 =D0=BE=D1=
=82 =D0=92=D1=82=D0=BE=D1=80=D0=BD=D0=B8=D0=BA 14 =D1=84=D0=B5=D0=B2=D1=
=80=D0=B0=D0=BB=D1=8F 2012 00:14:46 =D0=B2=D1=8B =D0=BD=D0=B0=D0=BF=D0=B8=
=D1=81=D0=B0=D0=BB=D0=B8:
> Le mardi 14 f=C3=A9vrier 2012 =C3=A0 01:09 +0200, alekcejk@googlemail=
=2Ecom a
>=20
> =C3=A9crit :
> > =D0=92 =D1=81=D0=BE=D0=BE=D0=B1=D1=89=D0=B5=D0=BD=D0=B8=D0=B8 =D0=BE=
=D1=82 =D0=9F=D0=BE=D0=BD=D0=B5=D0=B4=D0=B5=D0=BB=D1=8C=D0=BD=D0=B8=D0=BA=
 13 =D1=84=D0=B5=D0=B2=D1=80=D0=B0=D0=BB=D1=8F 2012 17:51:20 =D0=B2=D1=8B=
 =D0=BD=D0=B0=D0=BF=D0=B8=D1=81=D0=B0=D0=BB=D0=B8:
> > > Hi,
> > >=20
> > > Could you also please post a tcpdump of a "good" transfer on a 3.=
1.x
> > > kernel to the same server? It would be nice to make sure the opti=
ons
> > > and advertised windows are the same in both cases.
> > >=20
> > > neal
> >=20
> > Hi,
> >=20
> > Here tcpdump for 3.1.10 kernel (2.6.41.10-3.fc15.i686):
> >=20
> > tcpdump: verbose output suppressed, use -v or -vv for full protocol=
 decode
> > listening on eth0, link-type EN10MB (Ethernet), capture size 65535 =
bytes
> > 01:03:59.499533 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.=
], seq 1015030570:1015032018, ack 3902015221, win 46, options [nop,nop,=
TS val 3724352664 ecr 4211303], length 1448
> > 01:03:59.499655 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.=
], seq 1448:2896, ack 1, win 46, options [nop,nop,TS val 3724352664 ecr=
 4211303], length 1448
> > 01:03:59.499665 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.=
], ack 2896, win 41449, options [nop,nop,TS val 4211360 ecr 3724352664]=
, length 0
> > 01:03:59.499778 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.=
], seq 2896:4344, ack 1, win 46, options [nop,nop,TS val 3724352664 ecr=
 4211303], length 1448
>=20
> Hmm, we miss the first messages (SYN & SYNACK) to check what was
> negociated.


So, again for 3.1.10:

tcpdump: verbose output suppressed, use -v or -vv for full protocol dec=
ode
listening on eth0, link-type EN10MB (Ethernet), capture size 65535 byte=
s
01:21:18.094169 IP AA.BB.CC.XY.33198 > 213.83.42.56.21: Flags [S], seq =
2101693382, win 14600, options [mss 1460,sackOK,TS val 4294830145 ecr 0=
,nop,wscale 4], length 0
01:21:18.152513 IP 213.83.42.56.21 > AA.BB.CC.XY.33198: Flags [S.], seq=
 58248632, ack 2101693383, win 5792, options [mss 1460,sackOK,TS val 37=
24787939 ecr 4294830145,nop,wscale 7],=20
length 0
01:21:18.152580 IP AA.BB.CC.XY.33198 > 213.83.42.56.21: Flags [.], ack =
1, win 913, options [nop,nop,TS val 4294830203 ecr 3724787939], length =
0
01:21:18.470084 IP 213.83.42.56.21 > AA.BB.CC.XY.33198: Flags [P.], seq=
 1:68, ack 1, win 46, options [nop,nop,TS val 3724788072 ecr 4294830203=
], length 67
01:21:18.470111 IP AA.BB.CC.XY.33198 > 213.83.42.56.21: Flags [.], ack =
68, win 913, options [nop,nop,TS val 4294830521 ecr 3724788072], length=
 0
01:21:18.470193 IP AA.BB.CC.XY.33198 > 213.83.42.56.21: Flags [P.], seq=
 1:17, ack 68, win 913, options [nop,nop,TS val 4294830521 ecr 37247880=
72], length 16
01:21:18.528575 IP 213.83.42.56.21 > AA.BB.CC.XY.33198: Flags [.], ack =
17, win 46, options [nop,nop,TS val 3724788096 ecr 4294830521], length =
0
01:21:18.531582 IP 213.83.42.56.21 > AA.BB.CC.XY.33198: Flags [P.], seq=
 68:143, ack 17, win 46, options [nop,nop,TS val 3724788098 ecr 4294830=
521], length 75
01:21:18.531667 IP AA.BB.CC.XY.33198 > 213.83.42.56.21: Flags [P.], seq=
 17:30, ack 143, win 913, options [nop,nop,TS val 4294830582 ecr 372478=
8098], length 13
01:21:18.591595 IP 213.83.42.56.21 > AA.BB.CC.XY.33198: Flags [P.], seq=
 143:166, ack 30, win 46, options [nop,nop,TS val 3724788123 ecr 429483=
0582], length 23
01:21:18.631127 IP AA.BB.CC.XY.33198 > 213.83.42.56.21: Flags [.], ack =
166, win 913, options [nop,nop,TS val 4294830682 ecr 3724788123], lengt=
h 0
01:21:18.689584 IP 213.83.42.56.21 > AA.BB.CC.XY.33198: Flags [P.], seq=
 166:393, ack 30, win 46, options [nop,nop,TS val 3724788164 ecr 429483=
0682], length 227
01:21:18.689603 IP AA.BB.CC.XY.33198 > 213.83.42.56.21: Flags [.], ack =
393, win 980, options [nop,nop,TS val 4294830740 ecr 3724788164], lengt=
h 0
01:21:18.689782 IP AA.BB.CC.XY.33198 > 213.83.42.56.21: Flags [P.], seq=
 30:36, ack 393, win 980, options [nop,nop,TS val 4294830740 ecr 372478=
8164], length 6
01:21:18.748301 IP 213.83.42.56.21 > AA.BB.CC.XY.33198: Flags [P.], seq=
 393:412, ack 36, win 46, options [nop,nop,TS val 3724788188 ecr 429483=
0740], length 19
01:21:18.748488 IP AA.BB.CC.XY.33198 > 213.83.42.56.21: Flags [P.], seq=
 36:41, ack 412, win 980, options [nop,nop,TS val 4294830799 ecr 372478=
8188], length 5
01:21:18.806974 IP 213.83.42.56.21 > AA.BB.CC.XY.33198: Flags [P.], seq=
 412:446, ack 41, win 46, options [nop,nop,TS val 3724788213 ecr 429483=
0799], length 34
01:21:18.807148 IP AA.BB.CC.XY.33198 > 213.83.42.56.21: Flags [P.], seq=
 41:49, ack 446, win 980, options [nop,nop,TS val 4294830858 ecr 372478=
8213], length 8
01:21:18.865551 IP 213.83.42.56.21 > AA.BB.CC.XY.33198: Flags [P.], seq=
 446:465, ack 49, win 46, options [nop,nop,TS val 3724788238 ecr 429483=
0858], length 19
01:21:18.865769 IP AA.BB.CC.XY.33198 > 213.83.42.56.21: Flags [P.], seq=
 49:87, ack 465, win 980, options [nop,nop,TS val 4294830916 ecr 372478=
8238], length 38
01:21:18.924413 IP 213.83.42.56.21 > AA.BB.CC.XY.33198: Flags [P.], seq=
 465:493, ack 87, win 46, options [nop,nop,TS val 3724788262 ecr 429483=
0916], length 28
01:21:18.924601 IP AA.BB.CC.XY.33198 > 213.83.42.56.21: Flags [P.], seq=
 87:130, ack 493, win 980, options [nop,nop,TS val 4294830975 ecr 37247=
88262], length 43
01:21:18.983111 IP 213.83.42.56.21 > AA.BB.CC.XY.33198: Flags [P.], seq=
 493:509, ack 130, win 46, options [nop,nop,TS val 3724788287 ecr 42948=
30975], length 16
01:21:18.983330 IP AA.BB.CC.XY.33198 > 213.83.42.56.21: Flags [P.], seq=
 130:136, ack 509, win 980, options [nop,nop,TS val 4294831034 ecr 3724=
788287], length 6
01:21:19.041978 IP 213.83.42.56.21 > AA.BB.CC.XY.33198: Flags [P.], seq=
 509:560, ack 136, win 46, options [nop,nop,TS val 3724788311 ecr 42948=
31034], length 51
01:21:19.042157 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [S], s=
eq 1510671465, win 14600, options [mss 1460,sackOK,TS val 4294831093 ec=
r 0,nop,wscale 4], length 0
01:21:19.081040 IP AA.BB.CC.XY.33198 > 213.83.42.56.21: Flags [.], ack =
560, win 980, options [nop,nop,TS val 4294831132 ecr 3724788311], lengt=
h 0
01:21:19.096323 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [S.], =
seq 91818992, ack 1510671466, win 5792, options [mss 1460,sackOK,TS val=
 3724788335 ecr 4294831093,nop,wscale 7],=20
length 0
01:21:19.096379 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 1, win 913, options [nop,nop,TS val 4294831147 ecr 3724788335], leng=
th 0
01:21:19.096545 IP AA.BB.CC.XY.33198 > 213.83.42.56.21: Flags [P.], seq=
 136:179, ack 560, win 980, options [nop,nop,TS val 4294831147 ecr 3724=
788311], length 43
01:21:19.154857 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 1:1449, ack 1, win 46, options [nop,nop,TS val 3724788360 ecr 429483=
1147], length 1448
01:21:19.154885 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 1449, win 1094, options [nop,nop,TS val 4294831205 ecr 3724788360], =
length 0
01:21:19.154980 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 1449:2897, ack 1, win 46, options [nop,nop,TS val 3724788360 ecr 429=
4831147], length 1448
01:21:19.154992 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 2897, win 1275, options [nop,nop,TS val 4294831205 ecr 3724788360], =
length 0
01:21:19.156700 IP 213.83.42.56.21 > AA.BB.CC.XY.33198: Flags [P.], seq=
 560:661, ack 179, win 46, options [nop,nop,TS val 3724788360 ecr 42948=
31147], length 101
01:21:19.156775 IP AA.BB.CC.XY.33198 > 213.83.42.56.21: Flags [.], ack =
661, win 980, options [nop,nop,TS val 4294831207 ecr 3724788360], lengt=
h 0
01:21:19.209365 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 2897:4345, ack 1, win 46, options [nop,nop,TS val 3724788382 ecr 429=
4831205], length 1448
01:21:19.209390 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 4345, win 1456, options [nop,nop,TS val 4294831260 ecr 3724788382], =
length 0
01:21:19.209487 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 4345:5793, ack 1, win 46, options [nop,nop,TS val 3724788382 ecr 429=
4831205], length 1448
01:21:19.209497 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 5793, win 1637, options [nop,nop,TS val 4294831260 ecr 3724788382], =
length 0
01:21:19.209612 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 5793:7241, ack 1, win 46, options [nop,nop,TS val 3724788382 ecr 429=
4831205], length 1448
01:21:19.209623 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 7241, win 1818, options [nop,nop,TS val 4294831260 ecr 3724788382], =
length 0
01:21:19.209735 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 7241:8689, ack 1, win 46, options [nop,nop,TS val 3724788382 ecr 429=
4831205], length 1448
01:21:19.209745 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 8689, win 1999, options [nop,nop,TS val 4294831260 ecr 3724788382], =
length 0
01:21:19.263863 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 8689:10137, ack 1, win 46, options [nop,nop,TS val 3724788405 ecr 42=
94831260], length 1448
01:21:19.263876 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 10137, win 2180, options [nop,nop,TS val 4294831314 ecr 3724788405],=
 length 0
01:21:19.263990 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 10137:11585, ack 1, win 46, options [nop,nop,TS val 3724788405 ecr 4=
294831260], length 1448
01:21:19.264002 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 11585, win 2361, options [nop,nop,TS val 4294831314 ecr 3724788405],=
 length 0
01:21:19.264109 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 11585:13033, ack 1, win 46, options [nop,nop,TS val 3724788405 ecr 4=
294831260], length 1448
01:21:19.264120 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 13033, win 2542, options [nop,nop,TS val 4294831315 ecr 3724788405],=
 length 0
01:21:19.264232 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 13033:14481, ack 1, win 46, options [nop,nop,TS val 3724788405 ecr 4=
294831260], length 1448
01:21:19.264244 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 14481, win 2723, options [nop,nop,TS val 4294831315 ecr 3724788405],=
 length 0
01:21:19.264355 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 14481:15929, ack 1, win 46, options [nop,nop,TS val 3724788405 ecr 4=
294831260], length 1448
01:21:19.264366 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 15929, win 2904, options [nop,nop,TS val 4294831315 ecr 3724788405],=
 length 0
01:21:19.264478 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 15929:17377, ack 1, win 46, options [nop,nop,TS val 3724788405 ecr 4=
294831260], length 1448
01:21:19.264489 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 17377, win 3085, options [nop,nop,TS val 4294831315 ecr 3724788405],=
 length 0
01:21:19.318324 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 17377:18825, ack 1, win 46, options [nop,nop,TS val 3724788428 ecr 4=
294831314], length 1448
01:21:19.318339 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 18825, win 3266, options [nop,nop,TS val 4294831369 ecr 3724788428],=
 length 0
01:21:19.318447 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 18825:20273, ack 1, win 46, options [nop,nop,TS val 3724788428 ecr 4=
294831314], length 1448
01:21:19.318463 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 20273, win 3447, options [nop,nop,TS val 4294831369 ecr 3724788428],=
 length 0
01:21:19.318570 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 20273:21721, ack 1, win 46, options [nop,nop,TS val 3724788428 ecr 4=
294831314], length 1448
01:21:19.318580 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 21721, win 3628, options [nop,nop,TS val 4294831369 ecr 3724788428],=
 length 0
01:21:19.318693 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 21721:23169, ack 1, win 46, options [nop,nop,TS val 3724788428 ecr 4=
294831314], length 1448
01:21:19.318702 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 23169, win 3809, options [nop,nop,TS val 4294831369 ecr 3724788428],=
 length 0
01:21:19.318815 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 23169:24617, ack 1, win 46, options [nop,nop,TS val 3724788428 ecr 4=
294831315], length 1448
01:21:19.318825 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 24617, win 3990, options [nop,nop,TS val 4294831369 ecr 3724788428],=
 length 0
01:21:19.318939 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 24617:26065, ack 1, win 46, options [nop,nop,TS val 3724788428 ecr 4=
294831315], length 1448
01:21:19.318949 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 26065, win 4006, options [nop,nop,TS val 4294831369 ecr 3724788428],=
 length 0
01:21:19.319062 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 26065:27513, ack 1, win 46, options [nop,nop,TS val 3724788428 ecr 4=
294831315], length 1448
01:21:19.319071 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 27513, win 4006, options [nop,nop,TS val 4294831370 ecr 3724788428],=
 length 0
01:21:19.319185 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 27513:28961, ack 1, win 46, options [nop,nop,TS val 3724788428 ecr 4=
294831315], length 1448
01:21:19.319194 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 28961, win 4006, options [nop,nop,TS val 4294831370 ecr 3724788428],=
 length 0
01:21:19.319308 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 28961:30409, ack 1, win 46, options [nop,nop,TS val 3724788428 ecr 4=
294831315], length 1448
01:21:19.319317 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 30409, win 4006, options [nop,nop,TS val 4294831370 ecr 3724788428],=
 length 0
01:21:19.319431 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 30409:31857, ack 1, win 46, options [nop,nop,TS val 3724788428 ecr 4=
294831315], length 1448
01:21:19.319440 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 31857, win 4006, options [nop,nop,TS val 4294831370 ecr 3724788428],=
 length 0
01:21:19.319554 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 31857:33305, ack 1, win 46, options [nop,nop,TS val 3724788428 ecr 4=
294831315], length 1448
01:21:19.319677 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 33305:34753, ack 1, win 46, options [nop,nop,TS val 3724788428 ecr 4=
294831315], length 1448
01:21:19.319687 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 34753, win 4006, options [nop,nop,TS val 4294831370 ecr 3724788428],=
 length 0
01:21:19.372800 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 34753:36201, ack 1, win 46, options [nop,nop,TS val 3724788451 ecr 4=
294831369], length 1448
01:21:19.372923 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 36201:37649, ack 1, win 46, options [nop,nop,TS val 3724788451 ecr 4=
294831369], length 1448
01:21:19.372935 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 37649, win 4006, options [nop,nop,TS val 4294831423 ecr 3724788451],=
 length 0
01:21:19.373046 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 37649:39097, ack 1, win 46, options [nop,nop,TS val 3724788451 ecr 4=
294831369], length 1448
01:21:19.373168 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 39097:40545, ack 1, win 46, options [nop,nop,TS val 3724788451 ecr 4=
294831369], length 1448
01:21:19.373181 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 40545, win 4006, options [nop,nop,TS val 4294831424 ecr 3724788451],=
 length 0
01:21:19.373292 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 40545:41993, ack 1, win 46, options [nop,nop,TS val 3724788451 ecr 4=
294831369], length 1448
01:21:19.373415 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 41993:43441, ack 1, win 46, options [nop,nop,TS val 3724788451 ecr 4=
294831369], length 1448
01:21:19.373426 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 43441, win 4006, options [nop,nop,TS val 4294831424 ecr 3724788451],=
 length 0
01:21:19.373538 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 43441:44889, ack 1, win 46, options [nop,nop,TS val 3724788451 ecr 4=
294831369], length 1448
01:21:19.373661 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 44889:46337, ack 1, win 46, options [nop,nop,TS val 3724788451 ecr 4=
294831369], length 1448
01:21:19.373672 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 46337, win 4006, options [nop,nop,TS val 4294831424 ecr 3724788451],=
 length 0
01:21:19.373784 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 46337:47785, ack 1, win 46, options [nop,nop,TS val 3724788451 ecr 4=
294831369], length 1448
01:21:19.373907 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 47785:49233, ack 1, win 46, options [nop,nop,TS val 3724788451 ecr 4=
294831369], length 1448
01:21:19.373917 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 49233, win 4006, options [nop,nop,TS val 4294831424 ecr 3724788451],=
 length 0
01:21:19.374029 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 49233:50681, ack 1, win 46, options [nop,nop,TS val 3724788451 ecr 4=
294831369], length 1448
01:21:19.374152 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 50681:52129, ack 1, win 46, options [nop,nop,TS val 3724788451 ecr 4=
294831369], length 1448
01:21:19.374163 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 52129, win 4006, options [nop,nop,TS val 4294831425 ecr 3724788451],=
 length 0
01:21:19.374276 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 52129:53577, ack 1, win 46, options [nop,nop,TS val 3724788451 ecr 4=
294831370], length 1448
01:21:19.374398 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 53577:55025, ack 1, win 46, options [nop,nop,TS val 3724788451 ecr 4=
294831370], length 1448
01:21:19.374409 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 55025, win 4006, options [nop,nop,TS val 4294831425 ecr 3724788451],=
 length 0
01:21:19.374522 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 55025:56473, ack 1, win 46, options [nop,nop,TS val 3724788451 ecr 4=
294831370], length 1448
01:21:19.374645 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 56473:57921, ack 1, win 46, options [nop,nop,TS val 3724788451 ecr 4=
294831370], length 1448
01:21:19.374655 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 57921, win 4006, options [nop,nop,TS val 4294831425 ecr 3724788451],=
 length 0
01:21:19.374768 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 57921:59369, ack 1, win 46, options [nop,nop,TS val 3724788451 ecr 4=
294831370], length 1448
01:21:19.374891 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 59369:60817, ack 1, win 46, options [nop,nop,TS val 3724788451 ecr 4=
294831370], length 1448
01:21:19.374902 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 60817, win 4006, options [nop,nop,TS val 4294831425 ecr 3724788451],=
 length 0
01:21:19.375014 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 60817:62265, ack 1, win 46, options [nop,nop,TS val 3724788451 ecr 4=
294831370], length 1448
01:21:19.375137 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 62265:63713, ack 1, win 46, options [nop,nop,TS val 3724788451 ecr 4=
294831370], length 1448
01:21:19.375147 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 63713, win 4006, options [nop,nop,TS val 4294831426 ecr 3724788451],=
 length 0
01:21:19.375260 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 63713:65161, ack 1, win 46, options [nop,nop,TS val 3724788451 ecr 4=
294831370], length 1448
01:21:19.375390 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 65161:66609, ack 1, win 46, options [nop,nop,TS val 3724788451 ecr 4=
294831370], length 1448
01:21:19.375401 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 66609, win 4006, options [nop,nop,TS val 4294831426 ecr 3724788451],=
 length 0
01:21:19.427397 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 66609:68057, ack 1, win 46, options [nop,nop,TS val 3724788474 ecr 4=
294831423], length 1448
01:21:19.427533 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 68057:69505, ack 1, win 46, options [nop,nop,TS val 3724788474 ecr 4=
294831423], length 1448
01:21:19.427555 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 69505, win 4006, options [nop,nop,TS val 4294831478 ecr 3724788474],=
 length 0
01:21:19.427659 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 69505:70953, ack 1, win 46, options [nop,nop,TS val 3724788474 ecr 4=
294831423], length 1448
01:21:19.427779 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 70953:72401, ack 1, win 46, options [nop,nop,TS val 3724788474 ecr 4=
294831423], length 1448
01:21:19.427901 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 72401:73849, ack 1, win 46, options [nop,nop,TS val 3724788474 ecr 4=
294831423], length 1448
01:21:19.428025 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 73849:75297, ack 1, win 46, options [nop,nop,TS val 3724788474 ecr 4=
294831423], length 1448
01:21:19.428123 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 75297, win 4006, options [nop,nop,TS val 4294831479 ecr 3724788474],=
 length 0
01:21:19.428151 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 75297:76745, ack 1, win 46, options [nop,nop,TS val 3724788474 ecr 4=
294831424], length 1448
01:21:19.428270 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 76745:78193, ack 1, win 46, options [nop,nop,TS val 3724788474 ecr 4=
294831424], length 1448
01:21:19.428282 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 78193, win 4006, options [nop,nop,TS val 4294831479 ecr 3724788474],=
 length 0
01:21:19.428394 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 78193:79641, ack 1, win 46, options [nop,nop,TS val 3724788474 ecr 4=
294831424], length 1448
01:21:19.428516 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 79641:81089, ack 1, win 46, options [nop,nop,TS val 3724788474 ecr 4=
294831424], length 1448
01:21:19.428528 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 81089, win 4006, options [nop,nop,TS val 4294831479 ecr 3724788474],=
 length 0
01:21:19.428640 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 81089:82537, ack 1, win 46, options [nop,nop,TS val 3724788474 ecr 4=
294831424], length 1448
01:21:19.428763 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 82537:83985, ack 1, win 46, options [nop,nop,TS val 3724788474 ecr 4=
294831424], length 1448
01:21:19.428774 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 83985, win 4006, options [nop,nop,TS val 4294831479 ecr 3724788474],=
 length 0
01:21:19.428886 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 83985:85433, ack 1, win 46, options [nop,nop,TS val 3724788474 ecr 4=
294831424], length 1448
01:21:19.429008 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 85433:86881, ack 1, win 46, options [nop,nop,TS val 3724788474 ecr 4=
294831424], length 1448
01:21:19.429132 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 86881:88329, ack 1, win 46, options [nop,nop,TS val 3724788474 ecr 4=
294831424], length 1448
01:21:19.429255 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 88329:89777, ack 1, win 46, options [nop,nop,TS val 3724788474 ecr 4=
294831424], length 1448
01:21:19.429379 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 89777:91225, ack 1, win 46, options [nop,nop,TS val 3724788474 ecr 4=
294831424], length 1448
01:21:19.429502 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 91225:92673, ack 1, win 46, options [nop,nop,TS val 3724788474 ecr 4=
294831424], length 1448
01:21:19.429625 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 92673:94121, ack 1, win 46, options [nop,nop,TS val 3724788474 ecr 4=
294831425], length 1448
01:21:19.429748 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 94121:95569, ack 1, win 46, options [nop,nop,TS val 3724788474 ecr 4=
294831425], length 1448
01:21:19.429871 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 95569:97017, ack 1, win 46, options [nop,nop,TS val 3724788474 ecr 4=
294831425], length 1448
01:21:19.430000 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 97017:98465, ack 1, win 46, options [nop,nop,TS val 3724788475 ecr 4=
294831425], length 1448
01:21:19.430118 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 98465:99913, ack 1, win 46, options [nop,nop,TS val 3724788475 ecr 4=
294831425], length 1448
01:21:19.430239 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 99913:101361, ack 1, win 46, options [nop,nop,TS val 3724788475 ecr =
4294831425], length 1448
01:21:19.430299 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 101361, win 4006, options [nop,nop,TS val 4294831481 ecr 3724788474]=
, length 0
01:21:19.430363 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 101361:102809, ack 1, win 46, options [nop,nop,TS val 3724788475 ecr=
 4294831425], length 1448
01:21:19.430376 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 102809, win 4187, options [nop,nop,TS val 4294831481 ecr 3724788475]=
, length 0
01:21:19.430485 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 102809:104257, ack 1, win 46, options [nop,nop,TS val 3724788475 ecr=
 4294831425], length 1448
01:21:19.430497 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 104257, win 4368, options [nop,nop,TS val 4294831481 ecr 3724788475]=
, length 0
01:21:19.430608 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 104257:105705, ack 1, win 46, options [nop,nop,TS val 3724788475 ecr=
 4294831425], length 1448
01:21:19.430620 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 105705, win 4549, options [nop,nop,TS val 4294831481 ecr 3724788475]=
, length 0
01:21:19.430732 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 105705:107153, ack 1, win 46, options [nop,nop,TS val 3724788475 ecr=
 4294831426], length 1448
01:21:19.430744 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 107153, win 4730, options [nop,nop,TS val 4294831481 ecr 3724788475]=
, length 0
01:21:19.430854 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 107153:108601, ack 1, win 46, options [nop,nop,TS val 3724788475 ecr=
 4294831426], length 1448
01:21:19.430865 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 108601, win 4911, options [nop,nop,TS val 4294831481 ecr 3724788475]=
, length 0
01:21:19.430978 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 108601:110049, ack 1, win 46, options [nop,nop,TS val 3724788475 ecr=
 4294831426], length 1448
01:21:19.430989 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 110049, win 5092, options [nop,nop,TS val 4294831481 ecr 3724788475]=
, length 0
01:21:19.431100 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 110049:111497, ack 1, win 46, options [nop,nop,TS val 3724788475 ecr=
 4294831426], length 1448
01:21:19.431110 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 111497, win 5273, options [nop,nop,TS val 4294831482 ecr 3724788475]=
, length 0
01:21:19.431224 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 111497:112945, ack 1, win 46, options [nop,nop,TS val 3724788475 ecr=
 4294831426], length 1448
01:21:19.431235 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 112945, win 5392, options [nop,nop,TS val 4294831482 ecr 3724788475]=
, length 0
01:21:19.431347 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 112945:114393, ack 1, win 46, options [nop,nop,TS val 3724788475 ecr=
 4294831426], length 1448
01:21:19.471110 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 114393, win 5454, options [nop,nop,TS val 4294831522 ecr 3724788475]=
, length 0
01:21:19.482006 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 114393:115841, ack 1, win 46, options [nop,nop,TS val 3724788497 ecr=
 4294831478], length 1448
01:21:19.482030 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 115841, win 5635, options [nop,nop,TS val 4294831533 ecr 3724788497]=
, length 0
01:21:19.482127 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 115841:117289, ack 1, win 46, options [nop,nop,TS val 3724788497 ecr=
 4294831478], length 1448
01:21:19.482138 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 117289, win 5816, options [nop,nop,TS val 4294831533 ecr 3724788497]=
, length 0
01:21:19.482251 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 117289:118737, ack 1, win 46, options [nop,nop,TS val 3724788497 ecr=
 4294831478], length 1448
01:21:19.482264 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 118737, win 5973, options [nop,nop,TS val 4294831533 ecr 3724788497]=
, length 0
01:21:19.482374 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 118737:120185, ack 1, win 46, options [nop,nop,TS val 3724788497 ecr=
 4294831478], length 1448
01:21:19.482497 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 120185:121633, ack 1, win 46, options [nop,nop,TS val 3724788497 ecr=
 4294831478], length 1448
01:21:19.482508 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 121633, win 5973, options [nop,nop,TS val 4294831533 ecr 3724788497]=
, length 0
01:21:19.482620 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 121633:123081, ack 1, win 46, options [nop,nop,TS val 3724788497 ecr=
 4294831478], length 1448
01:21:19.482743 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [P.], =
seq 123081:124529, ack 1, win 46, options [nop,nop,TS val 3724788497 ec=
r 4294831479], length 1448
01:21:19.482753 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 124529, win 5973, options [nop,nop,TS val 4294831533 ecr 3724788497]=
, length 0
01:21:19.482866 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 124529:125977, ack 1, win 46, options [nop,nop,TS val 3724788497 ecr=
 4294831479], length 1448
01:21:19.482989 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 125977:127425, ack 1, win 46, options [nop,nop,TS val 3724788497 ecr=
 4294831479], length 1448
01:21:19.483006 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 127425, win 5973, options [nop,nop,TS val 4294831534 ecr 3724788497]=
, length 0
01:21:19.483112 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 127425:128873, ack 1, win 46, options [nop,nop,TS val 3724788497 ecr=
 4294831479], length 1448
01:21:19.483235 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 128873:130321, ack 1, win 46, options [nop,nop,TS val 3724788497 ecr=
 4294831479], length 1448
01:21:19.483245 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 130321, win 5973, options [nop,nop,TS val 4294831534 ecr 3724788497]=
, length 0
01:21:19.483359 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 130321:131769, ack 1, win 46, options [nop,nop,TS val 3724788497 ecr=
 4294831479], length 1448
01:21:19.483481 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 131769:133217, ack 1, win 46, options [nop,nop,TS val 3724788497 ecr=
 4294831479], length 1448
01:21:19.483492 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 133217, win 5973, options [nop,nop,TS val 4294831534 ecr 3724788497]=
, length 0
01:21:19.483605 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 133217:134665, ack 1, win 46, options [nop,nop,TS val 3724788497 ecr=
 4294831479], length 1448
01:21:19.483728 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 134665:136113, ack 1, win 46, options [nop,nop,TS val 3724788497 ecr=
 4294831479], length 1448
01:21:19.483739 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 136113, win 5973, options [nop,nop,TS val 4294831534 ecr 3724788497]=
, length 0
01:21:19.483851 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 136113:137561, ack 1, win 46, options [nop,nop,TS val 3724788497 ecr=
 4294831479], length 1448
01:21:19.483973 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 137561:139009, ack 1, win 46, options [nop,nop,TS val 3724788497 ecr=
 4294831479], length 1448
01:21:19.483983 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 139009, win 5973, options [nop,nop,TS val 4294831534 ecr 3724788497]=
, length 0
01:21:19.484097 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 139009:140457, ack 1, win 46, options [nop,nop,TS val 3724788497 ecr=
 4294831479], length 1448
01:21:19.484220 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 140457:141905, ack 1, win 46, options [nop,nop,TS val 3724788497 ecr=
 4294831479], length 1448
01:21:19.484231 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 141905, win 5973, options [nop,nop,TS val 4294831535 ecr 3724788497]=
, length 0
01:21:19.484342 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 141905:143353, ack 1, win 46, options [nop,nop,TS val 3724788497 ecr=
 4294831479], length 1448
01:21:19.484776 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 143353:144801, ack 1, win 46, options [nop,nop,TS val 3724788498 ecr=
 4294831481], length 1448
01:21:19.484791 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 144801, win 5973, options [nop,nop,TS val 4294831535 ecr 3724788497]=
, length 0
01:21:19.484898 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 144801:146249, ack 1, win 46, options [nop,nop,TS val 3724788498 ecr=
 4294831481], length 1448
01:21:19.485021 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 146249:147697, ack 1, win 46, options [nop,nop,TS val 3724788498 ecr=
 4294831481], length 1448
01:21:19.485034 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 147697, win 5973, options [nop,nop,TS val 4294831536 ecr 3724788498]=
, length 0
01:21:19.485148 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 147697:149145, ack 1, win 46, options [nop,nop,TS val 3724788498 ecr=
 4294831481], length 1448
01:21:19.485270 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 149145:150593, ack 1, win 46, options [nop,nop,TS val 3724788498 ecr=
 4294831481], length 1448
01:21:19.485282 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 150593, win 5973, options [nop,nop,TS val 4294831536 ecr 3724788498]=
, length 0
01:21:19.485390 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 150593:152041, ack 1, win 46, options [nop,nop,TS val 3724788498 ecr=
 4294831481], length 1448
01:21:19.485514 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 152041:153489, ack 1, win 46, options [nop,nop,TS val 3724788498 ecr=
 4294831481], length 1448
01:21:19.485525 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 153489, win 5973, options [nop,nop,TS val 4294831536 ecr 3724788498]=
, length 0
01:21:19.485637 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 153489:154937, ack 1, win 46, options [nop,nop,TS val 3724788498 ecr=
 4294831481], length 1448
01:21:19.485760 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 154937:156385, ack 1, win 46, options [nop,nop,TS val 3724788498 ecr=
 4294831481], length 1448
01:21:19.485770 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 156385, win 5973, options [nop,nop,TS val 4294831536 ecr 3724788498]=
, length 0
01:21:19.485882 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 156385:157833, ack 1, win 46, options [nop,nop,TS val 3724788498 ecr=
 4294831481], length 1448
01:21:19.486005 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 157833:159281, ack 1, win 46, options [nop,nop,TS val 3724788498 ecr=
 4294831481], length 1448
01:21:19.486015 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 159281, win 5973, options [nop,nop,TS val 4294831537 ecr 3724788498]=
, length 0
01:21:19.486128 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 159281:160729, ack 1, win 46, options [nop,nop,TS val 3724788498 ecr=
 4294831481], length 1448
01:21:19.486251 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 160729:162177, ack 1, win 46, options [nop,nop,TS val 3724788498 ecr=
 4294831481], length 1448
01:21:19.486262 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 162177, win 5973, options [nop,nop,TS val 4294831537 ecr 3724788498]=
, length 0
01:21:19.486374 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 162177:163625, ack 1, win 46, options [nop,nop,TS val 3724788498 ecr=
 4294831481], length 1448
01:21:19.486498 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 163625:165073, ack 1, win 46, options [nop,nop,TS val 3724788498 ecr=
 4294831481], length 1448
01:21:19.486508 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 165073, win 5973, options [nop,nop,TS val 4294831537 ecr 3724788498]=
, length 0
01:21:19.486621 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 165073:166521, ack 1, win 46, options [nop,nop,TS val 3724788498 ecr=
 4294831481], length 1448
01:21:19.486744 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 166521:167969, ack 1, win 46, options [nop,nop,TS val 3724788498 ecr=
 4294831481], length 1448
01:21:19.486754 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 167969, win 5973, options [nop,nop,TS val 4294831537 ecr 3724788498]=
, length 0
01:21:19.486867 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 167969:169417, ack 1, win 46, options [nop,nop,TS val 3724788498 ecr=
 4294831481], length 1448
01:21:19.486989 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 169417:170865, ack 1, win 46, options [nop,nop,TS val 3724788498 ecr=
 4294831481], length 1448
01:21:19.487006 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 170865, win 5973, options [nop,nop,TS val 4294831538 ecr 3724788498]=
, length 0
01:21:19.487113 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 170865:172313, ack 1, win 46, options [nop,nop,TS val 3724788498 ecr=
 4294831481], length 1448
01:21:19.487124 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 172313, win 6154, options [nop,nop,TS val 4294831538 ecr 3724788498]=
, length 0
01:21:19.487235 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 172313:173761, ack 1, win 46, options [nop,nop,TS val 3724788498 ecr=
 4294831481], length 1448
01:21:19.487245 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 173761, win 6335, options [nop,nop,TS val 4294831538 ecr 3724788498]=
, length 0
01:21:19.487359 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 173761:175209, ack 1, win 46, options [nop,nop,TS val 3724788498 ecr=
 4294831481], length 1448
01:21:19.487369 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 175209, win 6516, options [nop,nop,TS val 4294831538 ecr 3724788498]=
, length 0
01:21:19.487482 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 175209:176657, ack 1, win 46, options [nop,nop,TS val 3724788498 ecr=
 4294831481], length 1448
01:21:19.487492 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 176657, win 6697, options [nop,nop,TS val 4294831538 ecr 3724788498]=
, length 0
01:21:19.487605 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 176657:178105, ack 1, win 46, options [nop,nop,TS val 3724788498 ecr=
 4294831481], length 1448
01:21:19.487615 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 178105, win 6878, options [nop,nop,TS val 4294831538 ecr 3724788498]=
, length 0
01:21:19.487728 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 178105:179553, ack 1, win 46, options [nop,nop,TS val 3724788498 ecr=
 4294831481], length 1448
01:21:19.487739 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 179553, win 7059, options [nop,nop,TS val 4294831538 ecr 3724788498]=
, length 0
01:21:19.487858 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 179553:181001, ack 1, win 46, options [nop,nop,TS val 3724788498 ecr=
 4294831482], length 1448
01:21:19.487869 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 181001, win 7240, options [nop,nop,TS val 4294831538 ecr 3724788498]=
, length 0
01:21:19.487981 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 181001:182449, ack 1, win 46, options [nop,nop,TS val 3724788498 ecr=
 4294831482], length 1448
01:21:19.487992 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 182449, win 7421, options [nop,nop,TS val 4294831538 ecr 3724788498]=
, length 0
01:21:19.488104 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 182449:183897, ack 1, win 46, options [nop,nop,TS val 3724788498 ecr=
 4294831482], length 1448
01:21:19.488115 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 183897, win 7602, options [nop,nop,TS val 4294831539 ecr 3724788498]=
, length 0
01:21:19.488227 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 183897:185345, ack 1, win 46, options [nop,nop,TS val 3724788498 ecr=
 4294831482], length 1448
01:21:19.488237 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 185345, win 7783, options [nop,nop,TS val 4294831539 ecr 3724788498]=
, length 0
01:21:19.536500 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 185345:186793, ack 1, win 46, options [nop,nop,TS val 3724788520 ecr=
 4294831533], length 1448
01:21:19.536535 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 186793, win 7964, options [nop,nop,TS val 4294831587 ecr 3724788520]=
, length 0
01:21:19.536623 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [P.], =
seq 186793:188241, ack 1, win 46, options [nop,nop,TS val 3724788520 ec=
r 4294831533], length 1448
01:21:19.536636 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 188241, win 8145, options [nop,nop,TS val 4294831587 ecr 3724788520]=
, length 0
01:21:19.536745 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 188241:189689, ack 1, win 46, options [nop,nop,TS val 3724788520 ecr=
 4294831533], length 1448
01:21:19.536757 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 189689, win 8326, options [nop,nop,TS val 4294831587 ecr 3724788520]=
, length 0
01:21:19.536869 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 189689:191137, ack 1, win 46, options [nop,nop,TS val 3724788520 ecr=
 4294831533], length 1448
01:21:19.536881 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 191137, win 8507, options [nop,nop,TS val 4294831587 ecr 3724788520]=
, length 0
01:21:19.536990 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 191137:192585, ack 1, win 46, options [nop,nop,TS val 3724788520 ecr=
 4294831533], length 1448
01:21:19.537009 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 192585, win 8688, options [nop,nop,TS val 4294831588 ecr 3724788520]=
, length 0
01:21:19.537113 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 192585:194033, ack 1, win 46, options [nop,nop,TS val 3724788520 ecr=
 4294831533], length 1448
01:21:19.537126 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 194033, win 8869, options [nop,nop,TS val 4294831588 ecr 3724788520]=
, length 0
01:21:19.537237 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 194033:195481, ack 1, win 46, options [nop,nop,TS val 3724788520 ecr=
 4294831533], length 1448
01:21:19.537249 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 195481, win 9050, options [nop,nop,TS val 4294831588 ecr 3724788520]=
, length 0
01:21:19.537360 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 195481:196929, ack 1, win 46, options [nop,nop,TS val 3724788520 ecr=
 4294831533], length 1448
01:21:19.537372 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 196929, win 9231, options [nop,nop,TS val 4294831588 ecr 3724788520]=
, length 0
01:21:19.537483 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 196929:198377, ack 1, win 46, options [nop,nop,TS val 3724788520 ecr=
 4294831533], length 1448
01:21:19.537495 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 198377, win 9412, options [nop,nop,TS val 4294831588 ecr 3724788520]=
, length 0
01:21:19.537606 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 198377:199825, ack 1, win 46, options [nop,nop,TS val 3724788520 ecr=
 4294831533], length 1448
01:21:19.537617 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 199825, win 9593, options [nop,nop,TS val 4294831588 ecr 3724788520]=
, length 0
01:21:19.537728 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 199825:201273, ack 1, win 46, options [nop,nop,TS val 3724788520 ecr=
 4294831533], length 1448
01:21:19.537739 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 201273, win 9774, options [nop,nop,TS val 4294831588 ecr 3724788520]=
, length 0
01:21:19.537852 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 201273:202721, ack 1, win 46, options [nop,nop,TS val 3724788520 ecr=
 4294831534], length 1448
01:21:19.537864 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 202721, win 9955, options [nop,nop,TS val 4294831588 ecr 3724788520]=
, length 0
01:21:19.537975 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 202721:204169, ack 1, win 46, options [nop,nop,TS val 3724788520 ecr=
 4294831534], length 1448
01:21:19.537987 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 204169, win 10136, options [nop,nop,TS val 4294831588 ecr 3724788520=
], length 0
01:21:19.538098 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 204169:205617, ack 1, win 46, options [nop,nop,TS val 3724788520 ecr=
 4294831534], length 1448
01:21:19.538109 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 205617, win 10317, options [nop,nop,TS val 4294831589 ecr 3724788520=
], length 0
01:21:19.538221 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 205617:207065, ack 1, win 46, options [nop,nop,TS val 3724788520 ecr=
 4294831534], length 1448
01:21:19.538234 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 207065, win 10498, options [nop,nop,TS val 4294831589 ecr 3724788520=
], length 0
01:21:19.538344 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 207065:208513, ack 1, win 46, options [nop,nop,TS val 3724788520 ecr=
 4294831534], length 1448
01:21:19.538356 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 208513, win 10679, options [nop,nop,TS val 4294831589 ecr 3724788520=
], length 0
01:21:19.538468 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 208513:209961, ack 1, win 46, options [nop,nop,TS val 3724788520 ecr=
 4294831534], length 1448
01:21:19.538479 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 209961, win 10860, options [nop,nop,TS val 4294831589 ecr 3724788520=
], length 0
01:21:19.538590 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 209961:211409, ack 1, win 46, options [nop,nop,TS val 3724788520 ecr=
 4294831534], length 1448
01:21:19.538713 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 211409:212857, ack 1, win 46, options [nop,nop,TS val 3724788520 ecr=
 4294831534], length 1448
01:21:19.538725 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 212857, win 10860, options [nop,nop,TS val 4294831589 ecr 3724788520=
], length 0
01:21:19.538836 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 212857:214305, ack 1, win 46, options [nop,nop,TS val 3724788520 ecr=
 4294831534], length 1448
01:21:19.538959 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 214305:215753, ack 1, win 46, options [nop,nop,TS val 3724788520 ecr=
 4294831534], length 1448
01:21:19.538971 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 215753, win 10860, options [nop,nop,TS val 4294831589 ecr 3724788520=
], length 0
01:21:19.539082 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 215753:217201, ack 1, win 46, options [nop,nop,TS val 3724788520 ecr=
 4294831534], length 1448
01:21:19.539206 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 217201:218649, ack 1, win 46, options [nop,nop,TS val 3724788520 ecr=
 4294831534], length 1448
01:21:19.539218 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 218649, win 10860, options [nop,nop,TS val 4294831590 ecr 3724788520=
], length 0
01:21:19.539328 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 218649:220097, ack 1, win 46, options [nop,nop,TS val 3724788520 ecr=
 4294831534], length 1448
01:21:19.539451 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 220097:221545, ack 1, win 46, options [nop,nop,TS val 3724788520 ecr=
 4294831534], length 1448
01:21:19.539463 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 221545, win 10860, options [nop,nop,TS val 4294831590 ecr 3724788520=
], length 0
01:21:19.539575 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 221545:222993, ack 1, win 46, options [nop,nop,TS val 3724788520 ecr=
 4294831534], length 1448
01:21:19.539698 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 222993:224441, ack 1, win 46, options [nop,nop,TS val 3724788520 ecr=
 4294831535], length 1448
01:21:19.539708 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 224441, win 10860, options [nop,nop,TS val 4294831590 ecr 3724788520=
], length 0
01:21:19.539821 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 224441:225889, ack 1, win 46, options [nop,nop,TS val 3724788520 ecr=
 4294831535], length 1448
01:21:19.539944 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 225889:227337, ack 1, win 46, options [nop,nop,TS val 3724788520 ecr=
 4294831535], length 1448
01:21:19.539956 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 227337, win 10860, options [nop,nop,TS val 4294831590 ecr 3724788520=
], length 0
01:21:19.540066 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 227337:228785, ack 1, win 46, options [nop,nop,TS val 3724788520 ecr=
 4294831535], length 1448
01:21:19.540190 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 228785:230233, ack 1, win 46, options [nop,nop,TS val 3724788520 ecr=
 4294831535], length 1448
01:21:19.540200 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 230233, win 10860, options [nop,nop,TS val 4294831591 ecr 3724788520=
], length 0
01:21:19.540313 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 230233:231681, ack 1, win 46, options [nop,nop,TS val 3724788520 ecr=
 4294831535], length 1448
01:21:19.540436 IP 213.83.42.56.49548 > AA.BB.CC.XY.41828: Flags [.], s=
eq 231681:233129, ack 1, win 46, options [nop,nop,TS val 3724788521 ecr=
 4294831536], length 1448
01:21:19.540445 IP AA.BB.CC.XY.41828 > 213.83.42.56.49548: Flags [.], a=
ck 233129, win 10860, options [nop,nop,TS val 4294831591 ecr 3724788520=
], length 0
300 packets captured
301 packets received by filter
0 packets dropped by kernel
