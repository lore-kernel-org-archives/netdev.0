From: alekcejk@googlemail.com
Subject: Re: Re: Re: limited network bandwidth with 3.2.x kernels
Date: Tue, 14 Feb 2012 01:09:15 +0200
Message-ID: <1486820.tZrzp7eZ2l@localhost.localdomain>
References: <8633039.fHPLx6GNq3@localhost.localdomain> <1329173056.2523.14.camel@edumazet-laptop> <CADVnQykiHqmjCSofbMVL13iZaPhuJwRDUqPoCw8f2ynzpfdQTA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Neal Cardwell <ncardwell@google.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:50641 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753296Ab2BMXJm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2012 18:09:42 -0500
Received: by bkcjm19 with SMTP id jm19so4969508bkc.19
        for <netdev@vger.kernel.org>; Mon, 13 Feb 2012 15:09:40 -0800 (PST)
In-Reply-To: <CADVnQykiHqmjCSofbMVL13iZaPhuJwRDUqPoCw8f2ynzpfdQTA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=F7 =D3=CF=CF=C2=DD=C5=CE=C9=C9 =CF=D4 =F0=CF=CE=C5=C4=C5=CC=D8=CE=C9=CB=
 13 =C6=C5=D7=D2=C1=CC=D1 2012 17:51:20 =D7=D9 =CE=C1=D0=C9=D3=C1=CC=C9=
:
> Hi,
>=20
> Could you also please post a tcpdump of a "good" transfer on a 3.1.x
> kernel to the same server? It would be nice to make sure the options
> and advertised windows are the same in both cases.
>=20
> neal

Hi,

Here tcpdump for 3.1.10 kernel (2.6.41.10-3.fc15.i686):

