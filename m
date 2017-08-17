From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net] net: sched: fix NULL pointer dereference when action
 calls some targets
Date: Thu, 17 Aug 2017 12:02:20 +0200
Message-ID: <20170817100220.GC6928@salvia>
References: <0fa9a53725dd661571461cf283ec88cf15f4b139.1501932907.git.lucien.xin@gmail.com>
 <CAM_iQpWcg0a46gJ6Qp3F1pqvvsaJYajmDC2uG_mi9Av_vkFo2w@mail.gmail.com>
 <CADvbK_fuuBrh+eOuhQU+SYs9uazH2TRP+KUmhxU=hNZ=EkOT=Q@mail.gmail.com>
 <CAM_iQpXbtHDxVjZ=DoTiLXHLQy6q=JVBa66EqSOy95ZbFg-wkQ@mail.gmail.com>
 <CADvbK_cCQY0McHiZFKSTjdGdAjhB6RBej5n=SH2=hsLYC=Xa7w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        network dev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        netfilter-devel@vger.kernel.org,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ganesha.gnumonks.org ([213.95.27.120]:47256 "EHLO
        ganesha.gnumonks.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750913AbdHQKCw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2017 06:02:52 -0400
Content-Disposition: inline
In-Reply-To: <CADvbK_cCQY0McHiZFKSTjdGdAjhB6RBej5n=SH2=hsLYC=Xa7w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 16, 2017 at 08:39:44PM +1200, Xin Long wrote:
> On Wed, Aug 9, 2017 at 7:33 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> > On Mon, Aug 7, 2017 at 7:33 PM, Xin Long <lucien.xin@gmail.com> wrote:
> >> On Tue, Aug 8, 2017 at 9:15 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> >>> This looks like a completely API burden?
> >> netfilter xt targets are not really compatible with netsched action.
> >> I've got to say, the patch is just a way to make checkentry return
> >> false and avoid panic. like [1] said
> >
> > I don't doubt you fix a crash, I am thinking if we can
> > "fix" the API instead of fixing the caller.
> Hi, Cong,
> 
> For now, I don't think it's possible to change APIs or  some of their targets
> for the panic caused by action xt calling.
> 
> The common way should be fixed in net_sched side.
> 
> Given that the issue is very easy to triggered,
> let's wait for netfilter's replies for another few days,
> otherwise I will repost the fix, agree ?

Please, post the workaround so the kernel doesn't crash anymore.

This is going to be very hard to fix, it's broken since the very
beginning...

Thanks!
