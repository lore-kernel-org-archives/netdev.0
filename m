From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: linux-next: manual merge of the ipsec-next tree with the
 net-next tree
Date: Wed, 25 Sep 2013 07:29:23 +0200
Message-ID: <20130925052923.GU7660@secunet.com>
References: <20130924121629.f818475ddf308b0494cfce2a@canb.auug.org.au>
 <20130924102505.GS7660@secunet.com>
 <20130925095919.143635403832766c1b190202@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Fan Du <fan.du@windriver.com>, Joe Perches <joe@perches.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130925095919.143635403832766c1b190202@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 25, 2013 at 09:59:19AM +1000, Stephen Rothwell wrote:
> Hi Steffen,
> 
> On Tue, 24 Sep 2013 12:25:05 +0200 Steffen Klassert <steffen.klassert@secunet.com> wrote:
> >
> > On Tue, Sep 24, 2013 at 12:16:29PM +1000, Stephen Rothwell wrote:
> > > 
> > > Today's linux-next merge of the ipsec-next tree got a conflict in
> > > include/net/xfrm.h between commit d511337a1eda ("xfrm.h: Remove extern
> > > from function prototypes") from the net-next tree and commit aba826958830
> > > ("{ipv4,xfrm}: Introduce xfrm_tunnel_notifier for xfrm tunnel mode
> > > callback") from the ipsec-next tree.
> > 
> > Thanks for the information, I'll do a rebase of the ipsec-next
> > tree tomorrow.
> 
> Did you miss the end of the next paragraph:  "no action is required"?
> Dave can fix this up (like I did) when he merges your tree into his.
> 

I applied this patch shortly before the merge window opened, it is a left
over from the last develpoment cycle. I already rebased my tree onto
net-next in the past if that happened, even if there were no merge
conflicts. I did that just to see if everything still works. But I
could also do a test merge to see if everything still works and ask
to pull without a rebase then if this is the prefered way. Would make
my life easier :)
