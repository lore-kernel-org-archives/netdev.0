From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 0/3] net: mac80211: Neaten debugging
Date: Wed, 16 May 2012 09:59:31 +0200
Message-ID: <1337155171.4367.2.camel@jlt3.sipsolutions.net>
References: <1337106548.15553.8.camel@jlt3.sipsolutions.net>
	 <cover.1337116578.git.joe@perches.com>
	 <20120516.012319.1903390658912592000.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, linville@tuxdriver.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120516.012319.1903390658912592000.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-05-16 at 01:23 -0400, David Miller wrote:
> From: Joe Perches <joe@perches.com>
> Date: Tue, 15 May 2012 14:20:29 -0700
> 
> > Always use pr_debug variants instead of printk(KERN_DEBUG...)
> > 
> > Joe Perches (3):
> >   net: mac80211: Convert printk(KERN_DEBUG to pr_debug
> >   net: mac80211: Add and use ht_vdbg debugging macro
> >   net: mac80211: Add and use ibss_vdbg debugging macro
> 
> I really think this is the right thing to do and I hope the wireless
> folks integrate this.
> 
> I am well aware that you guys intend for some of these messages to be
> indications and notifications the user is intended to SEE, but in the
> cases where that is true KERN_DEBUG is absolutely not appropriate.
> 
> You should be using KERN_INFO or KERN_WARN in those situations
> instead.

Yeah, makes sense. I wonder if it makes sense to leave these under
#ifdef though? Why #ifdef something if it's going to be invisible most
of the time anyway?

johannes