tcpdump: verbose output suppressed, use -v or -vv for full protocol dec=
ode
listening on eth0, link-type EN10MB (Ethernet), capture size 65535 byte=
s
01:03:59.499533 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 1015030570:1015032018, ack 3902015221, win 46, options [nop,nop,TS v=
al 3724352664 ecr 4211303], length 1448
01:03:59.499655 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 1448:2896, ack 1, win 46, options [nop,nop,TS val 3724352664 ecr 421=
1303], length 1448
01:03:59.499665 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 2896, win 41449, options [nop,nop,TS val 4211360 ecr 3724352664], le=
ngth 0
01:03:59.499778 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 2896:4344, ack 1, win 46, options [nop,nop,TS val 3724352664 ecr 421=
1303], length 1448
01:03:59.499900 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 4344:5792, ack 1, win 46, options [nop,nop,TS val 3724352664 ecr 421=
1303], length 1448
01:03:59.499908 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 5792, win 41449, options [nop,nop,TS val 4211360 ecr 3724352664], le=
ngth 0
01:03:59.500028 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 5792:7240, ack 1, win 46, options [nop,nop,TS val 3724352664 ecr 421=
1304], length 1448
01:03:59.500149 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 7240:8688, ack 1, win 46, options [nop,nop,TS val 3724352664 ecr 421=
1304], length 1448
01:03:59.500159 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 8688, win 41449, options [nop,nop,TS val 4211361 ecr 3724352664], le=
ngth 0
01:03:59.500270 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 8688:10136, ack 1, win 46, options [nop,nop,TS val 3724352664 ecr 42=
11304], length 1448
01:03:59.500396 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 10136:11584, ack 1, win 46, options [nop,nop,TS val 3724352664 ecr 4=
211304], length 1448
01:03:59.500407 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 11584, win 41449, options [nop,nop,TS val 4211361 ecr 3724352664], l=
ength 0
01:03:59.500516 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 11584:13032, ack 1, win 46, options [nop,nop,TS val 3724352664 ecr 4=
211304], length 1448
01:03:59.500639 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 13032:14480, ack 1, win 46, options [nop,nop,TS val 3724352664 ecr 4=
211304], length 1448
01:03:59.500648 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 14480, win 41449, options [nop,nop,TS val 4211361 ecr 3724352664], l=
ength 0
01:03:59.500764 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 14480:15928, ack 1, win 46, options [nop,nop,TS val 3724352664 ecr 4=
211304], length 1448
01:03:59.500889 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 15928:17376, ack 1, win 46, options [nop,nop,TS val 3724352664 ecr 4=
211304], length 1448
01:03:59.500899 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 17376, win 41449, options [nop,nop,TS val 4211361 ecr 3724352664], l=
ength 0
01:03:59.501007 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 17376:18824, ack 1, win 46, options [nop,nop,TS val 3724352664 ecr 4=
211304], length 1448
01:03:59.501134 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 18824:20272, ack 1, win 46, options [nop,nop,TS val 3724352664 ecr 4=
211304], length 1448
01:03:59.501142 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 20272, win 41449, options [nop,nop,TS val 4211362 ecr 3724352664], l=
ength 0
01:03:59.501256 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 20272:21720, ack 1, win 46, options [nop,nop,TS val 3724352664 ecr 4=
211305], length 1448
01:03:59.501376 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 21720:23168, ack 1, win 46, options [nop,nop,TS val 3724352664 ecr 4=
211305], length 1448
01:03:59.501384 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 23168, win 41449, options [nop,nop,TS val 4211362 ecr 3724352664], l=
ength 0
01:03:59.501502 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 23168:24616, ack 1, win 46, options [nop,nop,TS val 3724352664 ecr 4=
211305], length 1448
01:03:59.501624 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 24616:26064, ack 1, win 46, options [nop,nop,TS val 3724352664 ecr 4=
211305], length 1448
01:03:59.501636 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 26064, win 41449, options [nop,nop,TS val 4211362 ecr 3724352664], l=
ength 0
01:03:59.501747 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 26064:27512, ack 1, win 46, options [nop,nop,TS val 3724352665 ecr 4=
211305], length 1448
01:03:59.501872 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 27512:28960, ack 1, win 46, options [nop,nop,TS val 3724352665 ecr 4=
211305], length 1448
01:03:59.501885 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 28960, win 41449, options [nop,nop,TS val 4211362 ecr 3724352665], l=
ength 0
01:03:59.501993 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 28960:30408, ack 1, win 46, options [nop,nop,TS val 3724352665 ecr 4=
211305], length 1448
01:03:59.502116 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 30408:31856, ack 1, win 46, options [nop,nop,TS val 3724352665 ecr 4=
211305], length 1448
01:03:59.502127 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 31856, win 41449, options [nop,nop,TS val 4211363 ecr 3724352665], l=
ength 0
01:03:59.502238 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 31856:33304, ack 1, win 46, options [nop,nop,TS val 3724352665 ecr 4=
211306], length 1448
01:03:59.502361 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 33304:34752, ack 1, win 46, options [nop,nop,TS val 3724352665 ecr 4=
211306], length 1448
01:03:59.502372 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 34752, win 41449, options [nop,nop,TS val 4211363 ecr 3724352665], l=
ength 0
01:03:59.502486 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 34752:36200, ack 1, win 46, options [nop,nop,TS val 3724352665 ecr 4=
211306], length 1448
01:03:59.502607 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 36200:37648, ack 1, win 46, options [nop,nop,TS val 3724352665 ecr 4=
211306], length 1448
01:03:59.502618 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 37648, win 41449, options [nop,nop,TS val 4211363 ecr 3724352665], l=
ength 0
01:03:59.502730 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 37648:39096, ack 1, win 46, options [nop,nop,TS val 3724352665 ecr 4=
211306], length 1448
01:03:59.502854 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 39096:40544, ack 1, win 46, options [nop,nop,TS val 3724352665 ecr 4=
211306], length 1448
01:03:59.502864 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 40544, win 41449, options [nop,nop,TS val 4211363 ecr 3724352665], l=
ength 0
01:03:59.502977 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 40544:41992, ack 1, win 46, options [nop,nop,TS val 3724352665 ecr 4=
211306], length 1448
01:03:59.503099 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 41992:43440, ack 1, win 46, options [nop,nop,TS val 3724352665 ecr 4=
211306], length 1448
01:03:59.503111 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 43440, win 41449, options [nop,nop,TS val 4211364 ecr 3724352665], l=
ength 0
01:03:59.503223 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 43440:44888, ack 1, win 46, options [nop,nop,TS val 3724352665 ecr 4=
211307], length 1448
01:03:59.503345 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 44888:46336, ack 1, win 46, options [nop,nop,TS val 3724352665 ecr 4=
211307], length 1448
01:03:59.503357 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 46336, win 41449, options [nop,nop,TS val 4211364 ecr 3724352665], l=
ength 0
01:03:59.503469 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 46336:47784, ack 1, win 46, options [nop,nop,TS val 3724352665 ecr 4=
211307], length 1448
01:03:59.503592 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 47784:49232, ack 1, win 46, options [nop,nop,TS val 3724352665 ecr 4=
211307], length 1448
01:03:59.503603 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 49232, win 41449, options [nop,nop,TS val 4211364 ecr 3724352665], l=
ength 0
01:03:59.503714 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 49232:50680, ack 1, win 46, options [nop,nop,TS val 3724352665 ecr 4=
211307], length 1448
01:03:59.503838 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 50680:52128, ack 1, win 46, options [nop,nop,TS val 3724352665 ecr 4=
211307], length 1448
01:03:59.503849 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 52128, win 41449, options [nop,nop,TS val 4211364 ecr 3724352665], l=
ength 0
01:03:59.503960 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 52128:53576, ack 1, win 46, options [nop,nop,TS val 3724352665 ecr 4=
211307], length 1448
01:03:59.504084 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 53576:55024, ack 1, win 46, options [nop,nop,TS val 3724352665 ecr 4=
211307], length 1448
01:03:59.504095 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 55024, win 41449, options [nop,nop,TS val 4211365 ecr 3724352665], l=
ength 0
01:03:59.504207 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 55024:56472, ack 1, win 46, options [nop,nop,TS val 3724352666 ecr 4=
211308], length 1448
01:03:59.504330 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 56472:57920, ack 1, win 46, options [nop,nop,TS val 3724352666 ecr 4=
211308], length 1448
01:03:59.504341 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 57920, win 41449, options [nop,nop,TS val 4211365 ecr 3724352666], l=
ength 0
01:03:59.504453 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 57920:59368, ack 1, win 46, options [nop,nop,TS val 3724352666 ecr 4=
211308], length 1448
01:03:59.504576 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 59368:60816, ack 1, win 46, options [nop,nop,TS val 3724352666 ecr 4=
211308], length 1448
01:03:59.504587 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 60816, win 41449, options [nop,nop,TS val 4211365 ecr 3724352666], l=
ength 0
01:03:59.504700 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 60816:62264, ack 1, win 46, options [nop,nop,TS val 3724352666 ecr 4=
211308], length 1448
01:03:59.504823 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 62264:63712, ack 1, win 46, options [nop,nop,TS val 3724352666 ecr 4=
211308], length 1448
01:03:59.504834 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 63712, win 41449, options [nop,nop,TS val 4211365 ecr 3724352666], l=
ength 0
01:03:59.504946 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 63712:65160, ack 1, win 46, options [nop,nop,TS val 3724352666 ecr 4=
211308], length 1448
01:03:59.505068 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 65160:66608, ack 1, win 46, options [nop,nop,TS val 3724352666 ecr 4=
211308], length 1448
01:03:59.505079 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 66608, win 41449, options [nop,nop,TS val 4211365 ecr 3724352666], l=
ength 0
01:03:59.505199 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 66608:68056, ack 1, win 46, options [nop,nop,TS val 3724352666 ecr 4=
211309], length 1448
01:03:59.505322 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 68056:69504, ack 1, win 46, options [nop,nop,TS val 3724352666 ecr 4=
211309], length 1448
01:03:59.505333 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 69504, win 41449, options [nop,nop,TS val 4211366 ecr 3724352666], l=
ength 0
01:03:59.505445 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 69504:70952, ack 1, win 46, options [nop,nop,TS val 3724352666 ecr 4=
211309], length 1448
01:03:59.505568 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 70952:72400, ack 1, win 46, options [nop,nop,TS val 3724352666 ecr 4=
211309], length 1448
01:03:59.505579 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 72400, win 41449, options [nop,nop,TS val 4211366 ecr 3724352666], l=
ength 0
01:03:59.505690 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 72400:73848, ack 1, win 46, options [nop,nop,TS val 3724352666 ecr 4=
211309], length 1448
01:03:59.505813 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 73848:75296, ack 1, win 46, options [nop,nop,TS val 3724352666 ecr 4=
211309], length 1448
01:03:59.505824 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 75296, win 41449, options [nop,nop,TS val 4211366 ecr 3724352666], l=
ength 0
01:03:59.505936 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 75296:76744, ack 1, win 46, options [nop,nop,TS val 3724352666 ecr 4=
211309], length 1448
01:03:59.506060 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 76744:78192, ack 1, win 46, options [nop,nop,TS val 3724352666 ecr 4=
211309], length 1448
01:03:59.506071 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 78192, win 41449, options [nop,nop,TS val 4211366 ecr 3724352666], l=
ength 0
01:03:59.506182 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 78192:79640, ack 1, win 46, options [nop,nop,TS val 3724352666 ecr 4=
211310], length 1448
01:03:59.506305 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 79640:81088, ack 1, win 46, options [nop,nop,TS val 3724352666 ecr 4=
211310], length 1448
01:03:59.506316 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 81088, win 41449, options [nop,nop,TS val 4211367 ecr 3724352666], l=
ength 0
01:03:59.506428 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 81088:82536, ack 1, win 46, options [nop,nop,TS val 3724352666 ecr 4=
211310], length 1448
01:03:59.506551 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 82536:83984, ack 1, win 46, options [nop,nop,TS val 3724352666 ecr 4=
211310], length 1448
01:03:59.506562 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 83984, win 41449, options [nop,nop,TS val 4211367 ecr 3724352666], l=
ength 0
01:03:59.506674 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 83984:85432, ack 1, win 46, options [nop,nop,TS val 3724352667 ecr 4=
211310], length 1448
01:03:59.506797 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 85432:86880, ack 1, win 46, options [nop,nop,TS val 3724352667 ecr 4=
211310], length 1448
01:03:59.506808 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 86880, win 41449, options [nop,nop,TS val 4211367 ecr 3724352667], l=
ength 0
01:03:59.506920 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 86880:88328, ack 1, win 46, options [nop,nop,TS val 3724352667 ecr 4=
211310], length 1448
01:03:59.507045 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 88328:89776, ack 1, win 46, options [nop,nop,TS val 3724352667 ecr 4=
211310], length 1448
01:03:59.507055 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 89776, win 41449, options [nop,nop,TS val 4211367 ecr 3724352667], l=
ength 0
01:03:59.507167 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 89776:91224, ack 1, win 46, options [nop,nop,TS val 3724352667 ecr 4=
211311], length 1448
01:03:59.507289 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 91224:92672, ack 1, win 46, options [nop,nop,TS val 3724352667 ecr 4=
211311], length 1448
01:03:59.507300 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 92672, win 41449, options [nop,nop,TS val 4211368 ecr 3724352667], l=
ength 0
01:03:59.507413 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 92672:94120, ack 1, win 46, options [nop,nop,TS val 3724352667 ecr 4=
211311], length 1448
01:03:59.507535 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 94120:95568, ack 1, win 46, options [nop,nop,TS val 3724352667 ecr 4=
211311], length 1448
01:03:59.507546 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 95568, win 41449, options [nop,nop,TS val 4211368 ecr 3724352667], l=
ength 0
01:03:59.507666 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 95568:97016, ack 1, win 46, options [nop,nop,TS val 3724352667 ecr 4=
211311], length 1448
01:03:59.507790 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 97016:98464, ack 1, win 46, options [nop,nop,TS val 3724352667 ecr 4=
211311], length 1448
01:03:59.507801 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 98464, win 41449, options [nop,nop,TS val 4211368 ecr 3724352667], l=
ength 0
01:03:59.507912 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 98464:99912, ack 1, win 46, options [nop,nop,TS val 3724352667 ecr 4=
211311], length 1448
01:03:59.508035 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 99912:101360, ack 1, win 46, options [nop,nop,TS val 3724352667 ecr =
4211311], length 1448
01:03:59.508046 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 101360, win 41449, options [nop,nop,TS val 4211368 ecr 3724352667], =
length 0
01:03:59.508159 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 101360:102808, ack 1, win 46, options [nop,nop,TS val 3724352667 ecr=
 4211312], length 1448
