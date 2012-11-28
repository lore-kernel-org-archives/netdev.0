From: Anders Kaseorg <andersk@MIT.EDU>
Subject: Re: Wireless regression in workqueue: use mod_delayed_work() instead
 of __cancel + queue
Date: Wed, 28 Nov 2012 10:17:28 -0500 (EST)
Message-ID: <alpine.DEB.2.00.1211281016320.26602@dr-wily.mit.edu>
References: <alpine.DEB.2.00.1211280953350.26602@dr-wily.mit.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Tejun Heo <tj@kernel.org>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.00.1211280953350.26602@dr-wily.mit.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 28 Nov 2012, Anders Kaseorg wrote:
> My Intel 6250 wireless card (iwldvm) can no longer associate with a 
> WPA-Enterprise network (PEAP-MSCHAPv2).  To my surprise, I bisected this 
> regression to commit e7c2f967445dd2041f0f8e3179cca22bb8bb7f79, 
> workqueue: use mod_delayed_work() instead of __cancel + queue.
> 
> A bunch of logs collected by Ubuntu apport are in this bug report: 
>   https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1083980
> 
> How can I help to debug this?
> 
> I see that someone else reported another regression with the same commit 
> last week, although this looks unrelated at first glance: 
>   http://thread.gmane.org/gmane.linux.kernel/1395938
> 
> Anders

(Oops, re-sending to fix a typo in the LKML address.)

Anders
