From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 01/19] netfilter: move nf_conntrack initialize out of
 pernet operations
Date: Sun, 13 Jan 2013 16:07:05 +0100
Message-ID: <20130113150705.GA32085@1984>
References: <1356662206-2260-1-git-send-email-gaofeng@cn.fujitsu.com>
 <20130110164154.GA5457@1984>
 <50EF6470.5000303@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	canqunzhang@gmail.com, kaber@trash.net, ebiederm@xmission.com
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <50EF6470.5000303@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 11, 2013 at 09:01:36AM +0800, Gao feng wrote:
> On 2013/01/11 00:41, Pablo Neira Ayuso wrote:
> > First off, thanks for looking into this.
> > 
> > I want to get this fix into 3.8 and -stable but this patch includes a
> > rework whose scope is net-next (upcoming 3.9).
> > 
> > The attached patch aims to fix the issue according to your patch
> > description. Once this is in, we can revisit your code refactoring
> > proposal.
> > 
> > Let me know.
> > 
> 
> Yes,I'm happy this bug being fixed in 3.8.
> So what I should do is waiting for below patch being accepted and
> then rebase my patchset? It's OK.

Yes, you'll have to rebase upon nf-next. First, I have to ask David to
pull from nf to get this fixes, so you'll have to wait a bit. If any
doubt, contact me.

While at it, please, merge patches 09, 10 and 11 in one single patch.

And 12 to 18. We need that the repository has to remain consistent
between two patches.

No problem if the patch seems big as soon as changes belong to the
same scope.

> Thanks!
[...]
> Acked-by: Gao feng <gaofeng@cn.fujitsu.com>

And this patch applied, thanks a lot Gao.