01:03:59.508280 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 102808:104256, ack 1, win 46, options [nop,nop,TS val 3724352667 ecr=
 4211312], length 1448
01:03:59.508291 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 104256, win 41449, options [nop,nop,TS val 4211369 ecr 3724352667], =
length 0
01:03:59.508404 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 104256:105704, ack 1, win 46, options [nop,nop,TS val 3724352667 ecr=
 4211312], length 1448
01:03:59.508527 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 105704:107152, ack 1, win 46, options [nop,nop,TS val 3724352667 ecr=
 4211312], length 1448
01:03:59.508538 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 107152, win 41449, options [nop,nop,TS val 4211369 ecr 3724352667], =
length 0
01:03:59.508650 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 107152:108600, ack 1, win 46, options [nop,nop,TS val 3724352667 ecr=
 4211312], length 1448
01:03:59.508774 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 108600:110048, ack 1, win 46, options [nop,nop,TS val 3724352667 ecr=
 4211312], length 1448
01:03:59.508785 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 110048, win 41449, options [nop,nop,TS val 4211369 ecr 3724352667], =
length 0
01:03:59.508896 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 110048:111496, ack 1, win 46, options [nop,nop,TS val 3724352667 ecr=
 4211312], length 1448
01:03:59.509019 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 111496:112944, ack 1, win 46, options [nop,nop,TS val 3724352667 ecr=
 4211312], length 1448
