From: Jean-Michel Hautbois <jhautbois@gmail.com>
Subject: Re: TCP communication for raw image transmission
Date: Thu, 5 Jan 2012 09:50:54 +0100
Message-ID: <CAL8zT=gzRX7Xgc0_8Qfbe0pchrC9XV+tB7_+_ZJRxguneAO11g@mail.gmail.com>
References: <CAL8zT=iSiKZfENdtng9gDtuRSuFNn4WZ69uuGapLVVEduFRVyQ@mail.gmail.com>
 <1325519943.2375.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <CAL8zT=giNe46FYQYxPkbshVfyG-DvCTKS0RLdiN8Kz+e-x-JFw@mail.gmail.com>
 <1325521745.18116.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <CAL8zT=gbCmtNpw1Lot0P7zB+b_Kw911jhxsXCzO3JOBmMLRcFg@mail.gmail.com>
 <1325523137.18116.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <1325523178.18116.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <CAL8zT=gA2pd8wJtBRRLSH_MKXOj3_FzfcXg7v705+8w-xdByLg@mail.gmail.com>
 <1325526085.18116.15.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <CAL8zT=jKGYPe+bi44m0ADWzr+h0Hx59oGUYZoYsuu5syQQ-N5g@mail.gmail.com>
 <CAL8zT=h=mDNiDRVDo=jjcCjkyRGZ79iQiQLT3ZVRLb2PuC2ugg@mail.gmail.com>
 <CAL8zT=htsVAJotATQ5Lqidea5dEqCkZOgTT6t4-fFjjDzcVviw@mail.gmail.com> <1325577977.2549.12.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:49815 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751347Ab2AEIvQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2012 03:51:16 -0500
Received: by wibhm6 with SMTP id hm6so175823wib.19
        for <netdev@vger.kernel.org>; Thu, 05 Jan 2012 00:51:15 -0800 (PST)
In-Reply-To: <1325577977.2549.12.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/1/3 Eric Dumazet <eric.dumazet@gmail.com>:
> Le mardi 03 janvier 2012 =C3=A0 08:36 +0100, Jean-Michel Hautbois a =C3=
=A9crit :
>
>> After looking to the results, I can't see really bad values or
>> anything which would explain such a behaviour...
>
> no tcp problems, so your board seems to be slow
>
>> Maybe is there some limits in the driver ? My board is a leopardboar=
d (dm368).
>> Any idea ?
>
> Just to have any idea of the inter frame timings, could you post the
> ~200 first frames taken on x86 ?
>
> tcpdump -p -n -s 0 -i eth0 host arm_ip -c 200

