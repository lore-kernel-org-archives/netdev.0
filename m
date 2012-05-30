From: Jean-Michel Hautbois <jhautbois@gmail.com>
Subject: Re: Difficulties to get 1Gbps on be2net ethernet card
Date: Wed, 30 May 2012 08:51:53 +0200
Message-ID: <CAL8zT=h2hoTWDMpTe8P-xfm-USXD6spx8fFVmm1UXyOfuuqhZw@mail.gmail.com>
References: <CAL8zT=hHAc5-wGMKgumV=K9jG6tDxzej9Dffe9UYQ24gdWQRtw@mail.gmail.com>
 <CAL8zT=jKhRjVCdYRCerMzimxPAhP5Gi+JBBfuKjG-rfg-LMoVw@mail.gmail.com> <1338360536.2760.85.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:37241 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751724Ab2E3GwO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2012 02:52:14 -0400
Received: by wibhn6 with SMTP id hn6so3516467wib.1
        for <netdev@vger.kernel.org>; Tue, 29 May 2012 23:52:13 -0700 (PDT)
In-Reply-To: <1338360536.2760.85.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/5/30 Eric Dumazet <eric.dumazet@gmail.com>:
> On Wed, 2012-05-30 at 08:28 +0200, Jean-Michel Hautbois wrote:
>
>> If this can help, setting tx queue length to 5000 seems to make the
>> problem disappear.
>
> Then you should have drops at Qdisc layer (before your change to 5000)
>
> tc -s -d qdisc
>
>> I didn't specified it : MTU is 4096, UDP packets are 4000 bytes.
>

Yes :
qdisc mq 0: dev eth1 root
 Sent 5710049154383 bytes 1413544639 pkt (dropped 73078, overlimits 0
requeues 281540)
 backlog 0b 0p requeues 281540

Why ? With a 2.6.26 kernel it works well with a tx queue length of 1000.