01:03:59.509030 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 112944, win 41449, options [nop,nop,TS val 4211369 ecr 3724352667], =
length 0
01:03:59.509142 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 112944:114392, ack 1, win 46, options [nop,nop,TS val 3724352668 ecr=
 4211313], length 1448
01:03:59.509266 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 114392:115840, ack 1, win 46, options [nop,nop,TS val 3724352668 ecr=
 4211313], length 1448
01:03:59.509277 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 115840, win 41449, options [nop,nop,TS val 4211370 ecr 3724352668], =
length 0
01:03:59.509389 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 115840:117288, ack 1, win 46, options [nop,nop,TS val 3724352668 ecr=
 4211313], length 1448
01:03:59.509511 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 117288:118736, ack 1, win 46, options [nop,nop,TS val 3724352668 ecr=
 4211313], length 1448
01:03:59.509522 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 118736, win 41449, options [nop,nop,TS val 4211370 ecr 3724352668], =
length 0
01:03:59.509634 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 118736:120184, ack 1, win 46, options [nop,nop,TS val 3724352668 ecr=
 4211313], length 1448
01:03:59.509757 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 120184:121632, ack 1, win 46, options [nop,nop,TS val 3724352668 ecr=
 4211313], length 1448
01:03:59.509768 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 121632, win 41449, options [nop,nop,TS val 4211370 ecr 3724352668], =
length 0
01:03:59.509881 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 121632:123080, ack 1, win 46, options [nop,nop,TS val 3724352668 ecr=
 4211313], length 1448
01:03:59.510004 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 123080:124528, ack 1, win 46, options [nop,nop,TS val 3724352668 ecr=
 4211313], length 1448
01:03:59.510017 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 124528, win 41449, options [nop,nop,TS val 4211370 ecr 3724352668], =
length 0
01:03:59.510128 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 124528:125976, ack 1, win 46, options [nop,nop,TS val 3724352668 ecr=
 4211314], length 1448
01:03:59.510252 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 125976:127424, ack 1, win 46, options [nop,nop,TS val 3724352668 ecr=
 4211314], length 1448
01:03:59.510263 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 127424, win 41449, options [nop,nop,TS val 4211371 ecr 3724352668], =
length 0
01:03:59.510374 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 127424:128872, ack 1, win 46, options [nop,nop,TS val 3724352668 ecr=
 4211314], length 1448
01:03:59.510497 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 128872:130320, ack 1, win 46, options [nop,nop,TS val 3724352668 ecr=
 4211314], length 1448
01:03:59.510510 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 130320, win 41449, options [nop,nop,TS val 4211371 ecr 3724352668], =
length 0
01:03:59.510618 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 130320:131768, ack 1, win 46, options [nop,nop,TS val 3724352668 ecr=
 4211314], length 1448
01:03:59.510743 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 131768:133216, ack 1, win 46, options [nop,nop,TS val 3724352668 ecr=
 4211314], length 1448
01:03:59.510754 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 133216, win 41449, options [nop,nop,TS val 4211371 ecr 3724352668], =
length 0
01:03:59.510865 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 133216:134664, ack 1, win 46, options [nop,nop,TS val 3724352668 ecr=
 4211314], length 1448
01:03:59.510989 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 134664:136112, ack 1, win 46, options [nop,nop,TS val 3724352668 ecr=
 4211314], length 1448
01:03:59.510999 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 136112, win 41449, options [nop,nop,TS val 4211371 ecr 3724352668], =
length 0
01:03:59.511112 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 136112:137560, ack 1, win 46, options [nop,nop,TS val 3724352668 ecr=
 4211315], length 1448
01:03:59.511234 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 137560:139008, ack 1, win 46, options [nop,nop,TS val 3724352668 ecr=
 4211315], length 1448
