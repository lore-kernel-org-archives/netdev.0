From: alekcejk@googlemail.com
Subject: Re: Re: Re: limited network bandwidth with 3.2.x kernels
Date: Thu, 16 Feb 2012 23:49:35 +0200
Message-ID: <16215291.4ftfQWZto1@localhost.localdomain>
References: <1329399616.9395.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <1461927.R8CTCUdqT9@localhost.localdomain> <CADVnQyknYYaduh4nnc27=oGofBqpExJzqA-ToXufZxbtm0xs6Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1251
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Neal Cardwell <ncardwell@google.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:43634 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751893Ab2BPVtx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2012 16:49:53 -0500
Received: by bkcjm19 with SMTP id jm19so2497857bkc.19
        for <netdev@vger.kernel.org>; Thu, 16 Feb 2012 13:49:50 -0800 (PST)
In-Reply-To: <CADVnQyknYYaduh4nnc27=oGofBqpExJzqA-ToXufZxbtm0xs6Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=C2 =F1=EE=EE=E1=F9=E5=ED=E8=E8 =EE=F2 =D7=E5=F2=E2=E5=F0=E3 16 =F4=E5=E2=
=F0=E0=EB=FF 2012 13:19:58 =E2=FB =ED=E0=EF=E8=F1=E0=EB=E8:
> On Thu, Feb 16, 2012 at 12:54 PM,  <alekcejk@googlemail.com> wrote:
> I still think it would be useful to have these three pieces of data
> for a slow/3.2.x transfer (from a geographically distant server) if
> you have a sec:
>=20
> - tcpdump of first 300 or so packets to see SYN/SYNACK options and RT=
T

