From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] inet: fix a UFO regression
Date: Thu, 07 Nov 2013 18:08:35 -0800
Message-ID: <1383876515.9412.137.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAMEtUuzswOVA6UkPRjS-O=gOe9BLLJ5qaAG_eAd_fTqDJo8ofA@mail.gmail.com>
	 <1382674000.7572.75.camel@edumazet-glaptop.roam.corp.google.com>
	 <1382692140.7572.79.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131025.181809.348808013109842304.davem@davemloft.net>
	 <CAMEtUuxwi05oX0TqNdMbjy04MT=ZLemLXJQTTcAMrnWuhXLKdQ@mail.gmail.com>
	 <1382923096.13037.10.camel@edumazet-glaptop.roam.corp.google.com>
	 <1383863586.9412.101.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAMEtUuwqmUhTgeKyodGKmOxhxe23=umnfc7nouhdVrqVNnk6zQ@mail.gmail.com>
	 <1383871465.9412.118.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAMEtUuynjTj_eteupaSx1hbZs4OyVtc=fDZAwAFSL24qK8tFLA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:48944 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756434Ab3KHCIi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 21:08:38 -0500
Received: by mail-pd0-f172.google.com with SMTP id w10so1457195pde.3
        for <netdev@vger.kernel.org>; Thu, 07 Nov 2013 18:08:38 -0800 (PST)
In-Reply-To: <CAMEtUuynjTj_eteupaSx1hbZs4OyVtc=fDZAwAFSL24qK8tFLA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-11-07 at 17:39 -0800, Alexei Starovoitov wrote:

> as we discussed this will break vxlan :)
> Please move udpfrag assignment before line:
>                 segs = ops->callbacks.gso_segment(skb, features);
> since skb_udp_tunnel_segment() does skb->encapsulation = 0
> then both ufo and vxlan should be fine

Oh that's right, thanks again, I'll send a V2
