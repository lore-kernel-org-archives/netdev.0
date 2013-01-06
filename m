From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Major network performance regression in 3.7
Date: Sun, 06 Jan 2013 10:39:01 -0800
Message-ID: <1357497541.6919.519.camel@edumazet-glaptop>
References: <1357437086.1678.5135.camel@edumazet-glaptop>
	 <1357438591.1678.5205.camel@edumazet-glaptop>
	 <20130106025256.GY16031@1wt.eu>
	 <1357457724.1678.5941.camel@edumazet-glaptop>
	 <20130106092435.GZ16031@1wt.eu> <1357484342.6919.61.camel@edumazet-glaptop>
	 <20130106155123.GB16031@1wt.eu>
	 <1357490393.6919.267.camel@edumazet-glaptop>
	 <20130106164416.GF16031@1wt.eu>
	 <1357492255.6919.336.camel@edumazet-glaptop>
	 <20130106173543.GB22432@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130106173543.GB22432@1wt.eu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2013-01-06 at 18:35 +0100, Willy Tarreau wrote:

> Unfortunately it does not work any better, which means to me
> that we don't leave via this code path. I tried other tricks
> which failed too. I need to understand this part better before
> randomly fiddling with it.
> 

OK, now I have your test program, I can work on a fix, dont worry ;)

The MSG_SENDPAGE_NOTLAST logic needs to be tweaked.
