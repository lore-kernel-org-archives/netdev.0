From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH] tcp: Expose the initial RTO via a new sysctl.
Date: Wed, 18 May 2011 22:20:25 +0200
Message-ID: <20110518202025.GC4175@nuttenaction>
References: <1305715384-81716-1-git-send-email-tsunanet@gmail.com>
 <20110518.152653.1486764697527722925.davem@davemloft.net>
 <BANLkTik-6wh8=jb6oMEpJvYC8+KTGGsMsw@mail.gmail.com>
 <20110518.155200.801089483916944725.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tsunanet@gmail.com, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110518.155200.801089483916944725.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* David Miller | 2011-05-18 15:52:00 [-0400]:

>I've already changed the initial TCP congestion window in Linux to 10
>without some stupid draft being fully accepted.
>
>I'll just as easily accept right now a patch right now which lowers
>the initial RTO to 1 second and adds the 3 second RTO fallback.

I like the idea to make the initial RTO a knob because we in a isolated MANET
environment have a RTT larger then 1 second. Especially the link layer setup
procedure over several hops demand some time-costly setup time. After that the
RTT is <1 second. The current algorithm works great for us. So this RTO change
will be counterproductive: it will always trigger a needless timeout.

The main problem for us is that Google at all pushing their view of Internet
with a lot of pressure. The same is true for the IETF IW adjustments, which is
unsuitable for networks which operates at a bandwidth characteristic some
years ago. The _former_ conservative principle "TCP over everything" is
forgotten.

Hagen
