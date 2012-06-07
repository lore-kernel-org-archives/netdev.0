From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Difficulties to get 1Gbps on be2net ethernet card
Date: Thu, 07 Jun 2012 14:31:29 +0200
Message-ID: <1339072289.3494.3.camel@edumazet-glaptop>
References: <CAL8zT=hHAc5-wGMKgumV=K9jG6tDxzej9Dffe9UYQ24gdWQRtw@mail.gmail.com>
	 <CAL8zT=jKhRjVCdYRCerMzimxPAhP5Gi+JBBfuKjG-rfg-LMoVw@mail.gmail.com>
	 <1338360536.2760.85.camel@edumazet-glaptop>
	 <CAL8zT=h2hoTWDMpTe8P-xfm-USXD6spx8fFVmm1UXyOfuuqhZw@mail.gmail.com>
	 <1338361587.2760.94.camel@edumazet-glaptop>
	 <CAL8zT=jHWhDdv-DyXL8XnL8qRc7o-jZfA7ADU-qt54hB5aLyCw@mail.gmail.com>
	 <CAL8zT=gJT1Frn_44SU0CrpZjPxwC_VuHFE4k9jvOGNmFomzhHA@mail.gmail.com>
	 <3367B80B08154D42A3B2BC708B5D41F647C678B73F@EXMAIL.ad.emulex.com>
	 <CAL8zT=iP+5o11am67ZBVOd=QrOfcjFWDydiuM9RrrAKe_k7LZw@mail.gmail.com>
	 <CAL8zT=ggT7Y2on6qmsp3u9CLOCwd6nOr3VjQfEsGZzA+O6us0A@mail.gmail.com>
	 <1338980484.2760.4219.camel@edumazet-glaptop>
	 <CAL8zT=hHDPnvRFcQ0w+D=AP+QK6ic4X=tva6Yw_XGwuTbAYjhQ@mail.gmail.com>
	 <CAL8zT=jGHo82mo-s8Tfs9LWzfu2GkrS4eZJoeOpHhpXHMr6csg@mail.gmail.com>
	 <CAL8zT=jY9YfdkBjk5VhwaSbzghCVUMXZZh+QAgc15LBBztczog@mail.gmail.com>
	 <CAL8zT=g67JLZZjLF81+wxe9pmuPZ4EdpY1fHJMQNgcy9R6oBzg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sathya.Perla@emulex.com, netdev@vger.kernel.org
To: Jean-Michel Hautbois <jhautbois@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:40561 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751800Ab2FGMbe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2012 08:31:34 -0400
Received: by eaak11 with SMTP id k11so204793eaa.19
        for <netdev@vger.kernel.org>; Thu, 07 Jun 2012 05:31:33 -0700 (PDT)
In-Reply-To: <CAL8zT=g67JLZZjLF81+wxe9pmuPZ4EdpY1fHJMQNgcy9R6oBzg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-06-07 at 14:27 +0200, Jean-Michel Hautbois wrote:

> I made some tests, and I didn't mention it : I am using the bonding
> driver over my ethernet drivers (be2net/mlx4 etc.).
> When I am using bonding, I need a big txqeuelen in order to send 2.4Gbps.
> When I disable bonding, and use directly the NIC then I don't see any
> drops in qdisc and it works well.
> So, I think there is something between 2.6.26 and 3.0 in the bonding
> driver which causes this issue.
> 

What your bond configuration looks like ?

cat /proc/net/bonding/bond0
ifconfig -a
tc -s -d qdisc