01:03:59.511245 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 139008, win 41449, options [nop,nop,TS val 4211372 ecr 3724352668], =
length 0
01:03:59.511357 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 139008:140456, ack 1, win 46, options [nop,nop,TS val 3724352668 ecr=
 4211315], length 1448
01:03:59.511480 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 140456:141904, ack 1, win 46, options [nop,nop,TS val 3724352668 ecr=
 4211315], length 1448
01:03:59.511491 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 141904, win 41449, options [nop,nop,TS val 4211372 ecr 3724352668], =
length 0
01:03:59.511603 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 141904:143352, ack 1, win 46, options [nop,nop,TS val 3724352669 ecr=
 4211315], length 1448
01:03:59.511726 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 143352:144800, ack 1, win 46, options [nop,nop,TS val 3724352669 ecr=
 4211315], length 1448
01:03:59.511737 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 144800, win 41449, options [nop,nop,TS val 4211372 ecr 3724352669], =
length 0
01:03:59.511850 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 144800:146248, ack 1, win 46, options [nop,nop,TS val 3724352669 ecr=
 4211316], length 1448
01:03:59.511972 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 146248:147696, ack 1, win 46, options [nop,nop,TS val 3724352669 ecr=
 4211316], length 1448
01:03:59.511983 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 147696, win 41449, options [nop,nop,TS val 4211372 ecr 3724352669], =
length 0
01:03:59.512095 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 147696:149144, ack 1, win 46, options [nop,nop,TS val 3724352669 ecr=
 4211316], length 1448
01:03:59.512218 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 149144:150592, ack 1, win 46, options [nop,nop,TS val 3724352669 ecr=
 4211316], length 1448
01:03:59.512228 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 150592, win 41449, options [nop,nop,TS val 4211373 ecr 3724352669], =
length 0
01:03:59.512341 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 150592:152040, ack 1, win 46, options [nop,nop,TS val 3724352669 ecr=
 4211316], length 1448
01:03:59.512464 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 152040:153488, ack 1, win 46, options [nop,nop,TS val 3724352669 ecr=
 4211316], length 1448
01:03:59.512475 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 153488, win 41449, options [nop,nop,TS val 4211373 ecr 3724352669], =
length 0
01:03:59.512587 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 153488:154936, ack 1, win 46, options [nop,nop,TS val 3724352669 ecr=
 4211316], length 1448
01:03:59.512711 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 154936:156384, ack 1, win 46, options [nop,nop,TS val 3724352669 ecr=
 4211316], length 1448
01:03:59.512722 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 156384, win 41449, options [nop,nop,TS val 4211373 ecr 3724352669], =
length 0
01:03:59.512835 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 156384:157832, ack 1, win 46, options [nop,nop,TS val 3724352669 ecr=
 4211317], length 1448
01:03:59.512956 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 157832:159280, ack 1, win 46, options [nop,nop,TS val 3724352669 ecr=
 4211317], length 1448
01:03:59.512967 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 159280, win 41449, options [nop,nop,TS val 4211373 ecr 3724352669], =
length 0
01:03:59.513080 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 159280:160728, ack 1, win 46, options [nop,nop,TS val 3724352669 ecr=
 4211317], length 1448
01:03:59.513202 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 160728:162176, ack 1, win 46, options [nop,nop,TS val 3724352669 ecr=
 4211317], length 1448
01:03:59.513214 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 162176, win 41449, options [nop,nop,TS val 4211374 ecr 3724352669], =
length 0
01:03:59.513326 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 162176:163624, ack 1, win 46, options [nop,nop,TS val 3724352669 ecr=
 4211317], length 1448
01:03:59.513449 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 163624:165072, ack 1, win 46, options [nop,nop,TS val 3724352669 ecr=
 4211317], length 1448
01:03:59.513461 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 165072, win 41449, options [nop,nop,TS val 4211374 ecr 3724352669], =
length 0
01:03:59.513572 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 165072:166520, ack 1, win 46, options [nop,nop,TS val 3724352669 ecr=
 4211317], length 1448
01:03:59.513696 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 166520:167968, ack 1, win 46, options [nop,nop,TS val 3724352669 ecr=
 4211317], length 1448
01:03:59.513710 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 167968, win 41449, options [nop,nop,TS val 4211374 ecr 3724352669], =
length 0
01:03:59.513818 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 167968:169416, ack 1, win 46, options [nop,nop,TS val 3724352670 ecr=
 4211317], length 1448
01:03:59.513941 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 169416:170864, ack 1, win 46, options [nop,nop,TS val 3724352670 ecr=
 4211317], length 1448
01:03:59.513952 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 170864, win 41449, options [nop,nop,TS val 4211374 ecr 3724352670], =
length 0
01:03:59.514064 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 170864:172312, ack 1, win 46, options [nop,nop,TS val 3724352670 ecr=
 4211317], length 1448
01:03:59.514186 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 172312:173760, ack 1, win 46, options [nop,nop,TS val 3724352670 ecr=
 4211317], length 1448
01:03:59.514197 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 173760, win 41449, options [nop,nop,TS val 4211375 ecr 3724352670], =
length 0
01:03:59.514310 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 173760:175208, ack 1, win 46, options [nop,nop,TS val 3724352670 ecr=
 4211318], length 1448
01:03:59.514434 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 175208:176656, ack 1, win 46, options [nop,nop,TS val 3724352670 ecr=
 4211318], length 1448
