From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: linux-next: merge of the wireless-next tree into the net-next
 tree
Date: Wed, 4 Jan 2012 09:02:10 -0500
Message-ID: <20120104140209.GA2540@tuxdriver.com>
References: <20120104105947.8bac77d1d7198a49e6feeca8@canb.auug.org.au>
 <20120103.202733.1070369898271428121.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	kvalo@qca.qualcomm.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120103.202733.1070369898271428121.davem@davemloft.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 03, 2012 at 08:27:33PM -0500, David Miller wrote:
> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Wed, 4 Jan 2012 10:59:47 +1100
> 
> > I noticed that the wireless-next tree has been merged into the net-next
> > tree today.  Has anything been done about the build failure I reported in
> > the wireless-next a while ago:
> > 
> > On 12/22/2011 16:58 +1100, Stephen Rothwell wrote:
> >>
> >> After merging the final tree, today's linux-next build (powerpc
> >> allyesconfig) failed like this:
> >> 
> >> drivers/net/wireless/ath/ath6kl/cfg80211.c:27:1: error: expected ')' before 'KBUILD_MODNAME'
> >> drivers/net/wireless/ath/ath6kl/cfg80211.c:27:1: error: 'KBUILD_MODNAME' undeclared here (not in a function)
> >> drivers/net/wireless/ath/ath6kl/cfg80211.c:27:1: error: expected ',' or ';' before string constant
> 
> It happens on any platform not just powerpc, John please fix this and
> don't have known unresolved -next build failures in your tree when you
> push to me.

I'm sorry, Dave.  I must have let this slip my mind over the holidays
-- maybe this explains why I didn't send the pull request before
Christmas...

Kalle has sent a temporary fix that sidesteps the issue by forcing the
SDIO and USB versions of ath6kl to be built as modules.  I'll forward
that on to you today.

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
