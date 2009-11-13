From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] ifb: add multi-queue support
Date: Fri, 13 Nov 2009 19:25:33 +0800
Message-ID: <412e6f7f0911130325r20e2fbbbg21e2e384de1f7c0f@mail.gmail.com>
References: <412e6f7f0911122216u6880e855g6a15dac29ad6a100@mail.gmail.com>
	 <20091113074508.GA6605@ff.dom.local>
	 <412e6f7f0911130054i7a508a6ah16368f11bdc7353d@mail.gmail.com>
	 <20091113091825.GA7449@ff.dom.local>
	 <412e6f7f0911130138td181935w36cab3119972753e@mail.gmail.com>
	 <20091113095731.GA7749@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f171.google.com ([209.85.222.171]:41551 "EHLO
	mail-pz0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753921AbZKMLZ2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 06:25:28 -0500
Received: by pzk1 with SMTP id 1so1229692pzk.33
        for <netdev@vger.kernel.org>; Fri, 13 Nov 2009 03:25:33 -0800 (PST)
In-Reply-To: <20091113095731.GA7749@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 13, 2009 at 5:57 PM, Jarek Poplawski <jarkao2@gmail.com> wr=
ote:
>
> I'm not against your solution at all. It only needs more proof...

I know. :)

> You seem to forget the main networking paths now are just softirq, an=
d
> it's probably for some reason. If kernel threads are good enough, it
> seems we should do more such changes.
>

I find there is still a softirqd kernel thread for each online CPU,
and these threads will be waked up if there are more SoftIRQs need to
be done after restarting the SoftIRQ processing many times, to keep
the whole system responsible. Did I miss sth.? And at the other side,
real time branch just wants to make all the activities based on kernel
threads, even ISR.


--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