01:03:59.514445 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 176656, win 41449, options [nop,nop,TS val 4211375 ecr 3724352670], =
length 0
01:03:59.514556 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 176656:178104, ack 1, win 46, options [nop,nop,TS val 3724352670 ecr=
 4211318], length 1448
01:03:59.514679 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 178104:179552, ack 1, win 46, options [nop,nop,TS val 3724352670 ecr=
 4211318], length 1448
01:03:59.514690 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 179552, win 41449, options [nop,nop,TS val 4211375 ecr 3724352670], =
length 0
01:03:59.514802 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 179552:181000, ack 1, win 46, options [nop,nop,TS val 3724352670 ecr=
 4211318], length 1448
01:03:59.514925 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 181000:182448, ack 1, win 46, options [nop,nop,TS val 3724352670 ecr=
 4211318], length 1448
01:03:59.514936 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 182448, win 41449, options [nop,nop,TS val 4211375 ecr 3724352670], =
length 0
01:03:59.515048 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 182448:183896, ack 1, win 46, options [nop,nop,TS val 3724352670 ecr=
 4211318], length 1448
01:03:59.515171 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 183896:185344, ack 1, win 46, options [nop,nop,TS val 3724352670 ecr=
 4211318], length 1448
01:03:59.515181 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 185344, win 41449, options [nop,nop,TS val 4211376 ecr 3724352670], =
length 0
01:03:59.515294 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 185344:186792, ack 1, win 46, options [nop,nop,TS val 3724352670 ecr=
 4211319], length 1448
01:03:59.515418 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 186792:188240, ack 1, win 46, options [nop,nop,TS val 3724352670 ecr=
 4211319], length 1448
01:03:59.515428 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 188240, win 41449, options [nop,nop,TS val 4211376 ecr 3724352670], =
length 0
01:03:59.515540 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 188240:189688, ack 1, win 46, options [nop,nop,TS val 3724352670 ecr=
 4211319], length 1448
01:03:59.515664 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 189688:191136, ack 1, win 46, options [nop,nop,TS val 3724352670 ecr=
 4211319], length 1448
01:03:59.515675 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 191136, win 41449, options [nop,nop,TS val 4211376 ecr 3724352670], =
length 0
01:03:59.515793 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 191136:192584, ack 1, win 46, options [nop,nop,TS val 3724352670 ecr=
 4211319], length 1448
01:03:59.515916 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 192584:194032, ack 1, win 46, options [nop,nop,TS val 3724352670 ecr=
 4211319], length 1448
01:03:59.515927 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 194032, win 41449, options [nop,nop,TS val 4211376 ecr 3724352670], =
length 0
01:03:59.516040 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 194032:195480, ack 1, win 46, options [nop,nop,TS val 3724352670 ecr=
 4211319], length 1448
01:03:59.516162 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 195480:196928, ack 1, win 46, options [nop,nop,TS val 3724352670 ecr=
 4211319], length 1448
01:03:59.516173 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 196928, win 41449, options [nop,nop,TS val 4211377 ecr 3724352670], =
length 0
01:03:59.516285 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 196928:198376, ack 1, win 46, options [nop,nop,TS val 3724352671 ecr=
 4211320], length 1448
01:03:59.516410 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 198376:199824, ack 1, win 46, options [nop,nop,TS val 3724352671 ecr=
 4211320], length 1448
01:03:59.516420 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 199824, win 41449, options [nop,nop,TS val 4211377 ecr 3724352671], =
length 0
01:03:59.516532 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 199824:201272, ack 1, win 46, options [nop,nop,TS val 3724352671 ecr=
 4211320], length 1448
01:03:59.516655 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 201272:202720, ack 1, win 46, options [nop,nop,TS val 3724352671 ecr=
 4211320], length 1448
01:03:59.516665 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 202720, win 41449, options [nop,nop,TS val 4211377 ecr 3724352671], =
length 0
01:03:59.516777 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 202720:204168, ack 1, win 46, options [nop,nop,TS val 3724352671 ecr=
 4211320], length 1448
01:03:59.516900 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 204168:205616, ack 1, win 46, options [nop,nop,TS val 3724352671 ecr=
 4211320], length 1448
01:03:59.516911 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 205616, win 41449, options [nop,nop,TS val 4211377 ecr 3724352671], =
length 0
01:03:59.517024 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 205616:207064, ack 1, win 46, options [nop,nop,TS val 3724352671 ecr=
 4211320], length 1448
01:03:59.517146 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 207064:208512, ack 1, win 46, options [nop,nop,TS val 3724352671 ecr=
 4211320], length 1448
01:03:59.517157 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 208512, win 41449, options [nop,nop,TS val 4211378 ecr 3724352671], =
length 0
01:03:59.517270 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [P.], =
seq 208512:209960, ack 1, win 46, options [nop,nop,TS val 3724352671 ec=
r 4211321], length 1448
01:03:59.517393 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 209960:211408, ack 1, win 46, options [nop,nop,TS val 3724352671 ecr=
 4211321], length 1448
01:03:59.517403 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 211408, win 41449, options [nop,nop,TS val 4211378 ecr 3724352671], =
length 0
01:03:59.517516 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 211408:212856, ack 1, win 46, options [nop,nop,TS val 3724352671 ecr=
 4211321], length 1448
01:03:59.517639 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 212856:214304, ack 1, win 46, options [nop,nop,TS val 3724352671 ecr=
 4211321], length 1448
01:03:59.517650 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 214304, win 41449, options [nop,nop,TS val 4211378 ecr 3724352671], =
length 0
01:03:59.517763 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 214304:215752, ack 1, win 46, options [nop,nop,TS val 3724352671 ecr=
 4211321], length 1448
