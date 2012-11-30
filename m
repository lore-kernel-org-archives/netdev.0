From: Tejun Heo <tj@kernel.org>
Subject: Re: Wireless regression in workqueue: use mod_delayed_work() instead
 of __cancel + queue
Date: Fri, 30 Nov 2012 13:14:35 -0800
Message-ID: <20121130211435.GJ3873@htj.dyndns.org>
References: <alpine.DEB.2.00.1211280953350.26602@dr-wily.mit.edu>
 <alpine.DEB.2.00.1211281016320.26602@dr-wily.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.hengli.com.au>,
	"John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Anders Kaseorg <andersk@MIT.EDU>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1211281016320.26602@dr-wily.mit.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello, Anders.

Sorry about the delay.

On Wed, Nov 28, 2012 at 10:17:28AM -0500, Anders Kaseorg wrote:
> On Wed, 28 Nov 2012, Anders Kaseorg wrote:
> > My Intel 6250 wireless card (iwldvm) can no longer associate with a 
> > WPA-Enterprise network (PEAP-MSCHAPv2).  To my surprise, I bisected this 
> > regression to commit e7c2f967445dd2041f0f8e3179cca22bb8bb7f79, 
> > workqueue: use mod_delayed_work() instead of __cancel + queue.

I see.

> > A bunch of logs collected by Ubuntu apport are in this bug report: 
> >   https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1083980
> > 
> > How can I help to debug this?
> > 
> > I see that someone else reported another regression with the same commit 
> > last week, although this looks unrelated at first glance: 
> >   http://thread.gmane.org/gmane.linux.kernel/1395938

Urgh... that one was in my spam folder probably due to the mimed
content.  Nothing rings a bell yet.  Will keep looking into it.

Thanks.

-- 
tejun
