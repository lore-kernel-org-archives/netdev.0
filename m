From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 0/3] net: mac80211: Neaten debugging
Date: Wed, 16 May 2012 17:56:41 +0200
Message-ID: <1337183801.18519.7.camel@jlt3.sipsolutions.net>
References: <1337106548.15553.8.camel@jlt3.sipsolutions.net>
	 <cover.1337116578.git.joe@perches.com>
	 <20120516.012319.1903390658912592000.davem@davemloft.net>
	 <1337155171.4367.2.camel@jlt3.sipsolutions.net>
	 <1337181771.4818.0.camel@joe2Laptop>
	 <1337182220.18519.5.camel@jlt3.sipsolutions.net>
	 <1337183004.4818.2.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linville@tuxdriver.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1337183004.4818.2.camel@joe2Laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-05-16 at 08:43 -0700, Joe Perches wrote:
> On Wed, 2012-05-16 at 17:30 +0200, Johannes Berg wrote:
> > On Wed, 2012-05-16 at 08:22 -0700, Joe Perches wrote:
> > > On Wed, 2012-05-16 at 09:59 +0200, Johannes Berg wrote:
> > > > I wonder if it makes sense to leave these under
> > > > #ifdef though? Why #ifdef something if it's going to be invisible most
> > > > of the time anyway?
> > > 
> > > I don't understand your point.
> > > #ifdef removal is a good thing.
> > 
> > Yeah, but you left a lot of them under ifdef, and I'm wondering why you
> > didn't remove them, or if you should, or ...
> 
> Those mostly use other different
> #ifdef CONFIG_SOME_OTHER_CONTROL elements.
> 
> There are I think 3 that I left because they do
> not use printk/pr_level but use wiphy_<level> or
> netdev_<level>.

Hmm, ok. I guess I need to just look at them and decide what should be
what. Thanks for the preparation work though :)

johannes
