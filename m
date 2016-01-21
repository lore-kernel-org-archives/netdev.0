From: =?utf-8?B?Ss61YW4=?= Sacren <sakiwit@gmail.com>
Subject: Re: question about samsung/sxgbe/sxgbe_xpcs.c
Date: Wed, 20 Jan 2016 22:10:56 -0700
Message-ID: <20160121051056.GA4373@mail.gmail.com>
References: <alpine.DEB.2.10.1601191723250.2531@hadrien>
 <CAKocOOOFrEFLL0MWnn_bhBby8GeVH82A2wtaL9Tg9QTJC2Wprw@mail.gmail.com>
 <alpine.DEB.2.10.1601191918470.2531@hadrien>
 <20160119.143628.432983847877790677.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: julia.lawall@lip6.fr, shuahkhan@gmail.com, bh74.an@samsung.com,
	ks.giri@samsung.com, vipul.pandya@samsung.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	shuahkh@osg.samsung.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160119.143628.432983847877790677.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Tue, 19 Jan 2016 14:36:28 -0500
>
> From: Julia Lawall <julia.lawall@lip6.fr>
> Date: Tue, 19 Jan 2016 19:54:20 +0100 (CET)

[...]

> > I just wondered.  I was looking at dependencies between networking files.
> > This one stands out because nothing is dependenton it, even the files it
> > is compiled with, and it doesn't contain the usual functions,
> > register_netdev, etc.
> 
> Even with that explanation, this is a bogus situation.
> 
> There are no in-tree callers of this code.  It should be removed until there
> are in-tree users.
> 
> Nobody can figure out if the interface for this is done properly without seeing
> the call sites and how they work.  It is therefore impossible to review this
> code and judge it's design.
> 
> If someone doesn't send me a removal patch, I will remove this code myself.

I have the patch ready.

Do you want me to submit it now during the merge window or wait till
net-next opens up again?
