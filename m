From: Joe Perches <joe@perches.com>
Subject: Re: [ath9k-devel] [PATCH net-next 00/21] treewide: Use consistent
 api style for address testing
Date: Fri, 19 Oct 2012 09:39:12 -0700
Message-ID: <1350664752.16440.3.camel@joe-AO722>
References: <cover.1350618006.git.joe@perches.com>
	 <1350630254.2293.183.camel@edumazet-glaptop> <20121019115517.7b8514a8@mj>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	ath9k-devel <ath9k-devel@lists.ath9k.org>
To: Pavel Roskin <proski@gnu.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121019115517.7b8514a8@mj>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(cc list trimmed)

On Fri, 2012-10-19 at 11:55 -0400, Pavel Roskin wrote:
> On Fri, 19 Oct 2012 09:04:14 +0200
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
> > Yes they are some names discrepancies, thats a big deal.
> > 
> > And we have alloc_skb() / kfree_skb() / skb_clone() 
> > 
> > Why not skb_alloc() / skb_free() / skb_clone() ?
> > 
> > Some people actually know current code by name of functions, they dont
> > want to change their mind and having to grep include files and git log
> > to learn the new names of an old function, especially when traveling
> > and using a laptop.
> 
> I agree.
> 
> Also, it makes sense to introduce a more consistent name for a function
> when it's improved in some way and the callers need to be adjusted or
> re-checked.
> 
> That way, the old name can be phased out as the code is made compatible
> with the new function.

That can also be done, as was done with this series, with backward
compatible #defines.