01:03:59.517884 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 215752:217200, ack 1, win 46, options [nop,nop,TS val 3724352671 ecr=
 4211321], length 1448
01:03:59.517895 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 217200, win 41449, options [nop,nop,TS val 4211378 ecr 3724352671], =
length 0
01:03:59.518008 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 217200:218648, ack 1, win 46, options [nop,nop,TS val 3724352671 ecr=
 4211321], length 1448
01:03:59.518131 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 218648:220096, ack 1, win 46, options [nop,nop,TS val 3724352671 ecr=
 4211321], length 1448
01:03:59.518142 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 220096, win 41449, options [nop,nop,TS val 4211379 ecr 3724352671], =
length 0
01:03:59.518254 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 220096:221544, ack 1, win 46, options [nop,nop,TS val 3724352671 ecr=
 4211322], length 1448
01:03:59.518377 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 221544:222992, ack 1, win 46, options [nop,nop,TS val 3724352671 ecr=
 4211322], length 1448
01:03:59.518388 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 222992, win 41449, options [nop,nop,TS val 4211379 ecr 3724352671], =
length 0
01:03:59.518500 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 222992:224440, ack 1, win 46, options [nop,nop,TS val 3724352671 ecr=
 4211322], length 1448
01:03:59.518623 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 224440:225888, ack 1, win 46, options [nop,nop,TS val 3724352671 ecr=
 4211322], length 1448
01:03:59.518634 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 225888, win 41449, options [nop,nop,TS val 4211379 ecr 3724352671], =
length 0
01:03:59.518746 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 225888:227336, ack 1, win 46, options [nop,nop,TS val 3724352672 ecr=
 4211322], length 1448
01:03:59.518869 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 227336:228784, ack 1, win 46, options [nop,nop,TS val 3724352672 ecr=
 4211322], length 1448
01:03:59.518880 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 228784, win 41449, options [nop,nop,TS val 4211379 ecr 3724352672], =
length 0
01:03:59.518994 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 228784:230232, ack 1, win 46, options [nop,nop,TS val 3724352672 ecr=
 4211322], length 1448
01:03:59.519115 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 230232:231680, ack 1, win 46, options [nop,nop,TS val 3724352672 ecr=
 4211322], length 1448
01:03:59.519126 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 231680, win 41449, options [nop,nop,TS val 4211380 ecr 3724352672], =
length 0
01:03:59.519238 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 231680:233128, ack 1, win 46, options [nop,nop,TS val 3724352672 ecr=
 4211323], length 1448
01:03:59.519362 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 233128:234576, ack 1, win 46, options [nop,nop,TS val 3724352672 ecr=
 4211323], length 1448
01:03:59.519373 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 234576, win 41449, options [nop,nop,TS val 4211380 ecr 3724352672], =
length 0
01:03:59.519484 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 234576:236024, ack 1, win 46, options [nop,nop,TS val 3724352672 ecr=
 4211323], length 1448
01:03:59.519607 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 236024:237472, ack 1, win 46, options [nop,nop,TS val 3724352672 ecr=
 4211323], length 1448
01:03:59.519618 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 237472, win 41449, options [nop,nop,TS val 4211380 ecr 3724352672], =
length 0
01:03:59.519730 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 237472:238920, ack 1, win 46, options [nop,nop,TS val 3724352672 ecr=
 4211323], length 1448
01:03:59.519854 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 238920:240368, ack 1, win 46, options [nop,nop,TS val 3724352672 ecr=
 4211323], length 1448
01:03:59.519864 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 240368, win 41449, options [nop,nop,TS val 4211380 ecr 3724352672], =
length 0
01:03:59.519977 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 240368:241816, ack 1, win 46, options [nop,nop,TS val 3724352672 ecr=
 4211323], length 1448
01:03:59.520100 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 241816:243264, ack 1, win 46, options [nop,nop,TS val 3724352672 ecr=
 4211323], length 1448
01:03:59.520111 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 243264, win 41449, options [nop,nop,TS val 4211381 ecr 3724352672], =
length 0
01:03:59.520222 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 243264:244712, ack 1, win 46, options [nop,nop,TS val 3724352672 ecr=
 4211324], length 1448
01:03:59.520346 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 244712:246160, ack 1, win 46, options [nop,nop,TS val 3724352672 ecr=
 4211324], length 1448
01:03:59.520357 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 246160, win 41449, options [nop,nop,TS val 4211381 ecr 3724352672], =
length 0
01:03:59.520468 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 246160:247608, ack 1, win 46, options [nop,nop,TS val 3724352672 ecr=
 4211324], length 1448
01:03:59.520591 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 247608:249056, ack 1, win 46, options [nop,nop,TS val 3724352672 ecr=
 4211324], length 1448
01:03:59.520602 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 249056, win 41449, options [nop,nop,TS val 4211381 ecr 3724352672], =
length 0
01:03:59.520715 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 249056:250504, ack 1, win 46, options [nop,nop,TS val 3724352672 ecr=
 4211324], length 1448
01:03:59.520838 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 250504:251952, ack 1, win 46, options [nop,nop,TS val 3724352672 ecr=
 4211324], length 1448
01:03:59.520849 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 251952, win 41449, options [nop,nop,TS val 4211381 ecr 3724352672], =
length 0
01:03:59.520961 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 251952:253400, ack 1, win 46, options [nop,nop,TS val 3724352672 ecr=
 4211324], length 1448
