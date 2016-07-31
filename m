From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [Patch net] ppp: defer netns reference release for ppp channel
Date: Mon, 1 Aug 2016 01:22:02 +0300
Message-ID: <20160731222202.GI26208@uranus>
References: <1467781956-2229-1-git-send-email-xiyou.wangcong@gmail.com>
 <20160706082602.GM4666@uranus>
 <20160706122515.GN4666@uranus>
 <20160728103357.GA3031@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org,
	Matt.Bennett@alliedtelesis.co.nz,
	Paul Mackerras <paulus@samba.org>, linux-ppp@vger.kernel.org
To: Guillaume Nault <g.nault@alphalink.fr>
Return-path: <linux-ppp-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160728103357.GA3031@alphalink.fr>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 28, 2016 at 12:33:58PM +0200, Guillaume Nault wrote:
> > 
> > After staring more I think the patch should be fine as a fix
> > since implementing sync with ppp_[re|un]register_channel and
> > ppp_ioctl might need a way more work.
> > 
> 
> [Sorry for arriving so late in the game, I was offline the last 3 weeks]
> 
> I agree having some symmetry between the creation and deletion
> processes would be nice and would make the code easier to reason about.
> Actually, I released the channel netns in ppp_unregister_channel() for
> exactly this reason (and failed to spot this race).
> 
> But the code is already quite asymmetric and it's certainly too late to
> move away from this scheme now. So releasing the channel netns in

Yes, this module needs cleanup in general, so fix is fine, thanks!
