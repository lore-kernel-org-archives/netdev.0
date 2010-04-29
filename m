From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: speedup udp receive path
Date: Thu, 29 Apr 2010 20:12:27 +0800
Message-ID: <u2l412e6f7f1004290512x7fcdb5c3w591c6446d676502@mail.gmail.com>
References: <1272010378-2955-1-git-send-email-xiaosuo@gmail.com>
	<20100427.150817.84390202.davem@davemloft.net> <1272406693.2343.26.camel@edumazet-laptop>
	<1272454432.14068.4.camel@bigi> <1272458001.2267.0.camel@edumazet-laptop>
	<1272458174.14068.16.camel@bigi> <1272463605.2267.70.camel@edumazet-laptop>
	<1272498293.4258.121.camel@bigi> <1272514176.2201.85.camel@edumazet-laptop>
	<1272540952.4258.161.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, therbert@google.com,
	shemminger@vyatta.com, netdev@vger.kernel.org,
	Eilon Greenstein <eilong@broadcom.com>,
	Brian Bloniarz <bmb@athenacr.com>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:60087 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758753Ab0D3Rab convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 13:30:31 -0400
Received: by pwj9 with SMTP id 9so283408pwj.19
        for <netdev@vger.kernel.org>; Fri, 30 Apr 2010 10:30:30 -0700 (PDT)
In-Reply-To: <1272540952.4258.161.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 29, 2010 at 7:35 PM, jamal <hadi@cyberus.ca> wrote:
>
> Same here - even in my worst case scenario 88.5% of 750Kpps > 600Kpps=
=2E
> Attached is history results to make more sense of what i am saying:
> we have net-next kernels from apr14, apr23, apr23 with changlis chang=
e,
> apr28, apr28 with your change. What you'll see is non-rps (blue) gets
> better and rps (Orange) gets better slowly then by apr28 it is worse.

Did the number of IPIs increase in the apr28 test? The finial patch
with Eric's change may introduce more IPIs. And I am wondering why
23rdcl-non-rps is better than before. Maybe it is the side effect of
my patch: enlarge the netdev_max_backlog.


--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