01:03:59.521085 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 253400:254848, ack 1, win 46, options [nop,nop,TS val 3724352672 ecr=
 4211324], length 1448
01:03:59.521096 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 254848, win 41449, options [nop,nop,TS val 4211382 ecr 3724352672], =
length 0
01:03:59.521207 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 254848:256296, ack 1, win 46, options [nop,nop,TS val 3724352673 ecr=
 4211325], length 1448
01:03:59.521331 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 256296:257744, ack 1, win 46, options [nop,nop,TS val 3724352673 ecr=
 4211325], length 1448
01:03:59.521341 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 257744, win 41449, options [nop,nop,TS val 4211382 ecr 3724352673], =
length 0
01:03:59.521453 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 257744:259192, ack 1, win 46, options [nop,nop,TS val 3724352673 ecr=
 4211325], length 1448
01:03:59.521576 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 259192:260640, ack 1, win 46, options [nop,nop,TS val 3724352673 ecr=
 4211325], length 1448
01:03:59.521586 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 260640, win 41449, options [nop,nop,TS val 4211382 ecr 3724352673], =
length 0
01:03:59.521700 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 260640:262088, ack 1, win 46, options [nop,nop,TS val 3724352673 ecr=
 4211325], length 1448
01:03:59.521822 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 262088:263536, ack 1, win 46, options [nop,nop,TS val 3724352673 ecr=
 4211325], length 1448
01:03:59.521833 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 263536, win 41449, options [nop,nop,TS val 4211382 ecr 3724352673], =
length 0
01:03:59.521945 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 263536:264984, ack 1, win 46, options [nop,nop,TS val 3724352673 ecr=
 4211325], length 1448
01:03:59.522068 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 264984:266432, ack 1, win 46, options [nop,nop,TS val 3724352673 ecr=
 4211325], length 1448
01:03:59.522079 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 266432, win 41449, options [nop,nop,TS val 4211382 ecr 3724352673], =
length 0
01:03:59.522191 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 266432:267880, ack 1, win 46, options [nop,nop,TS val 3724352673 ecr=
 4211326], length 1448
01:03:59.522315 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 267880:269328, ack 1, win 46, options [nop,nop,TS val 3724352673 ecr=
 4211326], length 1448
01:03:59.522325 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 269328, win 41449, options [nop,nop,TS val 4211383 ecr 3724352673], =
length 0
01:03:59.522437 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 269328:270776, ack 1, win 46, options [nop,nop,TS val 3724352673 ecr=
 4211326], length 1448
01:03:59.522560 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 270776:272224, ack 1, win 46, options [nop,nop,TS val 3724352673 ecr=
 4211326], length 1448
01:03:59.522571 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 272224, win 41449, options [nop,nop,TS val 4211383 ecr 3724352673], =
length 0
01:03:59.522684 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 272224:273672, ack 1, win 46, options [nop,nop,TS val 3724352673 ecr=
 4211326], length 1448
01:03:59.522807 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 273672:275120, ack 1, win 46, options [nop,nop,TS val 3724352673 ecr=
 4211326], length 1448
01:03:59.522818 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 275120, win 41449, options [nop,nop,TS val 4211383 ecr 3724352673], =
length 0
01:03:59.522930 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 275120:276568, ack 1, win 46, options [nop,nop,TS val 3724352673 ecr=
 4211327], length 1448
01:03:59.523053 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 276568:278016, ack 1, win 46, options [nop,nop,TS val 3724352673 ecr=
 4211327], length 1448
01:03:59.523064 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 278016, win 41449, options [nop,nop,TS val 4211383 ecr 3724352673], =
length 0
01:03:59.523176 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 278016:279464, ack 1, win 46, options [nop,nop,TS val 3724352673 ecr=
 4211327], length 1448
01:03:59.523300 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 279464:280912, ack 1, win 46, options [nop,nop,TS val 3724352673 ecr=
 4211327], length 1448
01:03:59.523311 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 280912, win 41449, options [nop,nop,TS val 4211384 ecr 3724352673], =
length 0
01:03:59.523422 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 280912:282360, ack 1, win 46, options [nop,nop,TS val 3724352674 ecr=
 4211327], length 1448
01:03:59.523545 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 282360:283808, ack 1, win 46, options [nop,nop,TS val 3724352674 ecr=
 4211327], length 1448
01:03:59.523555 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 283808, win 41449, options [nop,nop,TS val 4211384 ecr 3724352674], =
length 0
01:03:59.523667 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 283808:285256, ack 1, win 46, options [nop,nop,TS val 3724352674 ecr=
 4211327], length 1448
01:03:59.523791 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 285256:286704, ack 1, win 46, options [nop,nop,TS val 3724352674 ecr=
 4211327], length 1448
01:03:59.523802 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 286704, win 41449, options [nop,nop,TS val 4211384 ecr 3724352674], =
length 0
01:03:59.523915 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 286704:288152, ack 1, win 46, options [nop,nop,TS val 3724352674 ecr=
 4211328], length 1448
01:03:59.524038 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.], s=
eq 288152:289600, ack 1, win 46, options [nop,nop,TS val 3724352674 ecr=
 4211328], length 1448
01:03:59.524049 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.], a=
ck 289600, win 41449, options [nop,nop,TS val 4211384 ecr 3724352674], =
length 0
300 packets captured
326 packets received by filter
0 packets dropped by kernel

--=20
Alexey Kurov <nucleo@fedoraproject.org>