tcpdump: listening on eth0, link-type EN10MB (Ethernet), capture size 6=
5535 bytes
23:33:30.161104 IP (tos 0x0, ttl 100, id 40921, offset 0, flags [DF], p=
roto TCP (6), length 60)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [S], cksum 0x9602 (inco=
rrect -> 0x88a0), seq 3622665526, win 14600, options [mss 1460,sackOK,T=
S val 4294828783 ecr 0,nop,wscale 4],=20
length 0
23:33:30.225273 IP (tos 0x0, ttl 53, id 0, offset 0, flags [DF], proto =
TCP (6), length 60)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [S.], cksum 0xf8a5 (cor=
rect), seq 2665972683, ack 3622665527, win 17896, options [mss 8960,sac=
kOK,TS val 3454170400 ecr=20
4294828783,nop,wscale 11], length 0
23:33:30.225296 IP (tos 0x0, ttl 100, id 40922, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x86d8), ack 1, win 913, options [nop,nop,TS val 4294828848 ec=
r 3454170400], length 0
23:33:30.225360 IP (tos 0x0, ttl 100, id 40923, offset 0, flags [DF], p=
roto TCP (6), length 176)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [P.], cksum 0x9676 (inc=
orrect -> 0xd695), seq 1:125, ack 1, win 913, options [nop,nop,TS val 4=
294828848 ecr 3454170400], length 124
23:33:30.289550 IP (tos 0x0, ttl 53, id 63228, offset 0, flags [DF], pr=
oto TCP (6), length 52)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x89d4 (corr=
ect), ack 125, win 9, options [nop,nop,TS val 3454170416 ecr 4294828848=
], length 0
23:33:30.289970 IP (tos 0x0, ttl 53, id 63229, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x4e88 (corr=
ect), seq 1:1449, ack 125, win 9, options [nop,nop,TS val 3454170416 ec=
r 4294828848], length 1448
23:33:30.289983 IP (tos 0x0, ttl 100, id 40924, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x7faf), ack 1449, win 1094, options [nop,nop,TS val 429482891=
2 ecr 3454170416], length 0
23:33:30.290093 IP (tos 0x0, ttl 53, id 63230, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x7e84 (corr=
ect), seq 1449:2897, ack 125, win 9, options [nop,nop,TS val 3454170416=
 ecr 4294828848], length 1448
23:33:30.290108 IP (tos 0x0, ttl 100, id 40925, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x7952), ack 2897, win 1275, options [nop,nop,TS val 429482891=
2 ecr 3454170416], length 0
23:33:30.354330 IP (tos 0x0, ttl 53, id 63231, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x788c (corr=
ect), seq 2897:4345, ack 125, win 9, options [nop,nop,TS val 3454170432=
 ecr 4294828912], length 1448
23:33:30.354343 IP (tos 0x0, ttl 100, id 40926, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x72a4), ack 4345, win 1456, options [nop,nop,TS val 429482897=
7 ecr 3454170432], length 0
23:33:30.354452 IP (tos 0x0, ttl 53, id 63232, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x72e4 (corr=
ect), seq 4345:5793, ack 125, win 9, options [nop,nop,TS val 3454170432=
 ecr 4294828912], length 1448
23:33:30.354464 IP (tos 0x0, ttl 100, id 40927, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x6c47), ack 5793, win 1637, options [nop,nop,TS val 429482897=
7 ecr 3454170432], length 0
23:33:30.354576 IP (tos 0x0, ttl 53, id 63233, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x6d3c (corr=
ect), seq 5793:7241, ack 125, win 9, options [nop,nop,TS val 3454170432=
 ecr 4294828912], length 1448
23:33:30.354586 IP (tos 0x0, ttl 100, id 40928, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x65ea), ack 7241, win 1818, options [nop,nop,TS val 429482897=
7 ecr 3454170432], length 0
23:33:30.354701 IP (tos 0x0, ttl 53, id 63234, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x6794 (corr=
ect), seq 7241:8689, ack 125, win 9, options [nop,nop,TS val 3454170432=
 ecr 4294828912], length 1448
23:33:30.354712 IP (tos 0x0, ttl 100, id 40929, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x5f8d), ack 8689, win 1999, options [nop,nop,TS val 429482897=
7 ecr 3454170432], length 0
23:33:30.418663 IP (tos 0x0, ttl 53, id 63235, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x619b (corr=
ect), seq 8689:10137, ack 125, win 9, options [nop,nop,TS val 345417044=
8 ecr 4294828977], length 1448
23:33:30.418676 IP (tos 0x0, ttl 100, id 40930, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x58e0), ack 10137, win 2180, options [nop,nop,TS val 42948290=
41 ecr 3454170448], length 0
23:33:30.418786 IP (tos 0x0, ttl 53, id 63236, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x5bf3 (corr=
ect), seq 10137:11585, ack 125, win 9, options [nop,nop,TS val 34541704=
48 ecr 4294828977], length 1448
23:33:30.418799 IP (tos 0x0, ttl 100, id 40931, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x5283), ack 11585, win 2361, options [nop,nop,TS val 42948290=
41 ecr 3454170448], length 0
23:33:30.418908 IP (tos 0x0, ttl 53, id 63237, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x564b (corr=
ect), seq 11585:13033, ack 125, win 9, options [nop,nop,TS val 34541704=
48 ecr 4294828977], length 1448
23:33:30.418917 IP (tos 0x0, ttl 100, id 40932, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x4c26), ack 13033, win 2542, options [nop,nop,TS val 42948290=
41 ecr 3454170448], length 0
23:33:30.419038 IP (tos 0x0, ttl 53, id 63238, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x50a3 (corr=
ect), seq 13033:14481, ack 125, win 9, options [nop,nop,TS val 34541704=
48 ecr 4294828977], length 1448
23:33:30.419048 IP (tos 0x0, ttl 100, id 40933, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x45c9), ack 14481, win 2723, options [nop,nop,TS val 42948290=
41 ecr 3454170448], length 0
23:33:30.419155 IP (tos 0x0, ttl 53, id 63239, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [P.], cksum 0x4af3 (cor=
rect), seq 14481:15929, ack 125, win 9, options [nop,nop,TS val 3454170=
448 ecr 4294828977], length 1448
23:33:30.419166 IP (tos 0x0, ttl 100, id 40934, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x3f6b), ack 15929, win 2904, options [nop,nop,TS val 42948290=
42 ecr 3454170448], length 0
23:33:30.419278 IP (tos 0x0, ttl 53, id 63240, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x4553 (corr=
ect), seq 15929:17377, ack 125, win 9, options [nop,nop,TS val 34541704=
48 ecr 4294828977], length 1448
23:33:30.419289 IP (tos 0x0, ttl 100, id 40935, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x390e), ack 17377, win 3085, options [nop,nop,TS val 42948290=
42 ecr 3454170448], length 0
23:33:30.419402 IP (tos 0x0, ttl 53, id 63241, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x3fab (corr=
ect), seq 17377:18825, ack 125, win 9, options [nop,nop,TS val 34541704=
48 ecr 4294828977], length 1448
23:33:30.419414 IP (tos 0x0, ttl 100, id 40936, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x32b1), ack 18825, win 3266, options [nop,nop,TS val 42948290=
42 ecr 3454170448], length 0
23:33:30.419524 IP (tos 0x0, ttl 53, id 63242, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x3a03 (corr=
ect), seq 18825:20273, ack 125, win 9, options [nop,nop,TS val 34541704=
48 ecr 4294828977], length 1448
23:33:30.419533 IP (tos 0x0, ttl 100, id 40937, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x2c54), ack 20273, win 3447, options [nop,nop,TS val 42948290=
42 ecr 3454170448], length 0
23:33:30.483022 IP (tos 0x0, ttl 53, id 63243, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x340b (corr=
ect), seq 20273:21721, ack 125, win 9, options [nop,nop,TS val 34541704=
64 ecr 4294829041], length 1448
23:33:30.483034 IP (tos 0x0, ttl 100, id 40938, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x25a8), ack 21721, win 3628, options [nop,nop,TS val 42948291=
05 ecr 3454170464], length 0
23:33:30.483146 IP (tos 0x0, ttl 53, id 63244, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x2e63 (corr=
ect), seq 21721:23169, ack 125, win 9, options [nop,nop,TS val 34541704=
64 ecr 4294829041], length 1448
23:33:30.483160 IP (tos 0x0, ttl 100, id 40939, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x1f4a), ack 23169, win 3809, options [nop,nop,TS val 42948291=
06 ecr 3454170464], length 0
23:33:30.483268 IP (tos 0x0, ttl 53, id 63245, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [P.], cksum 0x28b3 (cor=
rect), seq 23169:24617, ack 125, win 9, options [nop,nop,TS val 3454170=
464 ecr 4294829041], length 1448
23:33:30.483279 IP (tos 0x0, ttl 100, id 40940, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x18ed), ack 24617, win 3990, options [nop,nop,TS val 42948291=
06 ecr 3454170464], length 0
23:33:30.483400 IP (tos 0x0, ttl 53, id 63246, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x2313 (corr=
ect), seq 24617:26065, ack 125, win 9, options [nop,nop,TS val 34541704=
64 ecr 4294829041], length 1448
23:33:30.483413 IP (tos 0x0, ttl 100, id 40941, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x1344), ack 26065, win 3991, options [nop,nop,TS val 42948291=
06 ecr 3454170464], length 0
23:33:30.483515 IP (tos 0x0, ttl 53, id 63247, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x1d6b (corr=
ect), seq 26065:27513, ack 125, win 9, options [nop,nop,TS val 34541704=
64 ecr 4294829041], length 1448
23:33:30.483526 IP (tos 0x0, ttl 100, id 40942, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x0d9c), ack 27513, win 3991, options [nop,nop,TS val 42948291=
06 ecr 3454170464], length 0
23:33:30.483638 IP (tos 0x0, ttl 53, id 63248, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x17c3 (corr=
ect), seq 27513:28961, ack 125, win 9, options [nop,nop,TS val 34541704=
64 ecr 4294829041], length 1448
23:33:30.483649 IP (tos 0x0, ttl 100, id 40943, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x07f4), ack 28961, win 3991, options [nop,nop,TS val 42948291=
06 ecr 3454170464], length 0
23:33:30.483761 IP (tos 0x0, ttl 53, id 63249, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x121b (corr=
ect), seq 28961:30409, ack 125, win 9, options [nop,nop,TS val 34541704=
64 ecr 4294829041], length 1448
23:33:30.483773 IP (tos 0x0, ttl 100, id 40944, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x024c), ack 30409, win 3991, options [nop,nop,TS val 42948291=
06 ecr 3454170464], length 0
23:33:30.483884 IP (tos 0x0, ttl 53, id 63250, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x0c73 (corr=
ect), seq 30409:31857, ack 125, win 9, options [nop,nop,TS val 34541704=
64 ecr 4294829041], length 1448
23:33:30.483894 IP (tos 0x0, ttl 100, id 40945, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0xfca3), ack 31857, win 3991, options [nop,nop,TS val 42948291=
06 ecr 3454170464], length 0
23:33:30.484014 IP (tos 0x0, ttl 53, id 63251, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x06c9 (corr=
ect), seq 31857:33305, ack 125, win 9, options [nop,nop,TS val 34541704=
65 ecr 4294829042], length 1448
23:33:30.484130 IP (tos 0x0, ttl 53, id 63252, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x0121 (corr=
ect), seq 33305:34753, ack 125, win 9, options [nop,nop,TS val 34541704=
65 ecr 4294829042], length 1448
23:33:30.484142 IP (tos 0x0, ttl 100, id 40946, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0xf152), ack 34753, win 3991, options [nop,nop,TS val 42948291=
06 ecr 3454170465], length 0
23:33:30.484253 IP (tos 0x0, ttl 53, id 63253, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xfb78 (corr=
ect), seq 34753:36201, ack 125, win 9, options [nop,nop,TS val 34541704=
65 ecr 4294829042], length 1448
23:33:30.484376 IP (tos 0x0, ttl 53, id 63254, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xf5d0 (corr=
ect), seq 36201:37649, ack 125, win 9, options [nop,nop,TS val 34541704=
65 ecr 4294829042], length 1448
23:33:30.484386 IP (tos 0x0, ttl 100, id 40947, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0xe601), ack 37649, win 3991, options [nop,nop,TS val 42948291=
07 ecr 3454170465], length 0
23:33:30.484498 IP (tos 0x0, ttl 53, id 63255, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xf028 (corr=
ect), seq 37649:39097, ack 125, win 9, options [nop,nop,TS val 34541704=
65 ecr 4294829042], length 1448
23:33:30.484622 IP (tos 0x0, ttl 53, id 63256, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [P.], cksum 0xea78 (cor=
rect), seq 39097:40545, ack 125, win 9, options [nop,nop,TS val 3454170=
465 ecr 4294829042], length 1448
23:33:30.484632 IP (tos 0x0, ttl 100, id 40948, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0xdab1), ack 40545, win 3991, options [nop,nop,TS val 42948291=
07 ecr 3454170465], length 0
23:33:30.484744 IP (tos 0x0, ttl 53, id 63257, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xe4d8 (corr=
ect), seq 40545:41993, ack 125, win 9, options [nop,nop,TS val 34541704=
65 ecr 4294829042], length 1448
23:33:30.484868 IP (tos 0x0, ttl 53, id 63258, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xdf30 (corr=
ect), seq 41993:43441, ack 125, win 9, options [nop,nop,TS val 34541704=
65 ecr 4294829042], length 1448
23:33:30.484879 IP (tos 0x0, ttl 100, id 40949, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0xcf61), ack 43441, win 3991, options [nop,nop,TS val 42948291=
07 ecr 3454170465], length 0
23:33:30.547393 IP (tos 0x0, ttl 53, id 63259, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xd93a (corr=
ect), seq 43441:44889, ack 125, win 9, options [nop,nop,TS val 34541704=
80 ecr 4294829105], length 1448
23:33:30.547515 IP (tos 0x0, ttl 53, id 63260, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xd392 (corr=
ect), seq 44889:46337, ack 125, win 9, options [nop,nop,TS val 34541704=
80 ecr 4294829105], length 1448
23:33:30.547528 IP (tos 0x0, ttl 100, id 40950, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0xc2ff), ack 46337, win 4187, options [nop,nop,TS val 42948291=
70 ecr 3454170480], length 0
23:33:30.547639 IP (tos 0x0, ttl 53, id 63261, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [P.], cksum 0xcde0 (cor=
rect), seq 46337:47785, ack 125, win 9, options [nop,nop,TS val 3454170=
481 ecr 4294829106], length 1448
23:33:30.547649 IP (tos 0x0, ttl 100, id 40951, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0xbcb9), ack 47785, win 4344, options [nop,nop,TS val 42948291=
70 ecr 3454170481], length 0
23:33:30.547762 IP (tos 0x0, ttl 53, id 63262, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xc840 (corr=
ect), seq 47785:49233, ack 125, win 9, options [nop,nop,TS val 34541704=
81 ecr 4294829106], length 1448
23:33:30.547886 IP (tos 0x0, ttl 53, id 63263, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xc298 (corr=
ect), seq 49233:50681, ack 125, win 9, options [nop,nop,TS val 34541704=
81 ecr 4294829106], length 1448
23:33:30.547897 IP (tos 0x0, ttl 100, id 40952, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0xb169), ack 50681, win 4344, options [nop,nop,TS val 42948291=
70 ecr 3454170481], length 0
23:33:30.548009 IP (tos 0x0, ttl 53, id 63264, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xbcf0 (corr=
ect), seq 50681:52129, ack 125, win 9, options [nop,nop,TS val 34541704=
81 ecr 4294829106], length 1448
23:33:30.548132 IP (tos 0x0, ttl 53, id 63265, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xb748 (corr=
ect), seq 52129:53577, ack 125, win 9, options [nop,nop,TS val 34541704=
81 ecr 4294829106], length 1448
23:33:30.548145 IP (tos 0x0, ttl 100, id 40953, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0xa619), ack 53577, win 4344, options [nop,nop,TS val 42948291=
70 ecr 3454170481], length 0
23:33:30.548255 IP (tos 0x0, ttl 53, id 63266, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xb1a0 (corr=
ect), seq 53577:55025, ack 125, win 9, options [nop,nop,TS val 34541704=
81 ecr 4294829106], length 1448
23:33:30.548378 IP (tos 0x0, ttl 53, id 63267, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xabf8 (corr=
ect), seq 55025:56473, ack 125, win 9, options [nop,nop,TS val 34541704=
81 ecr 4294829106], length 1448
23:33:30.548390 IP (tos 0x0, ttl 100, id 40954, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x9ac8), ack 56473, win 4344, options [nop,nop,TS val 42948291=
71 ecr 3454170481], length 0
23:33:30.548501 IP (tos 0x0, ttl 53, id 63268, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xa650 (corr=
ect), seq 56473:57921, ack 125, win 9, options [nop,nop,TS val 34541704=
81 ecr 4294829106], length 1448
23:33:30.548624 IP (tos 0x0, ttl 53, id 63269, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xa0a8 (corr=
ect), seq 57921:59369, ack 125, win 9, options [nop,nop,TS val 34541704=
81 ecr 4294829106], length 1448
23:33:30.548637 IP (tos 0x0, ttl 100, id 40955, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x8f78), ack 59369, win 4344, options [nop,nop,TS val 42948291=
71 ecr 3454170481], length 0
23:33:30.548747 IP (tos 0x0, ttl 53, id 63270, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x9b00 (corr=
ect), seq 59369:60817, ack 125, win 9, options [nop,nop,TS val 34541704=
81 ecr 4294829106], length 1448
23:33:30.548871 IP (tos 0x0, ttl 53, id 63271, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x9558 (corr=
ect), seq 60817:62265, ack 125, win 9, options [nop,nop,TS val 34541704=
81 ecr 4294829106], length 1448
23:33:30.548881 IP (tos 0x0, ttl 100, id 40956, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x8428), ack 62265, win 4344, options [nop,nop,TS val 42948291=
71 ecr 3454170481], length 0
23:33:30.548993 IP (tos 0x0, ttl 53, id 63272, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x8fb0 (corr=
ect), seq 62265:63713, ack 125, win 9, options [nop,nop,TS val 34541704=
81 ecr 4294829106], length 1448
23:33:30.549116 IP (tos 0x0, ttl 53, id 63273, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [P.], cksum 0x8a00 (cor=
rect), seq 63713:65161, ack 125, win 9, options [nop,nop,TS val 3454170=
481 ecr 4294829106], length 1448
23:33:30.549128 IP (tos 0x0, ttl 100, id 40957, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x78d8), ack 65161, win 4344, options [nop,nop,TS val 42948291=
71 ecr 3454170481], length 0
23:33:30.549239 IP (tos 0x0, ttl 53, id 63274, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x8460 (corr=
ect), seq 65161:66609, ack 125, win 9, options [nop,nop,TS val 34541704=
81 ecr 4294829106], length 1448
23:33:30.549362 IP (tos 0x0, ttl 53, id 63275, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x7eb8 (corr=
ect), seq 66609:68057, ack 125, win 9, options [nop,nop,TS val 34541704=
81 ecr 4294829106], length 1448
23:33:30.549373 IP (tos 0x0, ttl 100, id 40958, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x6d87), ack 68057, win 4344, options [nop,nop,TS val 42948291=
72 ecr 3454170481], length 0
23:33:30.549485 IP (tos 0x0, ttl 53, id 63276, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x7910 (corr=
ect), seq 68057:69505, ack 125, win 9, options [nop,nop,TS val 34541704=
81 ecr 4294829106], length 1448
23:33:30.549609 IP (tos 0x0, ttl 53, id 63277, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x7368 (corr=
ect), seq 69505:70953, ack 125, win 9, options [nop,nop,TS val 34541704=
81 ecr 4294829106], length 1448
23:33:30.549621 IP (tos 0x0, ttl 100, id 40959, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x6237), ack 70953, win 4344, options [nop,nop,TS val 42948291=
72 ecr 3454170481], length 0
23:33:30.549738 IP (tos 0x0, ttl 53, id 63278, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x6dbf (corr=
ect), seq 70953:72401, ack 125, win 9, options [nop,nop,TS val 34541704=
81 ecr 4294829107], length 1448
23:33:30.549862 IP (tos 0x0, ttl 53, id 63279, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x6817 (corr=
ect), seq 72401:73849, ack 125, win 9, options [nop,nop,TS val 34541704=
81 ecr 4294829107], length 1448
23:33:30.549873 IP (tos 0x0, ttl 100, id 40960, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x56e7), ack 73849, win 4344, options [nop,nop,TS val 42948291=
72 ecr 3454170481], length 0
23:33:30.549984 IP (tos 0x0, ttl 53, id 63280, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x626f (corr=
ect), seq 73849:75297, ack 125, win 9, options [nop,nop,TS val 34541704=
81 ecr 4294829107], length 1448
23:33:30.550107 IP (tos 0x0, ttl 53, id 63281, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x5cc7 (corr=
ect), seq 75297:76745, ack 125, win 9, options [nop,nop,TS val 34541704=
81 ecr 4294829107], length 1448
23:33:30.550118 IP (tos 0x0, ttl 100, id 40961, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x4b97), ack 76745, win 4344, options [nop,nop,TS val 42948291=
72 ecr 3454170481], length 0
23:33:30.550231 IP (tos 0x0, ttl 53, id 63282, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x571f (corr=
ect), seq 76745:78193, ack 125, win 9, options [nop,nop,TS val 34541704=
81 ecr 4294829107], length 1448
23:33:30.550353 IP (tos 0x0, ttl 53, id 63283, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x5177 (corr=
ect), seq 78193:79641, ack 125, win 9, options [nop,nop,TS val 34541704=
81 ecr 4294829107], length 1448
23:33:30.550363 IP (tos 0x0, ttl 100, id 40962, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x4046), ack 79641, win 4344, options [nop,nop,TS val 42948291=
73 ecr 3454170481], length 0
23:33:30.550476 IP (tos 0x0, ttl 53, id 63284, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x4bcf (corr=
ect), seq 79641:81089, ack 125, win 9, options [nop,nop,TS val 34541704=
81 ecr 4294829107], length 1448
23:33:30.550600 IP (tos 0x0, ttl 53, id 63285, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x4627 (corr=
ect), seq 81089:82537, ack 125, win 9, options [nop,nop,TS val 34541704=
81 ecr 4294829107], length 1448
23:33:30.550610 IP (tos 0x0, ttl 100, id 40963, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x34f6), ack 82537, win 4344, options [nop,nop,TS val 42948291=
73 ecr 3454170481], length 0
23:33:30.550722 IP (tos 0x0, ttl 53, id 63286, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x407f (corr=
ect), seq 82537:83985, ack 125, win 9, options [nop,nop,TS val 34541704=
81 ecr 4294829107], length 1448
23:33:30.590287 IP (tos 0x0, ttl 100, id 40964, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x2f26), ack 83985, win 4344, options [nop,nop,TS val 42948292=
13 ecr 3454170481], length 0
23:33:30.611877 IP (tos 0x0, ttl 53, id 63287, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x3a88 (corr=
ect), seq 83985:85433, ack 125, win 9, options [nop,nop,TS val 34541704=
97 ecr 4294829170], length 1448
23:33:30.612000 IP (tos 0x0, ttl 53, id 63288, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x34e0 (corr=
ect), seq 85433:86881, ack 125, win 9, options [nop,nop,TS val 34541704=
97 ecr 4294829170], length 1448
23:33:30.612013 IP (tos 0x0, ttl 100, id 40965, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x23b1), ack 86881, win 4344, options [nop,nop,TS val 42948292=
34 ecr 3454170497], length 0
23:33:30.612123 IP (tos 0x0, ttl 53, id 63289, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x2f38 (corr=
ect), seq 86881:88329, ack 125, win 9, options [nop,nop,TS val 34541704=
97 ecr 4294829170], length 1448
23:33:30.612247 IP (tos 0x0, ttl 53, id 63290, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x2990 (corr=
ect), seq 88329:89777, ack 125, win 9, options [nop,nop,TS val 34541704=
97 ecr 4294829170], length 1448
23:33:30.612260 IP (tos 0x0, ttl 100, id 40966, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x1860), ack 89777, win 4344, options [nop,nop,TS val 42948292=
35 ecr 3454170497], length 0
23:33:30.612371 IP (tos 0x0, ttl 53, id 63291, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x23e8 (corr=
ect), seq 89777:91225, ack 125, win 9, options [nop,nop,TS val 34541704=
97 ecr 4294829170], length 1448
23:33:30.612493 IP (tos 0x0, ttl 53, id 63292, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x1e40 (corr=
ect), seq 91225:92673, ack 125, win 9, options [nop,nop,TS val 34541704=
97 ecr 4294829170], length 1448
23:33:30.612504 IP (tos 0x0, ttl 100, id 40967, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x0d10), ack 92673, win 4344, options [nop,nop,TS val 42948292=
35 ecr 3454170497], length 0
23:33:30.612616 IP (tos 0x0, ttl 53, id 63293, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x1898 (corr=
ect), seq 92673:94121, ack 125, win 9, options [nop,nop,TS val 34541704=
97 ecr 4294829170], length 1448
23:33:30.612739 IP (tos 0x0, ttl 53, id 63294, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x12f0 (corr=
ect), seq 94121:95569, ack 125, win 9, options [nop,nop,TS val 34541704=
97 ecr 4294829170], length 1448
23:33:30.612750 IP (tos 0x0, ttl 100, id 40968, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x01c0), ack 95569, win 4344, options [nop,nop,TS val 42948292=
35 ecr 3454170497], length 0
23:33:30.612862 IP (tos 0x0, ttl 53, id 63295, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x0d48 (corr=
ect), seq 95569:97017, ack 125, win 9, options [nop,nop,TS val 34541704=
97 ecr 4294829170], length 1448
23:33:30.612985 IP (tos 0x0, ttl 53, id 63296, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [P.], cksum 0x0798 (cor=
rect), seq 97017:98465, ack 125, win 9, options [nop,nop,TS val 3454170=
497 ecr 4294829170], length 1448
23:33:30.612996 IP (tos 0x0, ttl 100, id 40969, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0xf66f), ack 98465, win 4344, options [nop,nop,TS val 42948292=
35 ecr 3454170497], length 0
23:33:30.613108 IP (tos 0x0, ttl 53, id 63297, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x01f8 (corr=
ect), seq 98465:99913, ack 125, win 9, options [nop,nop,TS val 34541704=
97 ecr 4294829170], length 1448
23:33:30.613232 IP (tos 0x0, ttl 53, id 63298, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [P.], cksum 0xfc46 (cor=
rect), seq 99913:101361, ack 125, win 9, options [nop,nop,TS val 345417=
0497 ecr 4294829171], length 1448
23:33:30.613242 IP (tos 0x0, ttl 100, id 40970, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0xeb1e), ack 101361, win 4344, options [nop,nop,TS val 4294829=
236 ecr 3454170497], length 0
23:33:30.613354 IP (tos 0x0, ttl 53, id 63299, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xf6a6 (corr=
ect), seq 101361:102809, ack 125, win 9, options [nop,nop,TS val 345417=
0497 ecr 4294829171], length 1448
23:33:30.613477 IP (tos 0x0, ttl 53, id 63300, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xf0fe (corr=
ect), seq 102809:104257, ack 125, win 9, options [nop,nop,TS val 345417=
0497 ecr 4294829171], length 1448
23:33:30.613487 IP (tos 0x0, ttl 100, id 40971, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0xdfce), ack 104257, win 4344, options [nop,nop,TS val 4294829=
236 ecr 3454170497], length 0
23:33:30.613600 IP (tos 0x0, ttl 53, id 63301, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xeb56 (corr=
ect), seq 104257:105705, ack 125, win 9, options [nop,nop,TS val 345417=
0497 ecr 4294829171], length 1448
23:33:30.613723 IP (tos 0x0, ttl 53, id 63302, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xe5ae (corr=
ect), seq 105705:107153, ack 125, win 9, options [nop,nop,TS val 345417=
0497 ecr 4294829171], length 1448
23:33:30.613735 IP (tos 0x0, ttl 100, id 40972, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0xd3c9), ack 107153, win 4525, options [nop,nop,TS val 4294829=
236 ecr 3454170497], length 0
23:33:30.613846 IP (tos 0x0, ttl 53, id 63303, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xe006 (corr=
ect), seq 107153:108601, ack 125, win 9, options [nop,nop,TS val 345417=
0497 ecr 4294829171], length 1448
23:33:30.613857 IP (tos 0x0, ttl 100, id 40973, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0xcd6c), ack 108601, win 4706, options [nop,nop,TS val 4294829=
236 ecr 3454170497], length 0
23:33:30.613969 IP (tos 0x0, ttl 53, id 63304, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xda5e (corr=
ect), seq 108601:110049, ack 125, win 9, options [nop,nop,TS val 345417=
0497 ecr 4294829171], length 1448
23:33:30.613981 IP (tos 0x0, ttl 100, id 40974, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0xc70f), ack 110049, win 4887, options [nop,nop,TS val 4294829=
236 ecr 3454170497], length 0
23:33:30.614092 IP (tos 0x0, ttl 53, id 63305, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xd4b6 (corr=
ect), seq 110049:111497, ack 125, win 9, options [nop,nop,TS val 345417=
0497 ecr 4294829171], length 1448
23:33:30.614104 IP (tos 0x0, ttl 100, id 40975, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0xc0b2), ack 111497, win 5068, options [nop,nop,TS val 4294829=
236 ecr 3454170497], length 0
23:33:30.614216 IP (tos 0x0, ttl 53, id 63306, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xcf0e (corr=
ect), seq 111497:112945, ack 125, win 9, options [nop,nop,TS val 345417=
0497 ecr 4294829171], length 1448
23:33:30.614225 IP (tos 0x0, ttl 100, id 40976, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0xba54), ack 112945, win 5249, options [nop,nop,TS val 4294829=
237 ecr 3454170497], length 0
23:33:30.614343 IP (tos 0x0, ttl 53, id 63307, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xc966 (corr=
ect), seq 112945:114393, ack 125, win 9, options [nop,nop,TS val 345417=
0497 ecr 4294829171], length 1448
23:33:30.614354 IP (tos 0x0, ttl 100, id 40977, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0xb3f7), ack 114393, win 5430, options [nop,nop,TS val 4294829=
237 ecr 3454170497], length 0
23:33:30.614462 IP (tos 0x0, ttl 53, id 63308, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xc3be (corr=
ect), seq 114393:115841, ack 125, win 9, options [nop,nop,TS val 345417=
0497 ecr 4294829171], length 1448
23:33:30.614474 IP (tos 0x0, ttl 100, id 40978, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0xad9a), ack 115841, win 5611, options [nop,nop,TS val 4294829=
237 ecr 3454170497], length 0
23:33:30.614584 IP (tos 0x0, ttl 53, id 63309, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xbe16 (corr=
ect), seq 115841:117289, ack 125, win 9, options [nop,nop,TS val 345417=
0497 ecr 4294829171], length 1448
23:33:30.614597 IP (tos 0x0, ttl 100, id 40979, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0xa73d), ack 117289, win 5792, options [nop,nop,TS val 4294829=
237 ecr 3454170497], length 0
23:33:30.614707 IP (tos 0x0, ttl 53, id 63310, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xb86d (corr=
ect), seq 117289:118737, ack 125, win 9, options [nop,nop,TS val 345417=
0497 ecr 4294829172], length 1448
23:33:30.614718 IP (tos 0x0, ttl 100, id 40980, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0xa0e0), ack 118737, win 5973, options [nop,nop,TS val 4294829=
237 ecr 3454170497], length 0
23:33:30.614830 IP (tos 0x0, ttl 53, id 63311, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xb2c5 (corr=
ect), seq 118737:120185, ack 125, win 9, options [nop,nop,TS val 345417=
0497 ecr 4294829172], length 1448
23:33:30.614841 IP (tos 0x0, ttl 100, id 40981, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x9a83), ack 120185, win 6154, options [nop,nop,TS val 4294829=
237 ecr 3454170497], length 0
23:33:30.614958 IP (tos 0x0, ttl 53, id 63312, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xad1d (corr=
ect), seq 120185:121633, ack 125, win 9, options [nop,nop,TS val 345417=
0497 ecr 4294829172], length 1448
23:33:30.614970 IP (tos 0x0, ttl 100, id 40982, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x9426), ack 121633, win 6335, options [nop,nop,TS val 4294829=
237 ecr 3454170497], length 0
23:33:30.615077 IP (tos 0x0, ttl 53, id 63313, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xa775 (corr=
ect), seq 121633:123081, ack 125, win 9, options [nop,nop,TS val 345417=
0497 ecr 4294829172], length 1448
23:33:30.615088 IP (tos 0x0, ttl 100, id 40983, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x8dc9), ack 123081, win 6516, options [nop,nop,TS val 4294829=
237 ecr 3454170497], length 0
23:33:30.615200 IP (tos 0x0, ttl 53, id 63314, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xa1cd (corr=
ect), seq 123081:124529, ack 125, win 9, options [nop,nop,TS val 345417=
0497 ecr 4294829172], length 1448
23:33:30.615211 IP (tos 0x0, ttl 100, id 40984, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x876b), ack 124529, win 6697, options [nop,nop,TS val 4294829=
238 ecr 3454170497], length 0
23:33:30.615322 IP (tos 0x0, ttl 53, id 63315, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x9c25 (corr=
ect), seq 124529:125977, ack 125, win 9, options [nop,nop,TS val 345417=
0497 ecr 4294829172], length 1448
23:33:30.615334 IP (tos 0x0, ttl 100, id 40985, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x810e), ack 125977, win 6878, options [nop,nop,TS val 4294829=
238 ecr 3454170497], length 0
23:33:30.615444 IP (tos 0x0, ttl 53, id 63316, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x967d (corr=
ect), seq 125977:127425, ack 125, win 9, options [nop,nop,TS val 345417=
0497 ecr 4294829172], length 1448
23:33:30.615464 IP (tos 0x0, ttl 100, id 40986, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x7ab1), ack 127425, win 7059, options [nop,nop,TS val 4294829=
238 ecr 3454170497], length 0
23:33:30.615569 IP (tos 0x0, ttl 53, id 63317, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x90d5 (corr=
ect), seq 127425:128873, ack 125, win 9, options [nop,nop,TS val 345417=
0497 ecr 4294829172], length 1448
23:33:30.615578 IP (tos 0x0, ttl 100, id 40987, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x7454), ack 128873, win 7240, options [nop,nop,TS val 4294829=
238 ecr 3454170497], length 0
23:33:30.615697 IP (tos 0x0, ttl 53, id 63318, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x8b2d (corr=
ect), seq 128873:130321, ack 125, win 9, options [nop,nop,TS val 345417=
0497 ecr 4294829172], length 1448
23:33:30.615707 IP (tos 0x0, ttl 100, id 40988, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x6df7), ack 130321, win 7421, options [nop,nop,TS val 4294829=
238 ecr 3454170497], length 0
23:33:30.615815 IP (tos 0x0, ttl 53, id 63319, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x8585 (corr=
ect), seq 130321:131769, ack 125, win 9, options [nop,nop,TS val 345417=
0497 ecr 4294829172], length 1448
23:33:30.615828 IP (tos 0x0, ttl 100, id 40989, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x679a), ack 131769, win 7602, options [nop,nop,TS val 4294829=
238 ecr 3454170497], length 0
23:33:30.615938 IP (tos 0x0, ttl 53, id 63320, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x7fdd (corr=
ect), seq 131769:133217, ack 125, win 9, options [nop,nop,TS val 345417=
0497 ecr 4294829172], length 1448
23:33:30.616061 IP (tos 0x0, ttl 53, id 63321, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x7a35 (corr=
ect), seq 133217:134665, ack 125, win 9, options [nop,nop,TS val 345417=
0497 ecr 4294829172], length 1448
23:33:30.616073 IP (tos 0x0, ttl 100, id 40990, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x5c4a), ack 134665, win 7602, options [nop,nop,TS val 4294829=
238 ecr 3454170497], length 0
23:33:30.616184 IP (tos 0x0, ttl 53, id 63322, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x748c (corr=
ect), seq 134665:136113, ack 125, win 9, options [nop,nop,TS val 345417=
0497 ecr 4294829173], length 1448
23:33:30.616306 IP (tos 0x0, ttl 53, id 63323, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [P.], cksum 0x6edc (cor=
rect), seq 136113:137561, ack 125, win 9, options [nop,nop,TS val 34541=
70497 ecr 4294829173], length 1448
23:33:30.616317 IP (tos 0x0, ttl 100, id 40991, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x50f9), ack 137561, win 7602, options [nop,nop,TS val 4294829=
239 ecr 3454170497], length 0
23:33:30.616429 IP (tos 0x0, ttl 53, id 63324, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x693c (corr=
ect), seq 137561:139009, ack 125, win 9, options [nop,nop,TS val 345417=
0497 ecr 4294829173], length 1448
23:33:30.616553 IP (tos 0x0, ttl 53, id 63325, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x6394 (corr=
ect), seq 139009:140457, ack 125, win 9, options [nop,nop,TS val 345417=
0497 ecr 4294829173], length 1448
23:33:30.616564 IP (tos 0x0, ttl 100, id 40992, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x45a9), ack 140457, win 7602, options [nop,nop,TS val 4294829=
239 ecr 3454170497], length 0
23:33:30.616676 IP (tos 0x0, ttl 53, id 63326, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x5dec (corr=
ect), seq 140457:141905, ack 125, win 9, options [nop,nop,TS val 345417=
0497 ecr 4294829173], length 1448
23:33:30.616800 IP (tos 0x0, ttl 53, id 63327, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x5844 (corr=
ect), seq 141905:143353, ack 125, win 9, options [nop,nop,TS val 345417=
0497 ecr 4294829173], length 1448
23:33:30.616812 IP (tos 0x0, ttl 100, id 40993, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x3a59), ack 143353, win 7602, options [nop,nop,TS val 4294829=
239 ecr 3454170497], length 0
23:33:30.654648 IP (tos 0x0, ttl 53, id 63328, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x526a (corr=
ect), seq 143353:144801, ack 125, win 9, options [nop,nop,TS val 345417=
0507 ecr 4294829213], length 1448
23:33:30.654771 IP (tos 0x0, ttl 53, id 63329, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x4cc2 (corr=
ect), seq 144801:146249, ack 125, win 9, options [nop,nop,TS val 345417=
0507 ecr 4294829213], length 1448
23:33:30.654784 IP (tos 0x0, ttl 100, id 40994, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x2ed9), ack 146249, win 7602, options [nop,nop,TS val 4294829=
277 ecr 3454170507], length 0
23:33:30.676418 IP (tos 0x0, ttl 53, id 63330, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x46ff (corr=
ect), seq 146249:147697, ack 125, win 9, options [nop,nop,TS val 345417=
0513 ecr 4294829234], length 1448
23:33:30.676541 IP (tos 0x0, ttl 53, id 63331, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x4157 (corr=
ect), seq 147697:149145, ack 125, win 9, options [nop,nop,TS val 345417=
0513 ecr 4294829234], length 1448
23:33:30.676554 IP (tos 0x0, ttl 100, id 40995, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x236d), ack 149145, win 7602, options [nop,nop,TS val 4294829=
299 ecr 3454170513], length 0
23:33:30.676663 IP (tos 0x0, ttl 53, id 63332, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x3baf (corr=
ect), seq 149145:150593, ack 125, win 9, options [nop,nop,TS val 345417=
0513 ecr 4294829234], length 1448
23:33:30.676787 IP (tos 0x0, ttl 53, id 63333, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [P.], cksum 0x35fe (cor=
rect), seq 150593:152041, ack 125, win 9, options [nop,nop,TS val 34541=
70513 ecr 4294829235], length 1448
23:33:30.676799 IP (tos 0x0, ttl 100, id 40996, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x181d), ack 152041, win 7602, options [nop,nop,TS val 4294829=
299 ecr 3454170513], length 0
23:33:30.676911 IP (tos 0x0, ttl 53, id 63334, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x305e (corr=
ect), seq 152041:153489, ack 125, win 9, options [nop,nop,TS val 345417=
0513 ecr 4294829235], length 1448
23:33:30.677034 IP (tos 0x0, ttl 53, id 63335, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x2ab6 (corr=
ect), seq 153489:154937, ack 125, win 9, options [nop,nop,TS val 345417=
0513 ecr 4294829235], length 1448
23:33:30.677044 IP (tos 0x0, ttl 100, id 40997, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x0ccd), ack 154937, win 7602, options [nop,nop,TS val 4294829=
299 ecr 3454170513], length 0
23:33:30.677156 IP (tos 0x0, ttl 53, id 63336, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x250e (corr=
ect), seq 154937:156385, ack 125, win 9, options [nop,nop,TS val 345417=
0513 ecr 4294829235], length 1448
23:33:30.677280 IP (tos 0x0, ttl 53, id 63337, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x1f66 (corr=
ect), seq 156385:157833, ack 125, win 9, options [nop,nop,TS val 345417=
0513 ecr 4294829235], length 1448
23:33:30.677290 IP (tos 0x0, ttl 100, id 40998, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x017c), ack 157833, win 7602, options [nop,nop,TS val 4294829=
300 ecr 3454170513], length 0
23:33:30.677402 IP (tos 0x0, ttl 53, id 63338, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x19be (corr=
ect), seq 157833:159281, ack 125, win 9, options [nop,nop,TS val 345417=
0513 ecr 4294829235], length 1448
23:33:30.677525 IP (tos 0x0, ttl 53, id 63339, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x1416 (corr=
ect), seq 159281:160729, ack 125, win 9, options [nop,nop,TS val 345417=
0513 ecr 4294829235], length 1448
23:33:30.677537 IP (tos 0x0, ttl 100, id 40999, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0xf62b), ack 160729, win 7602, options [nop,nop,TS val 4294829=
300 ecr 3454170513], length 0
23:33:30.677649 IP (tos 0x0, ttl 53, id 63340, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x0e6e (corr=
ect), seq 160729:162177, ack 125, win 9, options [nop,nop,TS val 345417=
0513 ecr 4294829235], length 1448
23:33:30.677771 IP (tos 0x0, ttl 53, id 63341, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x08c6 (corr=
ect), seq 162177:163625, ack 125, win 9, options [nop,nop,TS val 345417=
0513 ecr 4294829235], length 1448
23:33:30.677783 IP (tos 0x0, ttl 100, id 41000, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0xeadb), ack 163625, win 7602, options [nop,nop,TS val 4294829=
300 ecr 3454170513], length 0
23:33:30.677895 IP (tos 0x0, ttl 53, id 63342, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x031e (corr=
ect), seq 163625:165073, ack 125, win 9, options [nop,nop,TS val 345417=
0513 ecr 4294829235], length 1448
23:33:30.678018 IP (tos 0x0, ttl 53, id 63343, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xfd75 (corr=
ect), seq 165073:166521, ack 125, win 9, options [nop,nop,TS val 345417=
0513 ecr 4294829235], length 1448
23:33:30.678028 IP (tos 0x0, ttl 100, id 41001, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0xdf8b), ack 166521, win 7602, options [nop,nop,TS val 4294829=
300 ecr 3454170513], length 0
23:33:30.678140 IP (tos 0x0, ttl 53, id 63344, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xf7cd (corr=
ect), seq 166521:167969, ack 125, win 9, options [nop,nop,TS val 345417=
0513 ecr 4294829235], length 1448
23:33:30.678278 IP (tos 0x0, ttl 53, id 63345, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xf224 (corr=
ect), seq 167969:169417, ack 125, win 9, options [nop,nop,TS val 345417=
0513 ecr 4294829236], length 1448
23:33:30.678290 IP (tos 0x0, ttl 100, id 41002, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0xd385), ack 169417, win 7783, options [nop,nop,TS val 4294829=
301 ecr 3454170513], length 0
23:33:30.678400 IP (tos 0x0, ttl 53, id 63346, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xec7c (corr=
ect), seq 169417:170865, ack 125, win 9, options [nop,nop,TS val 345417=
0513 ecr 4294829236], length 1448
23:33:30.678523 IP (tos 0x0, ttl 53, id 63347, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xe6d4 (corr=
ect), seq 170865:172313, ack 125, win 9, options [nop,nop,TS val 345417=
0513 ecr 4294829236], length 1448
23:33:30.678533 IP (tos 0x0, ttl 100, id 41003, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0xc835), ack 172313, win 7783, options [nop,nop,TS val 4294829=
301 ecr 3454170513], length 0
23:33:30.678646 IP (tos 0x0, ttl 53, id 63348, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xe12c (corr=
ect), seq 172313:173761, ack 125, win 9, options [nop,nop,TS val 345417=
0513 ecr 4294829236], length 1448
23:33:30.678770 IP (tos 0x0, ttl 53, id 63349, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xdb84 (corr=
ect), seq 173761:175209, ack 125, win 9, options [nop,nop,TS val 345417=
0513 ecr 4294829236], length 1448
23:33:30.678782 IP (tos 0x0, ttl 100, id 41004, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0xbce5), ack 175209, win 7783, options [nop,nop,TS val 4294829=
301 ecr 3454170513], length 0
23:33:30.678893 IP (tos 0x0, ttl 53, id 63350, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xd5dc (corr=
ect), seq 175209:176657, ack 125, win 9, options [nop,nop,TS val 345417=
0513 ecr 4294829236], length 1448
23:33:30.679016 IP (tos 0x0, ttl 53, id 63351, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xd034 (corr=
ect), seq 176657:178105, ack 125, win 9, options [nop,nop,TS val 345417=
0513 ecr 4294829236], length 1448
23:33:30.679026 IP (tos 0x0, ttl 100, id 41005, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0xb195), ack 178105, win 7783, options [nop,nop,TS val 4294829=
301 ecr 3454170513], length 0
23:33:30.679138 IP (tos 0x0, ttl 53, id 63352, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xca8c (corr=
ect), seq 178105:179553, ack 125, win 9, options [nop,nop,TS val 345417=
0513 ecr 4294829236], length 1448
23:33:30.679262 IP (tos 0x0, ttl 53, id 63353, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xc4e4 (corr=
ect), seq 179553:181001, ack 125, win 9, options [nop,nop,TS val 345417=
0513 ecr 4294829236], length 1448
23:33:30.679273 IP (tos 0x0, ttl 100, id 41006, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0xa644), ack 181001, win 7783, options [nop,nop,TS val 4294829=
302 ecr 3454170513], length 0
23:33:30.679386 IP (tos 0x0, ttl 53, id 63354, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xbf3c (corr=
ect), seq 181001:182449, ack 125, win 9, options [nop,nop,TS val 345417=
0513 ecr 4294829236], length 1448
23:33:30.679507 IP (tos 0x0, ttl 53, id 63355, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xb994 (corr=
ect), seq 182449:183897, ack 125, win 9, options [nop,nop,TS val 345417=
0513 ecr 4294829236], length 1448
23:33:30.679518 IP (tos 0x0, ttl 100, id 41007, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x9af4), ack 183897, win 7783, options [nop,nop,TS val 4294829=
302 ecr 3454170513], length 0
23:33:30.679631 IP (tos 0x0, ttl 53, id 63356, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xb3ec (corr=
ect), seq 183897:185345, ack 125, win 9, options [nop,nop,TS val 345417=
0513 ecr 4294829236], length 1448
23:33:30.679754 IP (tos 0x0, ttl 53, id 63357, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xae44 (corr=
ect), seq 185345:186793, ack 125, win 9, options [nop,nop,TS val 345417=
0513 ecr 4294829236], length 1448
23:33:30.679764 IP (tos 0x0, ttl 100, id 41008, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x8fa4), ack 186793, win 7783, options [nop,nop,TS val 4294829=
302 ecr 3454170513], length 0
23:33:30.679877 IP (tos 0x0, ttl 53, id 63358, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [P.], cksum 0xa894 (cor=
rect), seq 186793:188241, ack 125, win 9, options [nop,nop,TS val 34541=
70513 ecr 4294829236], length 1448
23:33:30.680000 IP (tos 0x0, ttl 53, id 63359, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xa2f4 (corr=
ect), seq 188241:189689, ack 125, win 9, options [nop,nop,TS val 345417=
0513 ecr 4294829236], length 1448
23:33:30.680011 IP (tos 0x0, ttl 100, id 41009, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x8454), ack 189689, win 7783, options [nop,nop,TS val 4294829=
302 ecr 3454170513], length 0
23:33:30.680122 IP (tos 0x0, ttl 53, id 63360, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x9d4b (corr=
ect), seq 189689:191137, ack 125, win 9, options [nop,nop,TS val 345417=
0513 ecr 4294829237], length 1448
23:33:30.680246 IP (tos 0x0, ttl 53, id 63361, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x97a3 (corr=
ect), seq 191137:192585, ack 125, win 9, options [nop,nop,TS val 345417=
0513 ecr 4294829237], length 1448
23:33:30.680258 IP (tos 0x0, ttl 100, id 41010, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x7903), ack 192585, win 7783, options [nop,nop,TS val 4294829=
303 ecr 3454170513], length 0
23:33:30.680369 IP (tos 0x0, ttl 53, id 63362, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x91fb (corr=
ect), seq 192585:194033, ack 125, win 9, options [nop,nop,TS val 345417=
0513 ecr 4294829237], length 1448
23:33:30.680492 IP (tos 0x0, ttl 53, id 63363, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x8c53 (corr=
ect), seq 194033:195481, ack 125, win 9, options [nop,nop,TS val 345417=
0513 ecr 4294829237], length 1448
23:33:30.680504 IP (tos 0x0, ttl 100, id 41011, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x6db3), ack 195481, win 7783, options [nop,nop,TS val 4294829=
303 ecr 3454170513], length 0
23:33:30.680616 IP (tos 0x0, ttl 53, id 63364, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x86ab (corr=
ect), seq 195481:196929, ack 125, win 9, options [nop,nop,TS val 345417=
0513 ecr 4294829237], length 1448
23:33:30.680738 IP (tos 0x0, ttl 53, id 63365, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x8103 (corr=
ect), seq 196929:198377, ack 125, win 9, options [nop,nop,TS val 345417=
0513 ecr 4294829237], length 1448
23:33:30.680750 IP (tos 0x0, ttl 100, id 41012, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x6263), ack 198377, win 7783, options [nop,nop,TS val 4294829=
303 ecr 3454170513], length 0
23:33:30.680861 IP (tos 0x0, ttl 53, id 63366, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x7b5b (corr=
ect), seq 198377:199825, ack 125, win 9, options [nop,nop,TS val 345417=
0513 ecr 4294829237], length 1448
23:33:30.680985 IP (tos 0x0, ttl 53, id 63367, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x75b3 (corr=
ect), seq 199825:201273, ack 125, win 9, options [nop,nop,TS val 345417=
0513 ecr 4294829237], length 1448
23:33:30.680997 IP (tos 0x0, ttl 100, id 41013, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x5713), ack 201273, win 7783, options [nop,nop,TS val 4294829=
303 ecr 3454170513], length 0
23:33:30.681107 IP (tos 0x0, ttl 53, id 63368, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x700b (corr=
ect), seq 201273:202721, ack 125, win 9, options [nop,nop,TS val 345417=
0513 ecr 4294829237], length 1448
23:33:30.681230 IP (tos 0x0, ttl 53, id 63369, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x6a63 (corr=
ect), seq 202721:204169, ack 125, win 9, options [nop,nop,TS val 345417=
0513 ecr 4294829237], length 1448
23:33:30.681240 IP (tos 0x0, ttl 100, id 41014, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x4bc2), ack 204169, win 7783, options [nop,nop,TS val 4294829=
304 ecr 3454170513], length 0
23:33:30.681354 IP (tos 0x0, ttl 53, id 63370, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x64bb (corr=
ect), seq 204169:205617, ack 125, win 9, options [nop,nop,TS val 345417=
0513 ecr 4294829237], length 1448
23:33:30.681476 IP (tos 0x0, ttl 53, id 63371, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x5f13 (corr=
ect), seq 205617:207065, ack 125, win 9, options [nop,nop,TS val 345417=
0513 ecr 4294829237], length 1448
23:33:30.681488 IP (tos 0x0, ttl 100, id 41015, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x4072), ack 207065, win 7783, options [nop,nop,TS val 4294829=
304 ecr 3454170513], length 0
23:33:30.681600 IP (tos 0x0, ttl 53, id 63372, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x596b (corr=
ect), seq 207065:208513, ack 125, win 9, options [nop,nop,TS val 345417=
0513 ecr 4294829237], length 1448
23:33:30.681722 IP (tos 0x0, ttl 53, id 63373, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x53c3 (corr=
ect), seq 208513:209961, ack 125, win 9, options [nop,nop,TS val 345417=
0513 ecr 4294829237], length 1448
23:33:30.681732 IP (tos 0x0, ttl 100, id 41016, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x3522), ack 209961, win 7783, options [nop,nop,TS val 4294829=
304 ecr 3454170513], length 0
23:33:30.681845 IP (tos 0x0, ttl 53, id 63374, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x4e1b (corr=
ect), seq 209961:211409, ack 125, win 9, options [nop,nop,TS val 345417=
0513 ecr 4294829237], length 1448
23:33:30.681968 IP (tos 0x0, ttl 53, id 63375, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x4873 (corr=
ect), seq 211409:212857, ack 125, win 9, options [nop,nop,TS val 345417=
0513 ecr 4294829237], length 1448
23:33:30.681981 IP (tos 0x0, ttl 100, id 41017, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x29d2), ack 212857, win 7783, options [nop,nop,TS val 4294829=
304 ecr 3454170513], length 0
23:33:30.682091 IP (tos 0x0, ttl 53, id 63376, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x42c9 (corr=
ect), seq 212857:214305, ack 125, win 9, options [nop,nop,TS val 345417=
0514 ecr 4294829238], length 1448
23:33:30.682215 IP (tos 0x0, ttl 53, id 63377, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x3d21 (corr=
ect), seq 214305:215753, ack 125, win 9, options [nop,nop,TS val 345417=
0514 ecr 4294829238], length 1448
23:33:30.682226 IP (tos 0x0, ttl 100, id 41018, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x1e80), ack 215753, win 7783, options [nop,nop,TS val 4294829=
305 ecr 3454170514], length 0
23:33:30.682338 IP (tos 0x0, ttl 53, id 63378, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x3779 (corr=
ect), seq 215753:217201, ack 125, win 9, options [nop,nop,TS val 345417=
0514 ecr 4294829238], length 1448
23:33:30.682460 IP (tos 0x0, ttl 53, id 63379, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x31d1 (corr=
ect), seq 217201:218649, ack 125, win 9, options [nop,nop,TS val 345417=
0514 ecr 4294829238], length 1448
23:33:30.682472 IP (tos 0x0, ttl 100, id 41019, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x1330), ack 218649, win 7783, options [nop,nop,TS val 4294829=
305 ecr 3454170514], length 0
23:33:30.682583 IP (tos 0x0, ttl 53, id 63380, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [P.], cksum 0x2c21 (cor=
rect), seq 218649:220097, ack 125, win 9, options [nop,nop,TS val 34541=
70514 ecr 4294829238], length 1448
23:33:30.682706 IP (tos 0x0, ttl 53, id 63381, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x2681 (corr=
ect), seq 220097:221545, ack 125, win 9, options [nop,nop,TS val 345417=
0514 ecr 4294829238], length 1448
23:33:30.682718 IP (tos 0x0, ttl 100, id 41020, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x07e0), ack 221545, win 7783, options [nop,nop,TS val 4294829=
305 ecr 3454170514], length 0
23:33:30.682829 IP (tos 0x0, ttl 53, id 63382, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x20d9 (corr=
ect), seq 221545:222993, ack 125, win 9, options [nop,nop,TS val 345417=
0514 ecr 4294829238], length 1448
23:33:30.682953 IP (tos 0x0, ttl 53, id 63383, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x1b31 (corr=
ect), seq 222993:224441, ack 125, win 9, options [nop,nop,TS val 345417=
0514 ecr 4294829238], length 1448
23:33:30.682963 IP (tos 0x0, ttl 100, id 41021, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0xfc8f), ack 224441, win 7783, options [nop,nop,TS val 4294829=
305 ecr 3454170514], length 0
23:33:30.683076 IP (tos 0x0, ttl 53, id 63384, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x1589 (corr=
ect), seq 224441:225889, ack 125, win 9, options [nop,nop,TS val 345417=
0514 ecr 4294829238], length 1448
23:33:30.683199 IP (tos 0x0, ttl 53, id 63385, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x0fe1 (corr=
ect), seq 225889:227337, ack 125, win 9, options [nop,nop,TS val 345417=
0514 ecr 4294829238], length 1448
23:33:30.683209 IP (tos 0x0, ttl 100, id 41022, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0xf13e), ack 227337, win 7783, options [nop,nop,TS val 4294829=
306 ecr 3454170514], length 0
23:33:30.683323 IP (tos 0x0, ttl 53, id 63386, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x0a39 (corr=
ect), seq 227337:228785, ack 125, win 9, options [nop,nop,TS val 345417=
0514 ecr 4294829238], length 1448
23:33:30.683445 IP (tos 0x0, ttl 53, id 63387, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x0491 (corr=
ect), seq 228785:230233, ack 125, win 9, options [nop,nop,TS val 345417=
0514 ecr 4294829238], length 1448
23:33:30.683455 IP (tos 0x0, ttl 100, id 41023, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0xe5ee), ack 230233, win 7783, options [nop,nop,TS val 4294829=
306 ecr 3454170514], length 0
23:33:30.683568 IP (tos 0x0, ttl 53, id 63388, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xfee8 (corr=
ect), seq 230233:231681, ack 125, win 9, options [nop,nop,TS val 345417=
0514 ecr 4294829238], length 1448
23:33:30.683690 IP (tos 0x0, ttl 53, id 63389, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xf940 (corr=
ect), seq 231681:233129, ack 125, win 9, options [nop,nop,TS val 345417=
0514 ecr 4294829238], length 1448
23:33:30.683701 IP (tos 0x0, ttl 100, id 41024, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0xda9e), ack 233129, win 7783, options [nop,nop,TS val 4294829=
306 ecr 3454170514], length 0
23:33:30.683814 IP (tos 0x0, ttl 53, id 63390, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xf398 (corr=
ect), seq 233129:234577, ack 125, win 9, options [nop,nop,TS val 345417=
0514 ecr 4294829238], length 1448
23:33:30.683938 IP (tos 0x0, ttl 53, id 63391, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xedef (corr=
ect), seq 234577:236025, ack 125, win 9, options [nop,nop,TS val 345417=
0514 ecr 4294829239], length 1448
23:33:30.683948 IP (tos 0x0, ttl 100, id 41025, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0xcf4e), ack 236025, win 7783, options [nop,nop,TS val 4294829=
306 ecr 3454170514], length 0
23:33:30.684060 IP (tos 0x0, ttl 53, id 63392, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xe847 (corr=
ect), seq 236025:237473, ack 125, win 9, options [nop,nop,TS val 345417=
0514 ecr 4294829239], length 1448
23:33:30.684183 IP (tos 0x0, ttl 53, id 63393, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xe29f (corr=
ect), seq 237473:238921, ack 125, win 9, options [nop,nop,TS val 345417=
0514 ecr 4294829239], length 1448
23:33:30.684195 IP (tos 0x0, ttl 100, id 41026, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0xc3fd), ack 238921, win 7783, options [nop,nop,TS val 4294829=
307 ecr 3454170514], length 0
23:33:30.684306 IP (tos 0x0, ttl 53, id 63394, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xdcf7 (corr=
ect), seq 238921:240369, ack 125, win 9, options [nop,nop,TS val 345417=
0514 ecr 4294829239], length 1448
23:33:30.684429 IP (tos 0x0, ttl 53, id 63395, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xd74f (corr=
ect), seq 240369:241817, ack 125, win 9, options [nop,nop,TS val 345417=
0514 ecr 4294829239], length 1448
23:33:30.684441 IP (tos 0x0, ttl 100, id 41027, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0xb8ad), ack 241817, win 7783, options [nop,nop,TS val 4294829=
307 ecr 3454170514], length 0
23:33:30.684552 IP (tos 0x0, ttl 53, id 63396, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xd1a7 (corr=
ect), seq 241817:243265, ack 125, win 9, options [nop,nop,TS val 345417=
0514 ecr 4294829239], length 1448
23:33:30.684676 IP (tos 0x0, ttl 53, id 63397, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xcbff (corr=
ect), seq 243265:244713, ack 125, win 9, options [nop,nop,TS val 345417=
0514 ecr 4294829239], length 1448
23:33:30.684688 IP (tos 0x0, ttl 100, id 41028, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0xad5d), ack 244713, win 7783, options [nop,nop,TS val 4294829=
307 ecr 3454170514], length 0
23:33:30.684798 IP (tos 0x0, ttl 53, id 63398, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xc657 (corr=
ect), seq 244713:246161, ack 125, win 9, options [nop,nop,TS val 345417=
0514 ecr 4294829239], length 1448
23:33:30.684922 IP (tos 0x0, ttl 53, id 63399, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xc0af (corr=
ect), seq 246161:247609, ack 125, win 9, options [nop,nop,TS val 345417=
0514 ecr 4294829239], length 1448
23:33:30.684934 IP (tos 0x0, ttl 100, id 41029, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0xa20d), ack 247609, win 7783, options [nop,nop,TS val 4294829=
307 ecr 3454170514], length 0
23:33:30.719125 IP (tos 0x0, ttl 53, id 63400, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xbad8 (corr=
ect), seq 247609:249057, ack 125, win 9, options [nop,nop,TS val 345417=
0523 ecr 4294829277], length 1448
23:33:30.719249 IP (tos 0x0, ttl 53, id 63401, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xb530 (corr=
ect), seq 249057:250505, ack 125, win 9, options [nop,nop,TS val 345417=
0523 ecr 4294829277], length 1448
23:33:30.719260 IP (tos 0x0, ttl 100, id 41030, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x9691), ack 250505, win 7783, options [nop,nop,TS val 4294829=
342 ecr 3454170523], length 0
23:33:30.719371 IP (tos 0x0, ttl 53, id 63402, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xaf88 (corr=
ect), seq 250505:251953, ack 125, win 9, options [nop,nop,TS val 345417=
0523 ecr 4294829277], length 1448
23:33:30.740920 IP (tos 0x0, ttl 53, id 63403, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xa9c4 (corr=
ect), seq 251953:253401, ack 125, win 9, options [nop,nop,TS val 345417=
0529 ecr 4294829299], length 1448
23:33:30.740931 IP (tos 0x0, ttl 100, id 41031, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x8b2c), ack 253401, win 7783, options [nop,nop,TS val 4294829=
363 ecr 3454170523], length 0
23:33:30.741043 IP (tos 0x0, ttl 53, id 63404, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xa41c (corr=
ect), seq 253401:254849, ack 125, win 9, options [nop,nop,TS val 345417=
0529 ecr 4294829299], length 1448
23:33:30.741171 IP (tos 0x0, ttl 53, id 63405, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x9e74 (corr=
ect), seq 254849:256297, ack 125, win 9, options [nop,nop,TS val 345417=
0529 ecr 4294829299], length 1448
23:33:30.741184 IP (tos 0x0, ttl 100, id 41032, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x7fd5), ack 256297, win 7783, options [nop,nop,TS val 4294829=
364 ecr 3454170529], length 0
23:33:30.741290 IP (tos 0x0, ttl 53, id 63406, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x98cc (corr=
ect), seq 256297:257745, ack 125, win 9, options [nop,nop,TS val 345417=
0529 ecr 4294829299], length 1448
23:33:30.741412 IP (tos 0x0, ttl 53, id 63407, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x9324 (corr=
ect), seq 257745:259193, ack 125, win 9, options [nop,nop,TS val 345417=
0529 ecr 4294829299], length 1448
23:33:30.741425 IP (tos 0x0, ttl 100, id 41033, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x7485), ack 259193, win 7783, options [nop,nop,TS val 4294829=
364 ecr 3454170529], length 0
23:33:30.741535 IP (tos 0x0, ttl 53, id 63408, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x8d7c (corr=
ect), seq 259193:260641, ack 125, win 9, options [nop,nop,TS val 345417=
0529 ecr 4294829299], length 1448
23:33:30.741658 IP (tos 0x0, ttl 53, id 63409, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x87d4 (corr=
ect), seq 260641:262089, ack 125, win 9, options [nop,nop,TS val 345417=
0529 ecr 4294829299], length 1448
23:33:30.741669 IP (tos 0x0, ttl 100, id 41034, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x6935), ack 262089, win 7783, options [nop,nop,TS val 4294829=
364 ecr 3454170529], length 0
23:33:30.741782 IP (tos 0x0, ttl 53, id 63410, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x822c (corr=
ect), seq 262089:263537, ack 125, win 9, options [nop,nop,TS val 345417=
0529 ecr 4294829299], length 1448
23:33:30.741904 IP (tos 0x0, ttl 53, id 63411, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x7c84 (corr=
ect), seq 263537:264985, ack 125, win 9, options [nop,nop,TS val 345417=
0529 ecr 4294829299], length 1448
23:33:30.741916 IP (tos 0x0, ttl 100, id 41035, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x5de5), ack 264985, win 7783, options [nop,nop,TS val 4294829=
364 ecr 3454170529], length 0
300 packets captured
300 packets received by filter
0 packets dropped by kernel


=20
> - tcpdump of _last_ 300 or so packets, to see the steady-state dynami=
cs
>  with receiver window and packet inter-arrival times




tcpdump: listening on eth0, link-type EN10MB (Ethernet), capture size 6=
5535 bytes
23:36:59.155010 IP (tos 0x0, ttl 100, id 18644, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x51fc), ack 8424464, win 21177, options [nop,nop,TS val 70481=
 ecr 3454222632], length 0
23:36:59.155294 IP (tos 0x0, ttl 53, id 18141, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x9f43 (corr=
ect), seq 8424464:8425912, ack 1, win 9, options [nop,nop,TS val 345422=
2633 ecr 70417], length 1448
23:36:59.155417 IP (tos 0x0, ttl 53, id 18142, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x999b (corr=
ect), seq 8425912:8427360, ack 1, win 9, options [nop,nop,TS val 345422=
2633 ecr 70417], length 1448
23:36:59.155427 IP (tos 0x0, ttl 100, id 18645, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x46aa), ack 8427360, win 21177, options [nop,nop,TS val 70482=
 ecr 3454222633], length 0
23:36:59.156459 IP (tos 0x0, ttl 53, id 18143, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x93f2 (corr=
ect), seq 8427360:8428808, ack 1, win 9, options [nop,nop,TS val 345422=
2633 ecr 70418], length 1448
23:36:59.156581 IP (tos 0x0, ttl 53, id 18144, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x8e4a (corr=
ect), seq 8428808:8430256, ack 1, win 9, options [nop,nop,TS val 345422=
2633 ecr 70418], length 1448
23:36:59.156591 IP (tos 0x0, ttl 100, id 18646, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x3b59), ack 8430256, win 21177, options [nop,nop,TS val 70483=
 ecr 3454222633], length 0
23:36:59.157355 IP (tos 0x0, ttl 53, id 18145, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x88a1 (corr=
ect), seq 8430256:8431704, ack 1, win 9, options [nop,nop,TS val 345422=
2633 ecr 70419], length 1448
23:36:59.157478 IP (tos 0x0, ttl 53, id 18146, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x82f9 (corr=
ect), seq 8431704:8433152, ack 1, win 9, options [nop,nop,TS val 345422=
2633 ecr 70419], length 1448
23:36:59.157489 IP (tos 0x0, ttl 100, id 18647, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x3008), ack 8433152, win 21177, options [nop,nop,TS val 70484=
 ecr 3454222633], length 0
23:36:59.157600 IP (tos 0x0, ttl 53, id 18147, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x7d50 (corr=
ect), seq 8433152:8434600, ack 1, win 9, options [nop,nop,TS val 345422=
2633 ecr 70420], length 1448
23:36:59.157724 IP (tos 0x0, ttl 53, id 18148, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x77a8 (corr=
ect), seq 8434600:8436048, ack 1, win 9, options [nop,nop,TS val 345422=
2633 ecr 70420], length 1448
23:36:59.157735 IP (tos 0x0, ttl 100, id 18648, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x24b8), ack 8436048, win 21177, options [nop,nop,TS val 70484=
 ecr 3454222633], length 0
23:36:59.157915 IP (tos 0x0, ttl 53, id 18149, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x7200 (corr=
ect), seq 8436048:8437496, ack 1, win 9, options [nop,nop,TS val 345422=
2633 ecr 70420], length 1448
23:36:59.158038 IP (tos 0x0, ttl 53, id 18150, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x6c58 (corr=
ect), seq 8437496:8438944, ack 1, win 9, options [nop,nop,TS val 345422=
2633 ecr 70420], length 1448
23:36:59.158048 IP (tos 0x0, ttl 100, id 18649, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x1968), ack 8438944, win 21177, options [nop,nop,TS val 70484=
 ecr 3454222633], length 0
23:36:59.158281 IP (tos 0x0, ttl 53, id 18151, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x66b0 (corr=
ect), seq 8438944:8440392, ack 1, win 9, options [nop,nop,TS val 345422=
2633 ecr 70420], length 1448
23:36:59.158404 IP (tos 0x0, ttl 53, id 18152, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x6108 (corr=
ect), seq 8440392:8441840, ack 1, win 9, options [nop,nop,TS val 345422=
2633 ecr 70420], length 1448
23:36:59.158414 IP (tos 0x0, ttl 100, id 18650, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x0e17), ack 8441840, win 21177, options [nop,nop,TS val 70485=
 ecr 3454222633], length 0
23:36:59.158842 IP (tos 0x0, ttl 53, id 18153, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x5b5f (corr=
ect), seq 8441840:8443288, ack 1, win 9, options [nop,nop,TS val 345422=
2633 ecr 70421], length 1448
23:36:59.158966 IP (tos 0x0, ttl 53, id 18154, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x55b7 (corr=
ect), seq 8443288:8444736, ack 1, win 9, options [nop,nop,TS val 345422=
2633 ecr 70421], length 1448
23:36:59.158976 IP (tos 0x0, ttl 100, id 18651, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x02c7), ack 8444736, win 21177, options [nop,nop,TS val 70485=
 ecr 3454222633], length 0
23:36:59.159757 IP (tos 0x0, ttl 53, id 18155, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x500d (corr=
ect), seq 8444736:8446184, ack 1, win 9, options [nop,nop,TS val 345422=
2634 ecr 70422], length 1448
23:36:59.159880 IP (tos 0x0, ttl 53, id 18156, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x4a65 (corr=
ect), seq 8446184:8447632, ack 1, win 9, options [nop,nop,TS val 345422=
2634 ecr 70422], length 1448
23:36:59.159890 IP (tos 0x0, ttl 100, id 18652, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0xf774), ack 8447632, win 21177, options [nop,nop,TS val 70486=
 ecr 3454222634], length 0
23:36:59.160686 IP (tos 0x0, ttl 53, id 18157, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x44bc (corr=
ect), seq 8447632:8449080, ack 1, win 9, options [nop,nop,TS val 345422=
2634 ecr 70423], length 1448
23:36:59.160808 IP (tos 0x0, ttl 53, id 18158, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x3f14 (corr=
ect), seq 8449080:8450528, ack 1, win 9, options [nop,nop,TS val 345422=
2634 ecr 70423], length 1448
23:36:59.160820 IP (tos 0x0, ttl 100, id 18653, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0xec23), ack 8450528, win 21177, options [nop,nop,TS val 70487=
 ecr 3454222634], length 0
23:36:59.163216 IP (tos 0x0, ttl 53, id 18159, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x3969 (corr=
ect), seq 8450528:8451976, ack 1, win 9, options [nop,nop,TS val 345422=
2635 ecr 70425], length 1448
23:36:59.163338 IP (tos 0x0, ttl 53, id 18160, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x33c1 (corr=
ect), seq 8451976:8453424, ack 1, win 9, options [nop,nop,TS val 345422=
2635 ecr 70425], length 1448
23:36:59.163350 IP (tos 0x0, ttl 100, id 18654, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0xe0cf), ack 8453424, win 21177, options [nop,nop,TS val 70490=
 ecr 3454222635], length 0
23:36:59.163542 IP (tos 0x0, ttl 53, id 18161, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x2e18 (corr=
ect), seq 8453424:8454872, ack 1, win 9, options [nop,nop,TS val 345422=
2635 ecr 70426], length 1448
23:36:59.163665 IP (tos 0x0, ttl 53, id 18162, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x2870 (corr=
ect), seq 8454872:8456320, ack 1, win 9, options [nop,nop,TS val 345422=
2635 ecr 70426], length 1448
23:36:59.163677 IP (tos 0x0, ttl 100, id 18655, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0xd57f), ack 8456320, win 21177, options [nop,nop,TS val 70490=
 ecr 3454222635], length 0
23:36:59.166044 IP (tos 0x0, ttl 53, id 18163, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x22c6 (corr=
ect), seq 8456320:8457768, ack 1, win 9, options [nop,nop,TS val 345422=
2635 ecr 70428], length 1448
23:36:59.166167 IP (tos 0x0, ttl 53, id 18164, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x1d1e (corr=
ect), seq 8457768:8459216, ack 1, win 9, options [nop,nop,TS val 345422=
2635 ecr 70428], length 1448
23:36:59.166180 IP (tos 0x0, ttl 100, id 18656, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0xca2c), ack 8459216, win 21177, options [nop,nop,TS val 70493=
 ecr 3454222635], length 0
23:36:59.166291 IP (tos 0x0, ttl 53, id 18165, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x1776 (corr=
ect), seq 8459216:8460664, ack 1, win 9, options [nop,nop,TS val 345422=
2635 ecr 70428], length 1448
23:36:59.166413 IP (tos 0x0, ttl 53, id 18166, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x11ce (corr=
ect), seq 8460664:8462112, ack 1, win 9, options [nop,nop,TS val 345422=
2635 ecr 70428], length 1448
23:36:59.166425 IP (tos 0x0, ttl 100, id 18657, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0xbedc), ack 8462112, win 21177, options [nop,nop,TS val 70493=
 ecr 3454222635], length 0
23:36:59.167035 IP (tos 0x0, ttl 53, id 18167, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x0c24 (corr=
ect), seq 8462112:8463560, ack 1, win 9, options [nop,nop,TS val 345422=
2636 ecr 70429], length 1448
23:36:59.167158 IP (tos 0x0, ttl 53, id 18168, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x067c (corr=
ect), seq 8463560:8465008, ack 1, win 9, options [nop,nop,TS val 345422=
2636 ecr 70429], length 1448
23:36:59.167170 IP (tos 0x0, ttl 100, id 18658, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0xb38a), ack 8465008, win 21177, options [nop,nop,TS val 70494=
 ecr 3454222636], length 0
23:36:59.167521 IP (tos 0x0, ttl 53, id 18169, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x00d4 (corr=
ect), seq 8465008:8466456, ack 1, win 9, options [nop,nop,TS val 345422=
2636 ecr 70429], length 1448
23:36:59.167644 IP (tos 0x0, ttl 53, id 18170, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xfb2b (corr=
ect), seq 8466456:8467904, ack 1, win 9, options [nop,nop,TS val 345422=
2636 ecr 70429], length 1448
23:36:59.167656 IP (tos 0x0, ttl 100, id 18659, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0xa83a), ack 8467904, win 21177, options [nop,nop,TS val 70494=
 ecr 3454222636], length 0
23:36:59.168562 IP (tos 0x0, ttl 53, id 18171, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xf581 (corr=
ect), seq 8467904:8469352, ack 1, win 9, options [nop,nop,TS val 345422=
2636 ecr 70431], length 1448
23:36:59.168685 IP (tos 0x0, ttl 53, id 18172, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xefd9 (corr=
ect), seq 8469352:8470800, ack 1, win 9, options [nop,nop,TS val 345422=
2636 ecr 70431], length 1448
23:36:59.168697 IP (tos 0x0, ttl 100, id 18660, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x9ce9), ack 8470800, win 21177, options [nop,nop,TS val 70495=
 ecr 3454222636], length 0
23:36:59.168913 IP (tos 0x0, ttl 53, id 18173, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xea31 (corr=
ect), seq 8470800:8472248, ack 1, win 9, options [nop,nop,TS val 345422=
2636 ecr 70431], length 1448
23:36:59.169035 IP (tos 0x0, ttl 53, id 18174, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xe489 (corr=
ect), seq 8472248:8473696, ack 1, win 9, options [nop,nop,TS val 345422=
2636 ecr 70431], length 1448
23:36:59.169046 IP (tos 0x0, ttl 100, id 18661, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x9199), ack 8473696, win 21177, options [nop,nop,TS val 70495=
 ecr 3454222636], length 0
23:36:59.169263 IP (tos 0x0, ttl 53, id 18175, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xdee1 (corr=
ect), seq 8473696:8475144, ack 1, win 9, options [nop,nop,TS val 345422=
2636 ecr 70431], length 1448
23:36:59.169382 IP (tos 0x0, ttl 53, id 18176, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xd939 (corr=
ect), seq 8475144:8476592, ack 1, win 9, options [nop,nop,TS val 345422=
2636 ecr 70431], length 1448
23:36:59.169393 IP (tos 0x0, ttl 100, id 18662, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x8648), ack 8476592, win 21177, options [nop,nop,TS val 70496=
 ecr 3454222636], length 0
23:36:59.169505 IP (tos 0x0, ttl 53, id 18177, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xd391 (corr=
ect), seq 8476592:8478040, ack 1, win 9, options [nop,nop,TS val 345422=
2636 ecr 70431], length 1448
23:36:59.169628 IP (tos 0x0, ttl 53, id 18178, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xcde9 (corr=
ect), seq 8478040:8479488, ack 1, win 9, options [nop,nop,TS val 345422=
2636 ecr 70431], length 1448
23:36:59.169638 IP (tos 0x0, ttl 100, id 18663, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x7af8), ack 8479488, win 21177, options [nop,nop,TS val 70496=
 ecr 3454222636], length 0
23:36:59.169976 IP (tos 0x0, ttl 53, id 18179, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xc840 (corr=
ect), seq 8479488:8480936, ack 1, win 9, options [nop,nop,TS val 345422=
2636 ecr 70432], length 1448
23:36:59.170100 IP (tos 0x0, ttl 53, id 18180, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xc298 (corr=
ect), seq 8480936:8482384, ack 1, win 9, options [nop,nop,TS val 345422=
2636 ecr 70432], length 1448
23:36:59.170110 IP (tos 0x0, ttl 100, id 18664, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x6fa8), ack 8482384, win 21177, options [nop,nop,TS val 70496=
 ecr 3454222636], length 0
23:36:59.170254 IP (tos 0x0, ttl 53, id 18181, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xbcf0 (corr=
ect), seq 8482384:8483832, ack 1, win 9, options [nop,nop,TS val 345422=
2636 ecr 70432], length 1448
23:36:59.170370 IP (tos 0x0, ttl 53, id 18182, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xb748 (corr=
ect), seq 8483832:8485280, ack 1, win 9, options [nop,nop,TS val 345422=
2636 ecr 70432], length 1448
23:36:59.170380 IP (tos 0x0, ttl 100, id 18665, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x6457), ack 8485280, win 21177, options [nop,nop,TS val 70497=
 ecr 3454222636], length 0
23:36:59.170522 IP (tos 0x0, ttl 53, id 18183, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xb19f (corr=
ect), seq 8485280:8486728, ack 1, win 9, options [nop,nop,TS val 345422=
2636 ecr 70433], length 1448
23:36:59.170645 IP (tos 0x0, ttl 53, id 18184, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xabf7 (corr=
ect), seq 8486728:8488176, ack 1, win 9, options [nop,nop,TS val 345422=
2636 ecr 70433], length 1448
23:36:59.170655 IP (tos 0x0, ttl 100, id 18666, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x5907), ack 8488176, win 21177, options [nop,nop,TS val 70497=
 ecr 3454222636], length 0
23:36:59.170802 IP (tos 0x0, ttl 53, id 18185, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xa64f (corr=
ect), seq 8488176:8489624, ack 1, win 9, options [nop,nop,TS val 345422=
2636 ecr 70433], length 1448
23:36:59.170926 IP (tos 0x0, ttl 53, id 18186, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xa0a7 (corr=
ect), seq 8489624:8491072, ack 1, win 9, options [nop,nop,TS val 345422=
2636 ecr 70433], length 1448
23:36:59.170936 IP (tos 0x0, ttl 100, id 18667, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x4db7), ack 8491072, win 21177, options [nop,nop,TS val 70497=
 ecr 3454222636], length 0
23:36:59.171216 IP (tos 0x0, ttl 53, id 18187, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x9afe (corr=
ect), seq 8491072:8492520, ack 1, win 9, options [nop,nop,TS val 345422=
2637 ecr 70433], length 1448
23:36:59.171334 IP (tos 0x0, ttl 53, id 18188, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x9556 (corr=
ect), seq 8492520:8493968, ack 1, win 9, options [nop,nop,TS val 345422=
2637 ecr 70433], length 1448
23:36:59.171345 IP (tos 0x0, ttl 100, id 18668, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x4265), ack 8493968, win 21177, options [nop,nop,TS val 70498=
 ecr 3454222637], length 0
23:36:59.172533 IP (tos 0x0, ttl 53, id 18189, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x8fac (corr=
ect), seq 8493968:8495416, ack 1, win 9, options [nop,nop,TS val 345422=
2637 ecr 70435], length 1448
23:36:59.172656 IP (tos 0x0, ttl 53, id 18190, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x8a04 (corr=
ect), seq 8495416:8496864, ack 1, win 9, options [nop,nop,TS val 345422=
2637 ecr 70435], length 1448
23:36:59.172668 IP (tos 0x0, ttl 100, id 18669, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x3714), ack 8496864, win 21177, options [nop,nop,TS val 70499=
 ecr 3454222637], length 0
23:36:59.172805 IP (tos 0x0, ttl 53, id 18191, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x845c (corr=
ect), seq 8496864:8498312, ack 1, win 9, options [nop,nop,TS val 345422=
2637 ecr 70435], length 1448
23:36:59.172920 IP (tos 0x0, ttl 53, id 18192, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x7eb4 (corr=
ect), seq 8498312:8499760, ack 1, win 9, options [nop,nop,TS val 345422=
2637 ecr 70435], length 1448
23:36:59.172932 IP (tos 0x0, ttl 100, id 18670, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x2bc4), ack 8499760, win 21177, options [nop,nop,TS val 70499=
 ecr 3454222637], length 0
23:36:59.173871 IP (tos 0x0, ttl 53, id 18193, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x790b (corr=
ect), seq 8499760:8501208, ack 1, win 9, options [nop,nop,TS val 345422=
2637 ecr 70436], length 1448
23:36:59.173995 IP (tos 0x0, ttl 53, id 18194, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x7363 (corr=
ect), seq 8501208:8502656, ack 1, win 9, options [nop,nop,TS val 345422=
2637 ecr 70436], length 1448
23:36:59.174007 IP (tos 0x0, ttl 100, id 18671, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x2073), ack 8502656, win 21177, options [nop,nop,TS val 70500=
 ecr 3454222637], length 0
23:36:59.174301 IP (tos 0x0, ttl 53, id 18195, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x6dbb (corr=
ect), seq 8502656:8504104, ack 1, win 9, options [nop,nop,TS val 345422=
2637 ecr 70436], length 1448
23:36:59.174423 IP (tos 0x0, ttl 53, id 18196, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x6813 (corr=
ect), seq 8504104:8505552, ack 1, win 9, options [nop,nop,TS val 345422=
2637 ecr 70436], length 1448
23:36:59.174434 IP (tos 0x0, ttl 100, id 18672, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x1522), ack 8505552, win 21177, options [nop,nop,TS val 70501=
 ecr 3454222637], length 0
23:36:59.174554 IP (tos 0x0, ttl 53, id 18197, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x626a (corr=
ect), seq 8505552:8507000, ack 1, win 9, options [nop,nop,TS val 345422=
2637 ecr 70437], length 1448
23:36:59.174677 IP (tos 0x0, ttl 53, id 18198, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x5cc2 (corr=
ect), seq 8507000:8508448, ack 1, win 9, options [nop,nop,TS val 345422=
2637 ecr 70437], length 1448
23:36:59.174689 IP (tos 0x0, ttl 100, id 18673, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x09d2), ack 8508448, win 21177, options [nop,nop,TS val 70501=
 ecr 3454222637], length 0
23:36:59.174835 IP (tos 0x0, ttl 53, id 18199, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x571a (corr=
ect), seq 8508448:8509896, ack 1, win 9, options [nop,nop,TS val 345422=
2637 ecr 70437], length 1448
23:36:59.174958 IP (tos 0x0, ttl 53, id 18200, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x5172 (corr=
ect), seq 8509896:8511344, ack 1, win 9, options [nop,nop,TS val 345422=
2637 ecr 70437], length 1448
23:36:59.174970 IP (tos 0x0, ttl 100, id 18674, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0xfe81), ack 8511344, win 21177, options [nop,nop,TS val 70501=
 ecr 3454222637], length 0
23:36:59.175311 IP (tos 0x0, ttl 53, id 18201, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x4bc9 (corr=
ect), seq 8511344:8512792, ack 1, win 9, options [nop,nop,TS val 345422=
2638 ecr 70437], length 1448
23:36:59.175434 IP (tos 0x0, ttl 53, id 18202, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [P.], cksum 0x4619 (cor=
rect), seq 8512792:8514240, ack 1, win 9, options [nop,nop,TS val 34542=
22638 ecr 70437], length 1448
23:36:59.175446 IP (tos 0x0, ttl 100, id 18675, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0xf32f), ack 8514240, win 21177, options [nop,nop,TS val 70502=
 ecr 3454222638], length 0
23:36:59.175760 IP (tos 0x0, ttl 53, id 18203, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x4078 (corr=
ect), seq 8514240:8515688, ack 1, win 9, options [nop,nop,TS val 345422=
2638 ecr 70438], length 1448
23:36:59.175883 IP (tos 0x0, ttl 53, id 18204, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x3ad0 (corr=
ect), seq 8515688:8517136, ack 1, win 9, options [nop,nop,TS val 345422=
2638 ecr 70438], length 1448
23:36:59.175895 IP (tos 0x0, ttl 100, id 18676, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0xe7df), ack 8517136, win 21177, options [nop,nop,TS val 70502=
 ecr 3454222638], length 0
23:36:59.177422 IP (tos 0x0, ttl 53, id 18205, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x3527 (corr=
ect), seq 8517136:8518584, ack 1, win 9, options [nop,nop,TS val 345422=
2638 ecr 70439], length 1448
23:36:59.177545 IP (tos 0x0, ttl 53, id 18206, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x2f7f (corr=
ect), seq 8518584:8520032, ack 1, win 9, options [nop,nop,TS val 345422=
2638 ecr 70439], length 1448
23:36:59.177556 IP (tos 0x0, ttl 100, id 18677, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0xdc8d), ack 8520032, win 21177, options [nop,nop,TS val 70504=
 ecr 3454222638], length 0
23:36:59.178168 IP (tos 0x0, ttl 53, id 18207, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x29d6 (corr=
ect), seq 8520032:8521480, ack 1, win 9, options [nop,nop,TS val 345422=
2638 ecr 70440], length 1448
23:36:59.178291 IP (tos 0x0, ttl 53, id 18208, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x242e (corr=
ect), seq 8521480:8522928, ack 1, win 9, options [nop,nop,TS val 345422=
2638 ecr 70440], length 1448
23:36:59.178302 IP (tos 0x0, ttl 100, id 18678, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0xd13c), ack 8522928, win 21177, options [nop,nop,TS val 70505=
 ecr 3454222638], length 0
23:36:59.178608 IP (tos 0x0, ttl 53, id 18209, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x1e85 (corr=
ect), seq 8522928:8524376, ack 1, win 9, options [nop,nop,TS val 345422=
2638 ecr 70441], length 1448
23:36:59.178731 IP (tos 0x0, ttl 53, id 18210, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x18dd (corr=
ect), seq 8524376:8525824, ack 1, win 9, options [nop,nop,TS val 345422=
2638 ecr 70441], length 1448
23:36:59.178741 IP (tos 0x0, ttl 100, id 18679, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0xc5ec), ack 8525824, win 21177, options [nop,nop,TS val 70505=
 ecr 3454222638], length 0
23:36:59.178895 IP (tos 0x0, ttl 53, id 18211, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x1335 (corr=
ect), seq 8525824:8527272, ack 1, win 9, options [nop,nop,TS val 345422=
2638 ecr 70441], length 1448
23:36:59.179013 IP (tos 0x0, ttl 53, id 18212, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x0d8d (corr=
ect), seq 8527272:8528720, ack 1, win 9, options [nop,nop,TS val 345422=
2638 ecr 70441], length 1448
23:36:59.179023 IP (tos 0x0, ttl 100, id 18680, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0xba9c), ack 8528720, win 21177, options [nop,nop,TS val 70505=
 ecr 3454222638], length 0
23:36:59.181108 IP (tos 0x0, ttl 53, id 18213, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x07e3 (corr=
ect), seq 8528720:8530168, ack 1, win 9, options [nop,nop,TS val 345422=
2639 ecr 70442], length 1448
23:36:59.181230 IP (tos 0x0, ttl 53, id 18214, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x023b (corr=
ect), seq 8530168:8531616, ack 1, win 9, options [nop,nop,TS val 345422=
2639 ecr 70442], length 1448
23:36:59.181241 IP (tos 0x0, ttl 100, id 18681, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0xaf48), ack 8531616, win 21177, options [nop,nop,TS val 70508=
 ecr 3454222639], length 0
23:36:59.183522 IP (tos 0x0, ttl 53, id 18215, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xfc8e (corr=
ect), seq 8531616:8533064, ack 1, win 9, options [nop,nop,TS val 345422=
2640 ecr 70445], length 1448
23:36:59.183645 IP (tos 0x0, ttl 53, id 18216, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xf6e6 (corr=
ect), seq 8533064:8534512, ack 1, win 9, options [nop,nop,TS val 345422=
2640 ecr 70445], length 1448
23:36:59.183656 IP (tos 0x0, ttl 100, id 18682, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0xa3f5), ack 8534512, win 21177, options [nop,nop,TS val 70510=
 ecr 3454222640], length 0
23:36:59.183860 IP (tos 0x0, ttl 53, id 18217, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xf13d (corr=
ect), seq 8534512:8535960, ack 1, win 9, options [nop,nop,TS val 345422=
2640 ecr 70446], length 1448
23:36:59.183983 IP (tos 0x0, ttl 53, id 18218, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xeb95 (corr=
ect), seq 8535960:8537408, ack 1, win 9, options [nop,nop,TS val 345422=
2640 ecr 70446], length 1448
23:36:59.183994 IP (tos 0x0, ttl 100, id 18683, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x98a5), ack 8537408, win 21177, options [nop,nop,TS val 70510=
 ecr 3454222640], length 0
23:36:59.184554 IP (tos 0x0, ttl 53, id 18219, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xe5ec (corr=
ect), seq 8537408:8538856, ack 1, win 9, options [nop,nop,TS val 345422=
2640 ecr 70447], length 1448
23:36:59.184678 IP (tos 0x0, ttl 53, id 18220, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xe044 (corr=
ect), seq 8538856:8540304, ack 1, win 9, options [nop,nop,TS val 345422=
2640 ecr 70447], length 1448
23:36:59.184689 IP (tos 0x0, ttl 100, id 18684, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x8d54), ack 8540304, win 21177, options [nop,nop,TS val 70511=
 ecr 3454222640], length 0
23:36:59.186603 IP (tos 0x0, ttl 53, id 18221, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xda9a (corr=
ect), seq 8540304:8541752, ack 1, win 9, options [nop,nop,TS val 345422=
2640 ecr 70449], length 1448
23:36:59.186727 IP (tos 0x0, ttl 53, id 18222, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xd4f2 (corr=
ect), seq 8541752:8543200, ack 1, win 9, options [nop,nop,TS val 345422=
2640 ecr 70449], length 1448
23:36:59.186739 IP (tos 0x0, ttl 100, id 18685, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x8202), ack 8543200, win 21177, options [nop,nop,TS val 70513=
 ecr 3454222640], length 0
23:36:59.186924 IP (tos 0x0, ttl 53, id 18223, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xcf4a (corr=
ect), seq 8543200:8544648, ack 1, win 9, options [nop,nop,TS val 345422=
2640 ecr 70449], length 1448
23:36:59.187047 IP (tos 0x0, ttl 53, id 18224, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xc9a1 (corr=
ect), seq 8544648:8546096, ack 1, win 9, options [nop,nop,TS val 345422=
2641 ecr 70449], length 1448
23:36:59.187059 IP (tos 0x0, ttl 100, id 18686, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x76b2), ack 8546096, win 21177, options [nop,nop,TS val 70513=
 ecr 3454222640], length 0
23:36:59.187251 IP (tos 0x0, ttl 53, id 18225, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xc3f9 (corr=
ect), seq 8546096:8547544, ack 1, win 9, options [nop,nop,TS val 345422=
2641 ecr 70449], length 1448
23:36:59.187374 IP (tos 0x0, ttl 53, id 18226, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xbe51 (corr=
ect), seq 8547544:8548992, ack 1, win 9, options [nop,nop,TS val 345422=
2641 ecr 70449], length 1448
23:36:59.187387 IP (tos 0x0, ttl 100, id 18687, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x6b60), ack 8548992, win 21177, options [nop,nop,TS val 70514=
 ecr 3454222641], length 0
23:36:59.187510 IP (tos 0x0, ttl 53, id 18227, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xb8a9 (corr=
ect), seq 8548992:8550440, ack 1, win 9, options [nop,nop,TS val 345422=
2641 ecr 70449], length 1448
23:36:59.187632 IP (tos 0x0, ttl 53, id 18228, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xb301 (corr=
ect), seq 8550440:8551888, ack 1, win 9, options [nop,nop,TS val 345422=
2641 ecr 70449], length 1448
23:36:59.187644 IP (tos 0x0, ttl 100, id 18688, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x6010), ack 8551888, win 21177, options [nop,nop,TS val 70514=
 ecr 3454222641], length 0
23:36:59.188501 IP (tos 0x0, ttl 53, id 18229, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xad57 (corr=
ect), seq 8551888:8553336, ack 1, win 9, options [nop,nop,TS val 345422=
2641 ecr 70451], length 1448
23:36:59.188623 IP (tos 0x0, ttl 53, id 18230, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xa7af (corr=
ect), seq 8553336:8554784, ack 1, win 9, options [nop,nop,TS val 345422=
2641 ecr 70451], length 1448
23:36:59.188635 IP (tos 0x0, ttl 100, id 18689, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x54bf), ack 8554784, win 21177, options [nop,nop,TS val 70515=
 ecr 3454222641], length 0
23:36:59.188960 IP (tos 0x0, ttl 53, id 18231, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xa207 (corr=
ect), seq 8554784:8556232, ack 1, win 9, options [nop,nop,TS val 345422=
2641 ecr 70451], length 1448
23:36:59.189084 IP (tos 0x0, ttl 53, id 18232, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x9c5f (corr=
ect), seq 8556232:8557680, ack 1, win 9, options [nop,nop,TS val 345422=
2641 ecr 70451], length 1448
23:36:59.189095 IP (tos 0x0, ttl 100, id 18690, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x496f), ack 8557680, win 21177, options [nop,nop,TS val 70515=
 ecr 3454222641], length 0
23:36:59.189208 IP (tos 0x0, ttl 53, id 18233, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x96b7 (corr=
ect), seq 8557680:8559128, ack 1, win 9, options [nop,nop,TS val 345422=
2641 ecr 70451], length 1448
23:36:59.189330 IP (tos 0x0, ttl 53, id 18234, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x910f (corr=
ect), seq 8559128:8560576, ack 1, win 9, options [nop,nop,TS val 345422=
2641 ecr 70451], length 1448
23:36:59.189342 IP (tos 0x0, ttl 100, id 18691, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x3e1e), ack 8560576, win 21177, options [nop,nop,TS val 70516=
 ecr 3454222641], length 0
23:36:59.190146 IP (tos 0x0, ttl 53, id 18235, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x8b66 (corr=
ect), seq 8560576:8562024, ack 1, win 9, options [nop,nop,TS val 345422=
2641 ecr 70452], length 1448
23:36:59.190270 IP (tos 0x0, ttl 53, id 18236, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x85be (corr=
ect), seq 8562024:8563472, ack 1, win 9, options [nop,nop,TS val 345422=
2641 ecr 70452], length 1448
23:36:59.190282 IP (tos 0x0, ttl 100, id 18692, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x32cd), ack 8563472, win 21177, options [nop,nop,TS val 70517=
 ecr 3454222641], length 0
23:36:59.190466 IP (tos 0x0, ttl 53, id 18237, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x8016 (corr=
ect), seq 8563472:8564920, ack 1, win 9, options [nop,nop,TS val 345422=
2641 ecr 70452], length 1448
23:36:59.190589 IP (tos 0x0, ttl 53, id 18238, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x7a6e (corr=
ect), seq 8564920:8566368, ack 1, win 9, options [nop,nop,TS val 345422=
2641 ecr 70452], length 1448
23:36:59.190599 IP (tos 0x0, ttl 100, id 18693, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x277d), ack 8566368, win 21177, options [nop,nop,TS val 70517=
 ecr 3454222641], length 0
23:36:59.190712 IP (tos 0x0, ttl 53, id 18239, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x74c5 (corr=
ect), seq 8566368:8567816, ack 1, win 9, options [nop,nop,TS val 345422=
2641 ecr 70453], length 1448
23:36:59.190844 IP (tos 0x0, ttl 53, id 18240, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x6f1d (corr=
ect), seq 8567816:8569264, ack 1, win 9, options [nop,nop,TS val 345422=
2641 ecr 70453], length 1448
23:36:59.190853 IP (tos 0x0, ttl 100, id 18694, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x1c2d), ack 8569264, win 21177, options [nop,nop,TS val 70517=
 ecr 3454222641], length 0
23:36:59.190965 IP (tos 0x0, ttl 53, id 18241, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x6974 (corr=
ect), seq 8569264:8570712, ack 1, win 9, options [nop,nop,TS val 345422=
2642 ecr 70453], length 1448
23:36:59.191082 IP (tos 0x0, ttl 53, id 18242, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x63cc (corr=
ect), seq 8570712:8572160, ack 1, win 9, options [nop,nop,TS val 345422=
2642 ecr 70453], length 1448
23:36:59.191092 IP (tos 0x0, ttl 100, id 18695, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x10dc), ack 8572160, win 21177, options [nop,nop,TS val 70517=
 ecr 3454222642], length 0
23:36:59.191204 IP (tos 0x0, ttl 53, id 18243, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x5e24 (corr=
ect), seq 8572160:8573608, ack 1, win 9, options [nop,nop,TS val 345422=
2642 ecr 70453], length 1448
23:36:59.191327 IP (tos 0x0, ttl 53, id 18244, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x587c (corr=
ect), seq 8573608:8575056, ack 1, win 9, options [nop,nop,TS val 345422=
2642 ecr 70453], length 1448
23:36:59.191340 IP (tos 0x0, ttl 100, id 18696, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x058b), ack 8575056, win 21177, options [nop,nop,TS val 70518=
 ecr 3454222642], length 0
23:36:59.191828 IP (tos 0x0, ttl 53, id 18245, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x52d3 (corr=
ect), seq 8575056:8576504, ack 1, win 9, options [nop,nop,TS val 345422=
2642 ecr 70454], length 1448
23:36:59.191951 IP (tos 0x0, ttl 53, id 18246, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x4d2b (corr=
ect), seq 8576504:8577952, ack 1, win 9, options [nop,nop,TS val 345422=
2642 ecr 70454], length 1448
23:36:59.191962 IP (tos 0x0, ttl 100, id 18697, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0xfa3a), ack 8577952, win 21177, options [nop,nop,TS val 70518=
 ecr 3454222642], length 0
23:36:59.192198 IP (tos 0x0, ttl 53, id 18247, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x4783 (corr=
ect), seq 8577952:8579400, ack 1, win 9, options [nop,nop,TS val 345422=
2642 ecr 70454], length 1448
23:36:59.192321 IP (tos 0x0, ttl 53, id 18248, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x41db (corr=
ect), seq 8579400:8580848, ack 1, win 9, options [nop,nop,TS val 345422=
2642 ecr 70454], length 1448
23:36:59.192333 IP (tos 0x0, ttl 100, id 18698, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0xeee9), ack 8580848, win 21177, options [nop,nop,TS val 70519=
 ecr 3454222642], length 0
23:36:59.192614 IP (tos 0x0, ttl 53, id 18249, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x3c32 (corr=
ect), seq 8580848:8582296, ack 1, win 9, options [nop,nop,TS val 345422=
2642 ecr 70455], length 1448
23:36:59.192738 IP (tos 0x0, ttl 53, id 18250, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x368a (corr=
ect), seq 8582296:8583744, ack 1, win 9, options [nop,nop,TS val 345422=
2642 ecr 70455], length 1448
23:36:59.192750 IP (tos 0x0, ttl 100, id 18699, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0xe399), ack 8583744, win 21177, options [nop,nop,TS val 70519=
 ecr 3454222642], length 0
23:36:59.192879 IP (tos 0x0, ttl 53, id 18251, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x30e2 (corr=
ect), seq 8583744:8585192, ack 1, win 9, options [nop,nop,TS val 345422=
2642 ecr 70455], length 1448
23:36:59.193013 IP (tos 0x0, ttl 53, id 18252, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x2b3a (corr=
ect), seq 8585192:8586640, ack 1, win 9, options [nop,nop,TS val 345422=
2642 ecr 70455], length 1448
23:36:59.193025 IP (tos 0x0, ttl 100, id 18700, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0xd849), ack 8586640, win 21177, options [nop,nop,TS val 70519=
 ecr 3454222642], length 0
23:36:59.193287 IP (tos 0x0, ttl 53, id 18253, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x2592 (corr=
ect), seq 8586640:8588088, ack 1, win 9, options [nop,nop,TS val 345422=
2642 ecr 70455], length 1448
23:36:59.193409 IP (tos 0x0, ttl 53, id 18254, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x1fea (corr=
ect), seq 8588088:8589536, ack 1, win 9, options [nop,nop,TS val 345422=
2642 ecr 70455], length 1448
23:36:59.193419 IP (tos 0x0, ttl 100, id 18701, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0xccf8), ack 8589536, win 21177, options [nop,nop,TS val 70520=
 ecr 3454222642], length 0
23:36:59.193576 IP (tos 0x0, ttl 53, id 18255, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x1a41 (corr=
ect), seq 8589536:8590984, ack 1, win 9, options [nop,nop,TS val 345422=
2642 ecr 70456], length 1448
23:36:59.193699 IP (tos 0x0, ttl 53, id 18256, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x1499 (corr=
ect), seq 8590984:8592432, ack 1, win 9, options [nop,nop,TS val 345422=
2642 ecr 70456], length 1448
23:36:59.193709 IP (tos 0x0, ttl 100, id 18702, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0xc1a8), ack 8592432, win 21177, options [nop,nop,TS val 70520=
 ecr 3454222642], length 0
23:36:59.194213 IP (tos 0x0, ttl 53, id 18257, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x0ef1 (corr=
ect), seq 8592432:8593880, ack 1, win 9, options [nop,nop,TS val 345422=
2642 ecr 70456], length 1448
23:36:59.194337 IP (tos 0x0, ttl 53, id 18258, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x0949 (corr=
ect), seq 8593880:8595328, ack 1, win 9, options [nop,nop,TS val 345422=
2642 ecr 70456], length 1448
23:36:59.194347 IP (tos 0x0, ttl 100, id 18703, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0xb657), ack 8595328, win 21177, options [nop,nop,TS val 70521=
 ecr 3454222642], length 0
23:36:59.195473 IP (tos 0x0, ttl 53, id 18259, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x039f (corr=
ect), seq 8595328:8596776, ack 1, win 9, options [nop,nop,TS val 345422=
2643 ecr 70457], length 1448
23:36:59.195595 IP (tos 0x0, ttl 53, id 18260, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xfdf6 (corr=
ect), seq 8596776:8598224, ack 1, win 9, options [nop,nop,TS val 345422=
2643 ecr 70457], length 1448
23:36:59.195606 IP (tos 0x0, ttl 100, id 18704, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0xab05), ack 8598224, win 21177, options [nop,nop,TS val 70522=
 ecr 3454222643], length 0
23:36:59.195720 IP (tos 0x0, ttl 53, id 18261, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xf84d (corr=
ect), seq 8598224:8599672, ack 1, win 9, options [nop,nop,TS val 345422=
2643 ecr 70458], length 1448
23:36:59.195848 IP (tos 0x0, ttl 53, id 18262, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xf2a5 (corr=
ect), seq 8599672:8601120, ack 1, win 9, options [nop,nop,TS val 345422=
2643 ecr 70458], length 1448
23:36:59.195859 IP (tos 0x0, ttl 100, id 18705, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x9fb5), ack 8601120, win 21177, options [nop,nop,TS val 70522=
 ecr 3454222643], length 0
23:36:59.196083 IP (tos 0x0, ttl 53, id 18263, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xecfd (corr=
ect), seq 8601120:8602568, ack 1, win 9, options [nop,nop,TS val 345422=
2643 ecr 70458], length 1448
23:36:59.196207 IP (tos 0x0, ttl 53, id 18264, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xe755 (corr=
ect), seq 8602568:8604016, ack 1, win 9, options [nop,nop,TS val 345422=
2643 ecr 70458], length 1448
23:36:59.196217 IP (tos 0x0, ttl 100, id 18706, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x9464), ack 8604016, win 21177, options [nop,nop,TS val 70523=
 ecr 3454222643], length 0
23:36:59.196330 IP (tos 0x0, ttl 53, id 18265, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xe1ad (corr=
ect), seq 8604016:8605464, ack 1, win 9, options [nop,nop,TS val 345422=
2643 ecr 70458], length 1448
23:36:59.196453 IP (tos 0x0, ttl 53, id 18266, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xdc05 (corr=
ect), seq 8605464:8606912, ack 1, win 9, options [nop,nop,TS val 345422=
2643 ecr 70458], length 1448
23:36:59.196466 IP (tos 0x0, ttl 100, id 18707, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x8914), ack 8606912, win 21177, options [nop,nop,TS val 70523=
 ecr 3454222643], length 0
23:36:59.196653 IP (tos 0x0, ttl 53, id 18267, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xd65c (corr=
ect), seq 8606912:8608360, ack 1, win 9, options [nop,nop,TS val 345422=
2643 ecr 70459], length 1448
23:36:59.196776 IP (tos 0x0, ttl 53, id 18268, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xd0b4 (corr=
ect), seq 8608360:8609808, ack 1, win 9, options [nop,nop,TS val 345422=
2643 ecr 70459], length 1448
23:36:59.196788 IP (tos 0x0, ttl 100, id 18708, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x7dc4), ack 8609808, win 21177, options [nop,nop,TS val 70523=
 ecr 3454222643], length 0
23:36:59.197082 IP (tos 0x0, ttl 53, id 18269, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xcb0c (corr=
ect), seq 8609808:8611256, ack 1, win 9, options [nop,nop,TS val 345422=
2643 ecr 70459], length 1448
23:36:59.197205 IP (tos 0x0, ttl 53, id 18270, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xc564 (corr=
ect), seq 8611256:8612704, ack 1, win 9, options [nop,nop,TS val 345422=
2643 ecr 70459], length 1448
23:36:59.197217 IP (tos 0x0, ttl 100, id 18709, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x7273), ack 8612704, win 21177, options [nop,nop,TS val 70524=
 ecr 3454222643], length 0
23:36:59.197405 IP (tos 0x0, ttl 53, id 18271, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xbfbc (corr=
ect), seq 8612704:8614152, ack 1, win 9, options [nop,nop,TS val 345422=
2643 ecr 70459], length 1448
23:36:59.197528 IP (tos 0x0, ttl 53, id 18272, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xba14 (corr=
ect), seq 8614152:8615600, ack 1, win 9, options [nop,nop,TS val 345422=
2643 ecr 70459], length 1448
23:36:59.197538 IP (tos 0x0, ttl 100, id 18710, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x6723), ack 8615600, win 21177, options [nop,nop,TS val 70524=
 ecr 3454222643], length 0
23:36:59.198005 IP (tos 0x0, ttl 53, id 18273, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xb46b (corr=
ect), seq 8615600:8617048, ack 1, win 9, options [nop,nop,TS val 345422=
2643 ecr 70460], length 1448
23:36:59.198128 IP (tos 0x0, ttl 53, id 18274, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xaec3 (corr=
ect), seq 8617048:8618496, ack 1, win 9, options [nop,nop,TS val 345422=
2643 ecr 70460], length 1448
23:36:59.198138 IP (tos 0x0, ttl 100, id 18711, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x5bd3), ack 8618496, win 21177, options [nop,nop,TS val 70524=
 ecr 3454222643], length 0
23:36:59.198275 IP (tos 0x0, ttl 53, id 18275, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xa91b (corr=
ect), seq 8618496:8619944, ack 1, win 9, options [nop,nop,TS val 345422=
2643 ecr 70460], length 1448
23:36:59.198384 IP (tos 0x0, ttl 53, id 18276, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xa373 (corr=
ect), seq 8619944:8621392, ack 1, win 9, options [nop,nop,TS val 345422=
2643 ecr 70460], length 1448
23:36:59.198394 IP (tos 0x0, ttl 100, id 18712, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x5082), ack 8621392, win 21177, options [nop,nop,TS val 70525=
 ecr 3454222643], length 0
23:36:59.198507 IP (tos 0x0, ttl 53, id 18277, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x9dcb (corr=
ect), seq 8621392:8622840, ack 1, win 9, options [nop,nop,TS val 345422=
2643 ecr 70460], length 1448
23:36:59.198630 IP (tos 0x0, ttl 53, id 18278, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x9823 (corr=
ect), seq 8622840:8624288, ack 1, win 9, options [nop,nop,TS val 345422=
2643 ecr 70460], length 1448
23:36:59.198640 IP (tos 0x0, ttl 100, id 18713, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x4532), ack 8624288, win 21177, options [nop,nop,TS val 70525=
 ecr 3454222643], length 0
23:36:59.198855 IP (tos 0x0, ttl 53, id 18279, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x927a (corr=
ect), seq 8624288:8625736, ack 1, win 9, options [nop,nop,TS val 345422=
2643 ecr 70461], length 1448
23:36:59.198978 IP (tos 0x0, ttl 53, id 18280, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x8cd2 (corr=
ect), seq 8625736:8627184, ack 1, win 9, options [nop,nop,TS val 345422=
2643 ecr 70461], length 1448
23:36:59.198988 IP (tos 0x0, ttl 100, id 18714, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x39e2), ack 8627184, win 21177, options [nop,nop,TS val 70525=
 ecr 3454222643], length 0
23:36:59.199150 IP (tos 0x0, ttl 53, id 18281, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x8729 (corr=
ect), seq 8627184:8628632, ack 1, win 9, options [nop,nop,TS val 345422=
2644 ecr 70461], length 1448
23:36:59.199272 IP (tos 0x0, ttl 53, id 18282, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x8181 (corr=
ect), seq 8628632:8630080, ack 1, win 9, options [nop,nop,TS val 345422=
2644 ecr 70461], length 1448
23:36:59.199282 IP (tos 0x0, ttl 100, id 18715, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x2e90), ack 8630080, win 21177, options [nop,nop,TS val 70526=
 ecr 3454222644], length 0
23:36:59.199409 IP (tos 0x0, ttl 53, id 18283, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x7bd9 (corr=
ect), seq 8630080:8631528, ack 1, win 9, options [nop,nop,TS val 345422=
2644 ecr 70461], length 1448
23:36:59.199532 IP (tos 0x0, ttl 53, id 18284, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x7631 (corr=
ect), seq 8631528:8632976, ack 1, win 9, options [nop,nop,TS val 345422=
2644 ecr 70461], length 1448
23:36:59.199542 IP (tos 0x0, ttl 100, id 18716, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x2340), ack 8632976, win 21177, options [nop,nop,TS val 70526=
 ecr 3454222644], length 0
23:36:59.199925 IP (tos 0x0, ttl 53, id 18285, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x7088 (corr=
ect), seq 8632976:8634424, ack 1, win 9, options [nop,nop,TS val 345422=
2644 ecr 70462], length 1448
23:36:59.200048 IP (tos 0x0, ttl 53, id 18286, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x6ae0 (corr=
ect), seq 8634424:8635872, ack 1, win 9, options [nop,nop,TS val 345422=
2644 ecr 70462], length 1448
23:36:59.200058 IP (tos 0x0, ttl 100, id 18717, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x17f0), ack 8635872, win 21177, options [nop,nop,TS val 70526=
 ecr 3454222644], length 0
23:36:59.200345 IP (tos 0x0, ttl 53, id 18287, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x6538 (corr=
ect), seq 8635872:8637320, ack 1, win 9, options [nop,nop,TS val 345422=
2644 ecr 70462], length 1448
23:36:59.200469 IP (tos 0x0, ttl 53, id 18288, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x5f90 (corr=
ect), seq 8637320:8638768, ack 1, win 9, options [nop,nop,TS val 345422=
2644 ecr 70462], length 1448
23:36:59.200481 IP (tos 0x0, ttl 100, id 18718, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x0c9f), ack 8638768, win 21177, options [nop,nop,TS val 70527=
 ecr 3454222644], length 0
23:36:59.200591 IP (tos 0x0, ttl 53, id 18289, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x59e7 (corr=
ect), seq 8638768:8640216, ack 1, win 9, options [nop,nop,TS val 345422=
2644 ecr 70463], length 1448
23:36:59.200714 IP (tos 0x0, ttl 53, id 18290, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x543f (corr=
ect), seq 8640216:8641664, ack 1, win 9, options [nop,nop,TS val 345422=
2644 ecr 70463], length 1448
23:36:59.200726 IP (tos 0x0, ttl 100, id 18719, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x014f), ack 8641664, win 21177, options [nop,nop,TS val 70527=
 ecr 3454222644], length 0
23:36:59.202068 IP (tos 0x0, ttl 53, id 18291, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x4e96 (corr=
ect), seq 8641664:8643112, ack 1, win 9, options [nop,nop,TS val 345422=
2644 ecr 70464], length 1448
23:36:59.202191 IP (tos 0x0, ttl 53, id 18292, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x48ee (corr=
ect), seq 8643112:8644560, ack 1, win 9, options [nop,nop,TS val 345422=
2644 ecr 70464], length 1448
23:36:59.202204 IP (tos 0x0, ttl 100, id 18720, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0xf5fc), ack 8644560, win 21177, options [nop,nop,TS val 70529=
 ecr 3454222644], length 0
23:36:59.202314 IP (tos 0x0, ttl 53, id 18293, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x4346 (corr=
ect), seq 8644560:8646008, ack 1, win 9, options [nop,nop,TS val 345422=
2644 ecr 70464], length 1448
23:36:59.202438 IP (tos 0x0, ttl 53, id 18294, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x3d9e (corr=
ect), seq 8646008:8647456, ack 1, win 9, options [nop,nop,TS val 345422=
2644 ecr 70464], length 1448
23:36:59.202448 IP (tos 0x0, ttl 100, id 18721, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0xeaac), ack 8647456, win 21177, options [nop,nop,TS val 70529=
 ecr 3454222644], length 0
23:36:59.202560 IP (tos 0x0, ttl 53, id 18295, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x37f6 (corr=
ect), seq 8647456:8648904, ack 1, win 9, options [nop,nop,TS val 345422=
2644 ecr 70464], length 1448
23:36:59.202684 IP (tos 0x0, ttl 53, id 18296, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x324e (corr=
ect), seq 8648904:8650352, ack 1, win 9, options [nop,nop,TS val 345422=
2644 ecr 70464], length 1448
23:36:59.202694 IP (tos 0x0, ttl 100, id 18722, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0xdf5c), ack 8650352, win 21177, options [nop,nop,TS val 70529=
 ecr 3454222644], length 0
23:36:59.202807 IP (tos 0x0, ttl 53, id 18297, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x2ca5 (corr=
ect), seq 8650352:8651800, ack 1, win 9, options [nop,nop,TS val 345422=
2644 ecr 70465], length 1448
23:36:59.202930 IP (tos 0x0, ttl 53, id 18298, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x26fd (corr=
ect), seq 8651800:8653248, ack 1, win 9, options [nop,nop,TS val 345422=
2644 ecr 70465], length 1448
23:36:59.202940 IP (tos 0x0, ttl 100, id 18723, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0xd40c), ack 8653248, win 21177, options [nop,nop,TS val 70529=
 ecr 3454222644], length 0
23:36:59.203053 IP (tos 0x0, ttl 53, id 18299, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x2155 (corr=
ect), seq 8653248:8654696, ack 1, win 9, options [nop,nop,TS val 345422=
2644 ecr 70465], length 1448
23:36:59.203176 IP (tos 0x0, ttl 53, id 18300, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x1bad (corr=
ect), seq 8654696:8656144, ack 1, win 9, options [nop,nop,TS val 345422=
2644 ecr 70465], length 1448
23:36:59.203186 IP (tos 0x0, ttl 100, id 18724, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0xc8bb), ack 8656144, win 21177, options [nop,nop,TS val 70530=
 ecr 3454222644], length 0
23:36:59.203299 IP (tos 0x0, ttl 53, id 18301, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x1604 (corr=
ect), seq 8656144:8657592, ack 1, win 9, options [nop,nop,TS val 345422=
2645 ecr 70465], length 1448
23:36:59.203421 IP (tos 0x0, ttl 53, id 18302, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x105c (corr=
ect), seq 8657592:8659040, ack 1, win 9, options [nop,nop,TS val 345422=
2645 ecr 70465], length 1448
23:36:59.203432 IP (tos 0x0, ttl 100, id 18725, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0xbd6a), ack 8659040, win 21177, options [nop,nop,TS val 70530=
 ecr 3454222645], length 0
23:36:59.203545 IP (tos 0x0, ttl 53, id 18303, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x0ab4 (corr=
ect), seq 8659040:8660488, ack 1, win 9, options [nop,nop,TS val 345422=
2645 ecr 70465], length 1448
23:36:59.203668 IP (tos 0x0, ttl 53, id 18304, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x050c (corr=
ect), seq 8660488:8661936, ack 1, win 9, options [nop,nop,TS val 345422=
2645 ecr 70465], length 1448
23:36:59.203680 IP (tos 0x0, ttl 100, id 18726, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0xb21a), ack 8661936, win 21177, options [nop,nop,TS val 70530=
 ecr 3454222645], length 0
23:36:59.203791 IP (tos 0x0, ttl 53, id 18305, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xff62 (corr=
ect), seq 8661936:8663384, ack 1, win 9, options [nop,nop,TS val 345422=
2645 ecr 70466], length 1448
23:36:59.203914 IP (tos 0x0, ttl 53, id 18306, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xf9ba (corr=
ect), seq 8663384:8664832, ack 1, win 9, options [nop,nop,TS val 345422=
2645 ecr 70466], length 1448
23:36:59.203926 IP (tos 0x0, ttl 100, id 18727, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0xa6ca), ack 8664832, win 21177, options [nop,nop,TS val 70530=
 ecr 3454222645], length 0
23:36:59.204037 IP (tos 0x0, ttl 53, id 18307, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xf412 (corr=
ect), seq 8664832:8666280, ack 1, win 9, options [nop,nop,TS val 345422=
2645 ecr 70466], length 1448
23:36:59.204161 IP (tos 0x0, ttl 53, id 18308, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xee6a (corr=
ect), seq 8666280:8667728, ack 1, win 9, options [nop,nop,TS val 345422=
2645 ecr 70466], length 1448
23:36:59.204173 IP (tos 0x0, ttl 100, id 18728, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x9b79), ack 8667728, win 21177, options [nop,nop,TS val 70531=
 ecr 3454222645], length 0
23:36:59.204283 IP (tos 0x0, ttl 53, id 18309, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xe8c2 (corr=
ect), seq 8667728:8669176, ack 1, win 9, options [nop,nop,TS val 345422=
2645 ecr 70466], length 1448
23:36:59.204406 IP (tos 0x0, ttl 53, id 18310, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xe31a (corr=
ect), seq 8669176:8670624, ack 1, win 9, options [nop,nop,TS val 345422=
2645 ecr 70466], length 1448
23:36:59.204418 IP (tos 0x0, ttl 100, id 18729, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x9029), ack 8670624, win 21177, options [nop,nop,TS val 70531=
 ecr 3454222645], length 0
23:36:59.204529 IP (tos 0x0, ttl 53, id 18311, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xdd72 (corr=
ect), seq 8670624:8672072, ack 1, win 9, options [nop,nop,TS val 345422=
2645 ecr 70466], length 1448
23:36:59.204653 IP (tos 0x0, ttl 53, id 18312, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xd7ca (corr=
ect), seq 8672072:8673520, ack 1, win 9, options [nop,nop,TS val 345422=
2645 ecr 70466], length 1448
23:36:59.204665 IP (tos 0x0, ttl 100, id 18730, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x84d9), ack 8673520, win 21177, options [nop,nop,TS val 70531=
 ecr 3454222645], length 0
23:36:59.204775 IP (tos 0x0, ttl 53, id 18313, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xd221 (corr=
ect), seq 8673520:8674968, ack 1, win 9, options [nop,nop,TS val 345422=
2645 ecr 70467], length 1448
23:36:59.204898 IP (tos 0x0, ttl 53, id 18314, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xcc79 (corr=
ect), seq 8674968:8676416, ack 1, win 9, options [nop,nop,TS val 345422=
2645 ecr 70467], length 1448
23:36:59.204910 IP (tos 0x0, ttl 100, id 18731, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x7989), ack 8676416, win 21177, options [nop,nop,TS val 70531=
 ecr 3454222645], length 0
23:36:59.205099 IP (tos 0x0, ttl 53, id 18315, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xc6d1 (corr=
ect), seq 8676416:8677864, ack 1, win 9, options [nop,nop,TS val 345422=
2645 ecr 70467], length 1448
23:36:59.205221 IP (tos 0x0, ttl 53, id 18316, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xc129 (corr=
ect), seq 8677864:8679312, ack 1, win 9, options [nop,nop,TS val 345422=
2645 ecr 70467], length 1448
23:36:59.205233 IP (tos 0x0, ttl 100, id 18732, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x6e38), ack 8679312, win 21177, options [nop,nop,TS val 70532=
 ecr 3454222645], length 0
23:36:59.205343 IP (tos 0x0, ttl 53, id 18317, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xbb81 (corr=
ect), seq 8679312:8680760, ack 1, win 9, options [nop,nop,TS val 345422=
2645 ecr 70467], length 1448
23:36:59.205467 IP (tos 0x0, ttl 53, id 18318, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xb5d9 (corr=
ect), seq 8680760:8682208, ack 1, win 9, options [nop,nop,TS val 345422=
2645 ecr 70467], length 1448
23:36:59.205479 IP (tos 0x0, ttl 100, id 18733, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x62e8), ack 8682208, win 21177, options [nop,nop,TS val 70532=
 ecr 3454222645], length 0
23:36:59.205724 IP (tos 0x0, ttl 53, id 18319, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xb030 (corr=
ect), seq 8682208:8683656, ack 1, win 9, options [nop,nop,TS val 345422=
2645 ecr 70468], length 1448
23:36:59.205847 IP (tos 0x0, ttl 53, id 18320, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xaa88 (corr=
ect), seq 8683656:8685104, ack 1, win 9, options [nop,nop,TS val 345422=
2645 ecr 70468], length 1448
23:36:59.205857 IP (tos 0x0, ttl 100, id 18734, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x5798), ack 8685104, win 21177, options [nop,nop,TS val 70532=
 ecr 3454222645], length 0
23:36:59.206026 IP (tos 0x0, ttl 53, id 18321, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0xa4e0 (corr=
ect), seq 8685104:8686552, ack 1, win 9, options [nop,nop,TS val 345422=
2645 ecr 70468], length 1448
23:36:59.206149 IP (tos 0x0, ttl 53, id 18322, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x9f38 (corr=
ect), seq 8686552:8688000, ack 1, win 9, options [nop,nop,TS val 345422=
2645 ecr 70468], length 1448
23:36:59.206159 IP (tos 0x0, ttl 100, id 18735, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x4c48), ack 8688000, win 21177, options [nop,nop,TS val 70532=
 ecr 3454222645], length 0
23:36:59.206469 IP (tos 0x0, ttl 53, id 18323, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x9990 (corr=
ect), seq 8688000:8689448, ack 1, win 9, options [nop,nop,TS val 345422=
2645 ecr 70468], length 1448
23:36:59.206591 IP (tos 0x0, ttl 53, id 18324, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x93e8 (corr=
ect), seq 8689448:8690896, ack 1, win 9, options [nop,nop,TS val 345422=
2645 ecr 70468], length 1448
23:36:59.206601 IP (tos 0x0, ttl 100, id 18736, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x40f7), ack 8690896, win 21177, options [nop,nop,TS val 70533=
 ecr 3454222645], length 0
23:36:59.206926 IP (tos 0x0, ttl 53, id 18325, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x8e3e (corr=
ect), seq 8690896:8692344, ack 1, win 9, options [nop,nop,TS val 345422=
2646 ecr 70469], length 1448
23:36:59.207049 IP (tos 0x0, ttl 53, id 18326, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x8896 (corr=
ect), seq 8692344:8693792, ack 1, win 9, options [nop,nop,TS val 345422=
2646 ecr 70469], length 1448
23:36:59.207059 IP (tos 0x0, ttl 100, id 18737, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x35a6), ack 8693792, win 21177, options [nop,nop,TS val 70533=
 ecr 3454222646], length 0
23:36:59.207568 IP (tos 0x0, ttl 53, id 18327, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x82ed (corr=
ect), seq 8693792:8695240, ack 1, win 9, options [nop,nop,TS val 345422=
2646 ecr 70470], length 1448
23:36:59.207691 IP (tos 0x0, ttl 53, id 18328, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x7d45 (corr=
ect), seq 8695240:8696688, ack 1, win 9, options [nop,nop,TS val 345422=
2646 ecr 70470], length 1448
23:36:59.207702 IP (tos 0x0, ttl 100, id 18738, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x2a55), ack 8696688, win 21177, options [nop,nop,TS val 70534=
 ecr 3454222646], length 0
23:36:59.208162 IP (tos 0x0, ttl 53, id 18329, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x779d (corr=
ect), seq 8696688:8698136, ack 1, win 9, options [nop,nop,TS val 345422=
2646 ecr 70470], length 1448
23:36:59.208284 IP (tos 0x0, ttl 53, id 18330, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x71f5 (corr=
ect), seq 8698136:8699584, ack 1, win 9, options [nop,nop,TS val 345422=
2646 ecr 70470], length 1448
23:36:59.208294 IP (tos 0x0, ttl 100, id 18739, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x1f04), ack 8699584, win 21177, options [nop,nop,TS val 70535=
 ecr 3454222646], length 0
23:36:59.208492 IP (tos 0x0, ttl 53, id 18331, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x6c4d (corr=
ect), seq 8699584:8701032, ack 1, win 9, options [nop,nop,TS val 345422=
2646 ecr 70470], length 1448
23:36:59.208615 IP (tos 0x0, ttl 53, id 18332, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x66a5 (corr=
ect), seq 8701032:8702480, ack 1, win 9, options [nop,nop,TS val 345422=
2646 ecr 70470], length 1448
23:36:59.208625 IP (tos 0x0, ttl 100, id 18740, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x13b4), ack 8702480, win 21177, options [nop,nop,TS val 70535=
 ecr 3454222646], length 0
23:36:59.208738 IP (tos 0x0, ttl 53, id 18333, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x60fc (corr=
ect), seq 8702480:8703928, ack 1, win 9, options [nop,nop,TS val 345422=
2646 ecr 70471], length 1448
23:36:59.208865 IP (tos 0x0, ttl 53, id 18334, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x5b54 (corr=
ect), seq 8703928:8705376, ack 1, win 9, options [nop,nop,TS val 345422=
2646 ecr 70471], length 1448
23:36:59.208874 IP (tos 0x0, ttl 100, id 18741, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0x0864), ack 8705376, win 21177, options [nop,nop,TS val 70535=
 ecr 3454222646], length 0
23:36:59.208989 IP (tos 0x0, ttl 53, id 18335, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x55ac (corr=
ect), seq 8705376:8706824, ack 1, win 9, options [nop,nop,TS val 345422=
2646 ecr 70471], length 1448
23:36:59.209108 IP (tos 0x0, ttl 53, id 18336, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [.], cksum 0x5004 (corr=
ect), seq 8706824:8708272, ack 1, win 9, options [nop,nop,TS val 345422=
2646 ecr 70471], length 1448
23:36:59.209119 IP (tos 0x0, ttl 100, id 18742, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0xfd13), ack 8708272, win 21177, options [nop,nop,TS val 70535=
 ecr 3454222646], length 0
23:36:59.209184 IP (tos 0x0, ttl 53, id 18337, offset 0, flags [DF], pr=
oto TCP (6), length 992)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [P.], cksum 0x4c50 (cor=
rect), seq 8708272:8709212, ack 1, win 9, options [nop,nop,TS val 34542=
22646 ecr 70471], length 940
23:36:59.209214 IP (tos 0x0, ttl 100, id 18743, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0xf966), ack 8709212, win 21177, options [nop,nop,TS val 70536=
 ecr 3454222646], length 0
23:36:59.209808 IP (tos 0x0, ttl 100, id 18744, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [F.], cksum 0x95fa (inc=
orrect -> 0xf965), seq 1, ack 8709212, win 21177, options [nop,nop,TS v=
al 70536 ecr 3454222646], length 0
23:36:59.273989 IP (tos 0x0, ttl 53, id 18338, offset 0, flags [DF], pr=
oto TCP (6), length 52)
    90.130.66.198.80 > AA.BB.CC.XY.47140: Flags [F.], cksum 0x4c05 (cor=
rect), seq 8709212, ack 2, win 9, options [nop,nop,TS val 3454222662 ec=
r 70536], length 0
23:36:59.274009 IP (tos 0x0, ttl 100, id 18745, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.47140 > 90.130.66.198.80: Flags [.], cksum 0x95fa (inco=
rrect -> 0xf914), ack 8709213, win 21177, options [nop,nop,TS val 70600=
 ecr 3454222662], length 0
8608 packets captured
9044 packets received by filter
418 packets dropped by kernel



> - summary of overall throughput wget sees on that transfer

--2012-02-16 23:33:30--  http://speedtest.tele2.net/1GB.zip
100%[=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D>] 1 073 741 824 5,02M/s   in 3m 29s
2012-02-16 23:36:59 (4,90 MB/s) - =AB/dev/null=BB saved [1073741824/107=
3741824]

> This should help establish whether the receiver window is really the
> limiting factor in the slow cases.
>=20
> neal
