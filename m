From: Jean-Michel Hautbois <jhautbois@gmail.com>
Subject: Re: Difficulties to get 1Gbps on be2net ethernet card
Date: Fri, 8 Jun 2012 10:14:39 +0200
Message-ID: <CAL8zT=jPUEF62-V_0n9o3=n2Mo6y4M_kGgK+OwdXg0aLDazDgQ@mail.gmail.com>
References: <CAL8zT=hHAc5-wGMKgumV=K9jG6tDxzej9Dffe9UYQ24gdWQRtw@mail.gmail.com>
 <CAL8zT=jKhRjVCdYRCerMzimxPAhP5Gi+JBBfuKjG-rfg-LMoVw@mail.gmail.com>
 <1338360536.2760.85.camel@edumazet-glaptop> <CAL8zT=h2hoTWDMpTe8P-xfm-USXD6spx8fFVmm1UXyOfuuqhZw@mail.gmail.com>
 <1338361587.2760.94.camel@edumazet-glaptop> <CAL8zT=jHWhDdv-DyXL8XnL8qRc7o-jZfA7ADU-qt54hB5aLyCw@mail.gmail.com>
 <CAL8zT=gJT1Frn_44SU0CrpZjPxwC_VuHFE4k9jvOGNmFomzhHA@mail.gmail.com>
 <3367B80B08154D42A3B2BC708B5D41F647C678B73F@EXMAIL.ad.emulex.com>
 <CAL8zT=iP+5o11am67ZBVOd=QrOfcjFWDydiuM9RrrAKe_k7LZw@mail.gmail.com>
 <CAL8zT=ggT7Y2on6qmsp3u9CLOCwd6nOr3VjQfEsGZzA+O6us0A@mail.gmail.com>
 <1338980484.2760.4219.camel@edumazet-glaptop> <CAL8zT=hHDPnvRFcQ0w+D=AP+QK6ic4X=tva6Yw_XGwuTbAYjhQ@mail.gmail.com>
 <CAL8zT=jGHo82mo-s8Tfs9LWzfu2GkrS4eZJoeOpHhpXHMr6csg@mail.gmail.com>
 <CAL8zT=jY9YfdkBjk5VhwaSbzghCVUMXZZh+QAgc15LBBztczog@mail.gmail.com>
 <CAL8zT=g67JLZZjLF81+wxe9pmuPZ4EdpY1fHJMQNgcy9R6oBzg@mail.gmail.com>
 <1339072289.3494.3.camel@edumazet-glaptop> <CAL8zT=i2EkZLz3J5ib1tLnOuXt=Buf0sCwr7UbQWRE3B4oB+JQ@mail.gmail.com>
 <1339135709.6001.22.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sathya.Perla@emulex.com, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:35666 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757826Ab2FHIPB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jun 2012 04:15:01 -0400
Received: by bkcji2 with SMTP id ji2so1488223bkc.19
        for <netdev@vger.kernel.org>; Fri, 08 Jun 2012 01:14:59 -0700 (PDT)
In-Reply-To: <1339135709.6001.22.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/6/8 Eric Dumazet <eric.dumazet@gmail.com>:
> On Thu, 2012-06-07 at 14:54 +0200, Jean-Michel Hautbois wrote:
>
>> eth1 =C2=A0 =C2=A0 =C2=A0Link encap:Ethernet =C2=A0HWaddr 68:b5:99:b=
9:8d:d4
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 UP BROADCAST RUNNING SLAVE MULTIC=
AST =C2=A0MTU:4096 =C2=A0Metric:1
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 RX packets:0 errors:0 dropped:0 o=
verruns:0 frame:0
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 TX packets:15215387 errors:0 drop=
ped:0 overruns:0 carrier:0
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 collisions:0 txqueuelen:1000
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 RX bytes:0 (0.0 B) =C2=A0TX bytes=
:61476524359 (57.2 GiB)
>
>> qdisc mq 0: dev eth1 root
>> =C2=A0Sent 61476524359 bytes 15215387 pkt (dropped 45683472, overlim=
its 0
>> requeues 17480)
>
> OK, and "tc -s -d cl show dev eth1"
>
> (How many queues are really used)
>
>
>

tc -s -d cl show dev eth1
class mq :1 root
 Sent 9798071746 bytes 2425410 pkt (dropped 3442405, overlimits 0 reque=
ues 2747)
 backlog 0b 0p requeues 2747
class mq :2 root
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
class mq :3 root
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
class mq :4 root
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
class mq :5 root
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
class mq :6 root
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
class mq :7 root
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
class mq :8 root
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
