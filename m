From: Harry Wei <jiaweiwei.xiyou@gmail.com>
Subject: Re: [PATCH 1/2] netpoll: Remove unused EXPORT_SYMBOLs of
 netpoll_poll and netpoll_poll_dev
Date: Mon, 4 Jul 2011 17:27:38 +0800
Message-ID: <20110704092736.GA2932@gmail.com>
References: <cover.1309482314.git.joe@perches.com>
 <282ce7d68b97c4dbfb759c1c0752e6cbddfeeafc.1309482314.git.joe@perches.com>
 <20110704065320.GA2588@gmail.com>
 <1309765589.18925.42.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=gb2312
Cc: amwang@redhat.com, linux-kernel@vger.kernel.org,
	davem@davemloft.net, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1309765589.18925.42.camel@Joe-Laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 04, 2011 at 12:46:29AM -0700, Joe Perches wrote:
[...]
> > You have removed the function declaration in include/linux/netpoll.h.
> 
> Because it's unused by anything in the tree
> but netpoll.c
Hmmmm..., so sorry. I misunderstood your 'unused', which i thought
there was also no use in netpoll.c :-/
> 
> > And you changed the function like 
> > static void netpoll_poll_dev(...)
> > {
> > 	...
> > }
> > But i don't know its usage.
> 
> It's now a local function to netpoll.c
Yeah, it's true.
> 
> > The 'static' before this function just says the active area of 'netpoll_poll_dev'
> > is in the file net/core/netpoll.c. What is the purpose? Could you please tell me?
> 
> It prods the device to perform network work.
> 
> 	/* Process pending work on NIC */
> 	ops->ndo_poll_controller(dev);
> 
> 	poll_napi(dev);
Yeah, i will read the codes.


Thanks so much
Harry Wei