Here it is :
09:49:11.163207 IP 192.168.0.2.40234 > 192.168.0.1.12865: Flags [S],
seq 2206455606, win 5840, options [mss 1460,sackOK,TS val 4294951315
ecr 0,nop,wscale 1], length 0
09:49:11.163232 IP 192.168.0.1.12865 > 192.168.0.2.40234: Flags [S.],
seq 411452088, ack 2206455607, win 14480, options [mss 1460,sackOK,TS
val 156359 ecr 4294951315,nop,wscale 6], length 0
09:49:11.163827 IP 192.168.0.2.40234 > 192.168.0.1.12865: Flags [.],
ack 1, win 2920, options [nop,nop,TS val 4294951315 ecr 156359],
length 0
09:49:11.164443 IP 192.168.0.2.40234 > 192.168.0.1.12865: Flags [P.],
seq 1:257, ack 1, win 2920, options [nop,nop,TS val 4294951315 ecr
156359], length 256
09:49:11.164466 IP 192.168.0.1.12865 > 192.168.0.2.40234: Flags [.],
ack 257, win 243, options [nop,nop,TS val 156359 ecr 4294951315],
length 0
09:49:11.164494 IP 192.168.0.1.12865 > 192.168.0.2.40234: Flags [P.],
seq 1:257, ack 257, win 243, options [nop,nop,TS val 156359 ecr
4294951315], length 256
09:49:11.165126 IP 192.168.0.2.40234 > 192.168.0.1.12865: Flags [.],
ack 257, win 3456, options [nop,nop,TS val 4294951315 ecr 156359],
length 0
09:49:11.179437 IP 192.168.0.2.40234 > 192.168.0.1.12865: Flags [P.],
seq 257:513, ack 257, win 3456, options [nop,nop,TS val 4294951317 ecr
156359], length 256
09:49:11.218998 IP 192.168.0.1.12865 > 192.168.0.2.40234: Flags [.],
ack 513, win 260, options [nop,nop,TS val 156376 ecr 4294951317],
length 0
09:49:11.227409 IP 192.168.0.1.12865 > 192.168.0.2.40234: Flags [P.],
seq 257:513, ack 513, win 260, options [nop,nop,TS val 156378 ecr
4294951317], length 256
09:49:11.228895 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [S],
seq 2200327184, win 5840, options [mss 1460,sackOK,TS val 4294951322
ecr 0,nop,wscale 1], length 0
09:49:11.228911 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [S.],
seq 933609285, ack 2200327185, win 14480, options [mss 1460,sackOK,TS
val 156378 ecr 4294951322,nop,wscale 6], length 0
09:49:11.229513 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
ack 1, win 2920, options [nop,nop,TS val 4294951322 ecr 156378],
length 0
09:49:11.229915 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 1:1449, ack 1, win 2920, options [nop,nop,TS val 4294951322 ecr
156378], length 1448
09:49:11.229956 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 1449, win 272, options [nop,nop,TS val 156379 ecr 4294951322],
length 0
09:49:11.230168 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 1449:4345, ack 1, win 2920, options [nop,nop,TS val 4294951322 ecr
156378], length 2896
09:49:11.230203 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 4345, win 317, options [nop,nop,TS val 156379 ecr 4294951322],
length 0
09:49:11.230763 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 4345:5793, ack 1, win 2920, options [nop,nop,TS val 4294951322 ecr
156379], length 1448
09:49:11.230793 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 5793, win 362, options [nop,nop,TS val 156379 ecr 4294951322],
length 0
09:49:11.231015 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [P.],
seq 5793:8689, ack 1, win 2920, options [nop,nop,TS val 4294951322 ecr
156379], length 2896
09:49:11.231045 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 8689, win 408, options [nop,nop,TS val 156379 ecr 4294951322],
length 0
09:49:11.231265 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 8689:11585, ack 1, win 2920, options [nop,nop,TS val 4294951322
ecr 156379], length 2896
09:49:11.231292 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 11585, win 453, options [nop,nop,TS val 156379 ecr 4294951322],
length 0
09:49:11.231514 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [P.],
seq 11585:14481, ack 1, win 2920, options [nop,nop,TS val 4294951322
ecr 156379], length 2896
09:49:11.231554 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 14481, win 498, options [nop,nop,TS val 156379 ecr 4294951322],
length 0
09:49:11.232060 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [P.],
seq 14481:16385, ack 1, win 2920, options [nop,nop,TS val 4294951322
ecr 156379], length 1904
09:49:11.232089 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 16385, win 543, options [nop,nop,TS val 156379 ecr 4294951322],
length 0
09:49:11.232586 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 16385:19281, ack 1, win 2920, options [nop,nop,TS val 4294951322
ecr 156379], length 2896
09:49:11.232617 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 19281, win 589, options [nop,nop,TS val 156380 ecr 4294951322],
length 0
09:49:11.232838 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 19281:22177, ack 1, win 2920, options [nop,nop,TS val 4294951322
ecr 156379], length 2896
09:49:11.232866 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 22177, win 634, options [nop,nop,TS val 156380 ecr 4294951322],
length 0
09:49:11.233113 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 22177:23625, ack 1, win 2920, options [nop,nop,TS val 4294951322
ecr 156379], length 1448
09:49:11.233140 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 23625, win 679, options [nop,nop,TS val 156380 ecr 4294951322],
length 0
09:49:11.233362 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 23625:25073, ack 1, win 2920, options [nop,nop,TS val 4294951322
ecr 156379], length 1448
09:49:11.233388 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 25073, win 724, options [nop,nop,TS val 156380 ecr 4294951322],
length 0
09:49:11.233612 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [P.],
seq 25073:27969, ack 1, win 2920, options [nop,nop,TS val 4294951322
ecr 156379], length 2896
09:49:11.233641 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 27969, win 770, options [nop,nop,TS val 156380 ecr 4294951322],
length 0
09:49:11.234202 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 27969:29417, ack 1, win 2920, options [nop,nop,TS val 4294951322
ecr 156380], length 1448
09:49:11.234225 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 29417, win 815, options [nop,nop,TS val 156380 ecr 4294951322],
length 0
09:49:11.234455 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [P.],
seq 29417:32769, ack 1, win 2920, options [nop,nop,TS val 4294951322
ecr 156380], length 3352
09:49:11.234483 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 32769, win 860, options [nop,nop,TS val 156380 ecr 4294951322],
length 0
09:49:11.235042 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 32769:34217, ack 1, win 2920, options [nop,nop,TS val 4294951322
ecr 156380], length 1448
09:49:11.235067 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 34217, win 905, options [nop,nop,TS val 156380 ecr 4294951322],
length 0
09:49:11.235293 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 34217:37113, ack 1, win 2920, options [nop,nop,TS val 4294951322
ecr 156380], length 2896
09:49:11.235318 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 37113, win 951, options [nop,nop,TS val 156380 ecr 4294951322],
length 0
09:49:11.235551 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 37113:40009, ack 1, win 2920, options [nop,nop,TS val 4294951322
ecr 156380], length 2896
09:49:11.235577 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 40009, win 996, options [nop,nop,TS val 156380 ecr 4294951322],
length 0
09:49:11.235791 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 40009:41457, ack 1, win 2920, options [nop,nop,TS val 4294951322
ecr 156380], length 1448
09:49:11.235818 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 41457, win 1002, options [nop,nop,TS val 156381 ecr 4294951322],
length 0
09:49:11.236041 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 41457:42905, ack 1, win 2920, options [nop,nop,TS val 4294951322
ecr 156380], length 1448
09:49:11.236067 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 42905, win 1002, options [nop,nop,TS val 156381 ecr 4294951322],
length 0
09:49:11.236312 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 42905:44353, ack 1, win 2920, options [nop,nop,TS val 4294951322
ecr 156380], length 1448
09:49:11.236336 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 44353, win 1002, options [nop,nop,TS val 156381 ecr 4294951322],
length 0
09:49:11.236562 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 44353:47249, ack 1, win 2920, options [nop,nop,TS val 4294951322
ecr 156380], length 2896
09:49:11.236588 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 47249, win 1002, options [nop,nop,TS val 156381 ecr 4294951322],
length 0
09:49:11.236812 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [P.],
seq 47249:49153, ack 1, win 2920, options [nop,nop,TS val 4294951322
ecr 156380], length 1904
09:49:11.236837 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 49153, win 1002, options [nop,nop,TS val 156381 ecr 4294951322],
length 0
09:49:11.237508 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 49153:50601, ack 1, win 2920, options [nop,nop,TS val 4294951322
ecr 156381], length 1448
09:49:11.237761 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 50601:53497, ack 1, win 2920, options [nop,nop,TS val 4294951323
ecr 156381], length 2896
09:49:11.237796 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 53497, win 1002, options [nop,nop,TS val 156381 ecr 4294951322],
length 0
09:49:11.238012 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 53497:56393, ack 1, win 2920, options [nop,nop,TS val 4294951323
ecr 156381], length 2896
09:49:11.238053 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 56393, win 1002, options [nop,nop,TS val 156381 ecr 4294951323],
length 0
09:49:11.238262 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 56393:59289, ack 1, win 2920, options [nop,nop,TS val 4294951323
ecr 156381], length 2896
09:49:11.238299 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 59289, win 1002, options [nop,nop,TS val 156381 ecr 4294951323],
length 0
09:49:11.238509 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 59289:60737, ack 1, win 2920, options [nop,nop,TS val 4294951323
ecr 156381], length 1448
09:49:11.238759 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 60737:62185, ack 1, win 2920, options [nop,nop,TS val 4294951323
ecr 156381], length 1448
09:49:11.238798 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 62185, win 1002, options [nop,nop,TS val 156381 ecr 4294951323],
length 0
09:49:11.239010 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [P.],
seq 62185:65537, ack 1, win 2920, options [nop,nop,TS val 4294951323
ecr 156381], length 3352
09:49:11.239053 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 65537, win 1002, options [nop,nop,TS val 156382 ecr 4294951323],
length 0
09:49:11.239757 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 65537:66985, ack 1, win 2920, options [nop,nop,TS val 4294951323
ecr 156382], length 1448
09:49:11.240007 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 66985:69881, ack 1, win 2920, options [nop,nop,TS val 4294951323
ecr 156382], length 2896
09:49:11.240040 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 69881, win 1002, options [nop,nop,TS val 156382 ecr 4294951323],
length 0
09:49:11.240257 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 69881:72777, ack 1, win 2920, options [nop,nop,TS val 4294951323
ecr 156382], length 2896
09:49:11.240286 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 72777, win 1002, options [nop,nop,TS val 156382 ecr 4294951323],
length 0
09:49:11.240507 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 72777:75673, ack 1, win 2920, options [nop,nop,TS val 4294951323
ecr 156382], length 2896
09:49:11.240534 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 75673, win 1002, options [nop,nop,TS val 156382 ecr 4294951323],
length 0
09:49:11.240756 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 75673:78569, ack 1, win 2920, options [nop,nop,TS val 4294951323
ecr 156382], length 2896
09:49:11.240783 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 78569, win 1002, options [nop,nop,TS val 156382 ecr 4294951323],
length 0
09:49:11.241027 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 78569:80017, ack 1, win 2920, options [nop,nop,TS val 4294951323
ecr 156382], length 1448
09:49:11.241277 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [P.],
seq 80017:81921, ack 1, win 2920, options [nop,nop,TS val 4294951323
ecr 156382], length 1904
09:49:11.241306 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 81921, win 1002, options [nop,nop,TS val 156382 ecr 4294951323],
length 0
09:49:11.241801 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 81921:83369, ack 1, win 2920, options [nop,nop,TS val 4294951323
ecr 156382], length 1448
09:49:11.242053 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 83369:86265, ack 1, win 2920, options [nop,nop,TS val 4294951323
ecr 156382], length 2896
09:49:11.242081 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 86265, win 1002, options [nop,nop,TS val 156382 ecr 4294951323],
length 0
09:49:11.242303 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 86265:89161, ack 1, win 2920, options [nop,nop,TS val 4294951323
ecr 156382], length 2896
09:49:11.242340 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 89161, win 1002, options [nop,nop,TS val 156383 ecr 4294951323],
length 0
09:49:11.242553 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 89161:92057, ack 1, win 2920, options [nop,nop,TS val 4294951323
ecr 156382], length 2896
09:49:11.242578 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 92057, win 1002, options [nop,nop,TS val 156383 ecr 4294951323],
length 0
09:49:11.242802 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 92057:94953, ack 1, win 2920, options [nop,nop,TS val 4294951323
ecr 156382], length 2896
09:49:11.242828 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 94953, win 1002, options [nop,nop,TS val 156383 ecr 4294951323],
length 0
09:49:11.243055 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 94953:96401, ack 1, win 2920, options [nop,nop,TS val 4294951323
ecr 156382], length 1448
09:49:11.243385 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [P.],
seq 96401:98305, ack 1, win 2920, options [nop,nop,TS val 4294951323
ecr 156382], length 1904
09:49:11.243409 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 98305, win 1002, options [nop,nop,TS val 156383 ecr 4294951323],
length 0
09:49:11.243963 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 98305:99753, ack 1, win 2920, options [nop,nop,TS val 4294951323
ecr 156383], length 1448
09:49:11.244215 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 99753:102649, ack 1, win 2920, options [nop,nop,TS val 4294951323
ecr 156383], length 2896
09:49:11.244238 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 102649, win 1002, options [nop,nop,TS val 156383 ecr 4294951323],
length 0
09:49:11.244465 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 102649:105545, ack 1, win 2920, options [nop,nop,TS val 4294951323
ecr 156383], length 2896
09:49:11.244491 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 105545, win 1002, options [nop,nop,TS val 156383 ecr 4294951323],
length 0
09:49:11.244715 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 105545:108441, ack 1, win 2920, options [nop,nop,TS val 4294951323
ecr 156383], length 2896
09:49:11.244740 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 108441, win 1002, options [nop,nop,TS val 156383 ecr 4294951323],
length 0
09:49:11.244964 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 108441:111337, ack 1, win 2920, options [nop,nop,TS val 4294951323
ecr 156383], length 2896
09:49:11.244990 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 111337, win 1002, options [nop,nop,TS val 156383 ecr 4294951323],
length 0
09:49:11.245236 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 111337:112785, ack 1, win 2920, options [nop,nop,TS val 4294951323
ecr 156383], length 1448
09:49:11.245486 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [P.],
seq 112785:114689, ack 1, win 2920, options [nop,nop,TS val 4294951323
ecr 156383], length 1904
09:49:11.245510 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 114689, win 1002, options [nop,nop,TS val 156383 ecr 4294951323],
length 0
09:49:11.246059 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 114689:116137, ack 1, win 2920, options [nop,nop,TS val 4294951323
ecr 156383], length 1448
09:49:11.246310 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 116137:119033, ack 1, win 2920, options [nop,nop,TS val 4294951323
ecr 156383], length 2896
09:49:11.246334 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 119033, win 1002, options [nop,nop,TS val 156384 ecr 4294951323],
length 0
09:49:11.246560 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 119033:121929, ack 1, win 2920, options [nop,nop,TS val 4294951323
ecr 156383], length 2896
09:49:11.246586 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 121929, win 1002, options [nop,nop,TS val 156384 ecr 4294951323],
length 0
09:49:11.246810 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 121929:124825, ack 1, win 2920, options [nop,nop,TS val 4294951323
ecr 156383], length 2896
09:49:11.246835 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 124825, win 1002, options [nop,nop,TS val 156384 ecr 4294951323],
length 0
09:49:11.247059 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 124825:126273, ack 1, win 2920, options [nop,nop,TS val 4294951323
ecr 156383], length 1448
09:49:11.247307 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 126273:127721, ack 1, win 2920, options [nop,nop,TS val 4294951323
ecr 156383], length 1448
09:49:11.247330 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 127721, win 1002, options [nop,nop,TS val 156384 ecr 4294951323],
length 0
09:49:11.247572 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 127721:129169, ack 1, win 2920, options [nop,nop,TS val 4294951324
ecr 156383], length 1448
09:49:11.247821 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [P.],
seq 129169:131073, ack 1, win 2920, options [nop,nop,TS val 4294951324
ecr 156383], length 1904
09:49:11.247844 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 131073, win 1002, options [nop,nop,TS val 156384 ecr 4294951324],
length 0
09:49:11.248434 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 131073:132521, ack 1, win 2920, options [nop,nop,TS val 4294951324
ecr 156384], length 1448
09:49:11.248685 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 132521:135417, ack 1, win 2920, options [nop,nop,TS val 4294951324
ecr 156384], length 2896
09:49:11.248699 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 135417, win 1002, options [nop,nop,TS val 156384 ecr 4294951324],
length 0
09:49:11.248935 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 135417:138313, ack 1, win 2920, options [nop,nop,TS val 4294951324
ecr 156384], length 2896
09:49:11.248964 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 138313, win 1002, options [nop,nop,TS val 156384 ecr 4294951324],
length 0
09:49:11.249184 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 138313:141209, ack 1, win 2920, options [nop,nop,TS val 4294951324
ecr 156384], length 2896
09:49:11.249212 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 141209, win 1002, options [nop,nop,TS val 156385 ecr 4294951324],
length 0
09:49:11.249433 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 141209:142657, ack 1, win 2920, options [nop,nop,TS val 4294951324
ecr 156384], length 1448
09:49:11.249683 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 142657:145553, ack 1, win 2920, options [nop,nop,TS val 4294951324
ecr 156384], length 2896
09:49:11.249707 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 145553, win 1002, options [nop,nop,TS val 156385 ecr 4294951324],
length 0
09:49:11.249933 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [P.],
seq 145553:147457, ack 1, win 2920, options [nop,nop,TS val 4294951324
ecr 156384], length 1904
09:49:11.249959 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 147457, win 1002, options [nop,nop,TS val 156385 ecr 4294951324],
length 0
09:49:11.250570 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 147457:148905, ack 1, win 2920, options [nop,nop,TS val 4294951324
ecr 156385], length 1448
09:49:11.250821 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 148905:151801, ack 1, win 2920, options [nop,nop,TS val 4294951324
ecr 156385], length 2896
09:49:11.250844 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 151801, win 1002, options [nop,nop,TS val 156385 ecr 4294951324],
length 0
09:49:11.251071 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 151801:154697, ack 1, win 2920, options [nop,nop,TS val 4294951324
ecr 156385], length 2896
09:49:11.251096 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 154697, win 1002, options [nop,nop,TS val 156385 ecr 4294951324],
length 0
09:49:11.251320 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 154697:157593, ack 1, win 2920, options [nop,nop,TS val 4294951324
ecr 156385], length 2896
09:49:11.251345 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 157593, win 1002, options [nop,nop,TS val 156385 ecr 4294951324],
length 0
09:49:11.251570 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 157593:160489, ack 1, win 2920, options [nop,nop,TS val 4294951324
ecr 156385], length 2896
09:49:11.251597 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 160489, win 1002, options [nop,nop,TS val 156385 ecr 4294951324],
length 0
09:49:11.251842 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 160489:161937, ack 1, win 2920, options [nop,nop,TS val 4294951324
ecr 156385], length 1448
09:49:11.252126 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [P.],
seq 161937:163841, ack 1, win 2920, options [nop,nop,TS val 4294951324
ecr 156385], length 1904
09:49:11.252151 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 163841, win 1002, options [nop,nop,TS val 156385 ecr 4294951324],
length 0
09:49:11.252724 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 163841:165289, ack 1, win 2920, options [nop,nop,TS val 4294951324
ecr 156385], length 1448
09:49:11.252975 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 165289:168185, ack 1, win 2920, options [nop,nop,TS val 4294951324
ecr 156385], length 2896
09:49:11.252983 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 168185, win 1002, options [nop,nop,TS val 156386 ecr 4294951324],
length 0
09:49:11.253225 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 168185:171081, ack 1, win 2920, options [nop,nop,TS val 4294951324
ecr 156385], length 2896
09:49:11.253232 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 171081, win 1002, options [nop,nop,TS val 156386 ecr 4294951324],
length 0
09:49:11.253477 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 171081:173977, ack 1, win 2920, options [nop,nop,TS val 4294951324
ecr 156385], length 2896
09:49:11.253489 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 173977, win 1002, options [nop,nop,TS val 156386 ecr 4294951324],
length 0
09:49:11.253726 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 173977:176873, ack 1, win 2920, options [nop,nop,TS val 4294951324
ecr 156385], length 2896
09:49:11.253738 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 176873, win 1002, options [nop,nop,TS val 156386 ecr 4294951324],
length 0
09:49:11.253984 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 176873:178321, ack 1, win 2920, options [nop,nop,TS val 4294951324
ecr 156385], length 1448
09:49:11.254233 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [P.],
seq 178321:180225, ack 1, win 2920, options [nop,nop,TS val 4294951324
ecr 156385], length 1904
09:49:11.254244 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 180225, win 1002, options [nop,nop,TS val 156386 ecr 4294951324],
length 0
09:49:11.254848 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 180225:181673, ack 1, win 2920, options [nop,nop,TS val 4294951324
ecr 156386], length 1448
09:49:11.255101 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 181673:184569, ack 1, win 2920, options [nop,nop,TS val 4294951324
ecr 156386], length 2896
09:49:11.255114 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 184569, win 1002, options [nop,nop,TS val 156386 ecr 4294951324],
length 0
09:49:11.255351 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 184569:187465, ack 1, win 2920, options [nop,nop,TS val 4294951324
ecr 156386], length 2896
09:49:11.255364 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 187465, win 1002, options [nop,nop,TS val 156386 ecr 4294951324],
length 0
09:49:11.255598 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 187465:190361, ack 1, win 2920, options [nop,nop,TS val 4294951324
ecr 156386], length 2896
09:49:11.255630 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 190361, win 1002, options [nop,nop,TS val 156386 ecr 4294951324],
length 0
09:49:11.255848 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 190361:191809, ack 1, win 2920, options [nop,nop,TS val 4294951324
ecr 156386], length 1448
09:49:11.256097 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 191809:194705, ack 1, win 2920, options [nop,nop,TS val 4294951324
ecr 156386], length 2896
09:49:11.256121 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 194705, win 1002, options [nop,nop,TS val 156387 ecr 4294951324],
length 0
09:49:11.256347 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [P.],
seq 194705:196609, ack 1, win 2920, options [nop,nop,TS val 4294951324
ecr 156386], length 1904
09:49:11.256374 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 196609, win 1002, options [nop,nop,TS val 156387 ecr 4294951324],
length 0
09:49:11.257052 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 196609:198057, ack 1, win 2920, options [nop,nop,TS val 4294951324
ecr 156387], length 1448
09:49:11.257302 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 198057:199505, ack 1, win 2920, options [nop,nop,TS val 4294951324
ecr 156387], length 1448
09:49:11.257325 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 199505, win 1047, options [nop,nop,TS val 156387 ecr 4294951324],
length 0
09:49:11.257554 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 199505:202401, ack 1, win 2920, options [nop,nop,TS val 4294951325
ecr 156387], length 2896
09:49:11.257581 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 202401, win 1070, options [nop,nop,TS val 156387 ecr 4294951325],
length 0
09:49:11.257827 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 202401:203849, ack 1, win 2920, options [nop,nop,TS val 4294951325
ecr 156387], length 1448
09:49:11.258078 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 203849:206745, ack 1, win 2920, options [nop,nop,TS val 4294951325
ecr 156387], length 2896
09:49:11.258101 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 206745, win 1070, options [nop,nop,TS val 156387 ecr 4294951325],
length 0
09:49:11.258329 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 206745:209641, ack 1, win 2920, options [nop,nop,TS val 4294951325
ecr 156387], length 2896
09:49:11.258356 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 209641, win 1070, options [nop,nop,TS val 156387 ecr 4294951325],
length 0
09:49:11.258598 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 209641:211089, ack 1, win 2920, options [nop,nop,TS val 4294951325
ecr 156387], length 1448
09:49:11.258849 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [P.],
seq 211089:212993, ack 1, win 2920, options [nop,nop,TS val 4294951325
ecr 156387], length 1904
09:49:11.258881 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 212993, win 1070, options [nop,nop,TS val 156387 ecr 4294951325],
length 0
09:49:11.259389 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 212993:214441, ack 1, win 2920, options [nop,nop,TS val 4294951325
ecr 156387], length 1448
09:49:11.259639 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 214441:217337, ack 1, win 2920, options [nop,nop,TS val 4294951325
ecr 156387], length 2896
09:49:11.259670 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 217337, win 1070, options [nop,nop,TS val 156388 ecr 4294951325],
length 0
09:49:11.259878 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 217337:220233, ack 1, win 2920, options [nop,nop,TS val 4294951325
ecr 156387], length 2896
09:49:11.259907 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 220233, win 1070, options [nop,nop,TS val 156388 ecr 4294951325],
length 0
09:49:11.260127 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 220233:223129, ack 1, win 2920, options [nop,nop,TS val 4294951325
ecr 156387], length 2896
09:49:11.260152 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 223129, win 1070, options [nop,nop,TS val 156388 ecr 4294951325],
length 0
09:49:11.260399 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 223129:224577, ack 1, win 2920, options [nop,nop,TS val 4294951325
ecr 156387], length 1448
09:49:11.260648 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 224577:226025, ack 1, win 2920, options [nop,nop,TS val 4294951325
ecr 156387], length 1448
09:49:11.260671 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 226025, win 1070, options [nop,nop,TS val 156388 ecr 4294951325],
length 0
09:49:11.260899 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [P.],
seq 226025:229377, ack 1, win 2920, options [nop,nop,TS val 4294951325
ecr 156387], length 3352
09:49:11.260926 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 229377, win 1070, options [nop,nop,TS val 156388 ecr 4294951325],
length 0
09:49:11.261622 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 229377:230825, ack 1, win 2920, options [nop,nop,TS val 4294951325
ecr 156388], length 1448
09:49:11.261873 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 230825:233721, ack 1, win 2920, options [nop,nop,TS val 4294951325
ecr 156388], length 2896
09:49:11.261896 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 233721, win 1070, options [nop,nop,TS val 156388 ecr 4294951325],
length 0
09:49:11.262123 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 233721:236617, ack 1, win 2920, options [nop,nop,TS val 4294951325
ecr 156388], length 2896
09:49:11.262149 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 236617, win 1070, options [nop,nop,TS val 156388 ecr 4294951325],
length 0
09:49:11.262373 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 236617:239513, ack 1, win 2920, options [nop,nop,TS val 4294951325
ecr 156388], length 2896
09:49:11.262398 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 239513, win 1070, options [nop,nop,TS val 156389 ecr 4294951325],
length 0
09:49:11.262622 IP 192.168.0.2.42474 > 192.168.0.1.51529: Flags [.],
seq 239513:242409, ack 1, win 2920, options [nop,nop,TS val 4294951325
ecr 156388], length 2896
09:49:11.262647 IP 192.168.0.1.51529 > 192.168.0.2.42474: Flags [.],
ack 242409, win 1070, options [nop,nop,TS val 156389 ecr 4294951325],
length 0

JM
