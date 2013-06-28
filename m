From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [Patch net] ipv6,mcast: always hold idev->lock before mca_lock
Date: Fri, 28 Jun 2013 12:46:43 +0200
Message-ID: <20130628104643.GD15799@order.stressinduktion.org>
References: <1367998914-26423-1-git-send-email-amwang@redhat.com> <20130626225809.GB26180@order.stressinduktion.org> <1372302584.26333.2.camel@cr0> <20130627034204.GB18553@order.stressinduktion.org> <51CD2C7F.5060200@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Cong Wang <amwang@redhat.com>, netdev@vger.kernel.org,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	"David S. Miller" <davem@davemloft.net>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:43232 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755191Ab3F1Kqp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jun 2013 06:46:45 -0400
Content-Disposition: inline
In-Reply-To: <51CD2C7F.5060200@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 28, 2013 at 02:26:07PM +0800, Ding Tianhong wrote:
> On 2013/6/27 11:42, Hannes Frederic Sowa wrote:
> > On Thu, Jun 27, 2013 at 11:09:44AM +0800, Cong Wang wrote:
> >> On Thu, 2013-06-27 at 00:58 +0200, Hannes Frederic Sowa wrote:
> >>> I do confirm that if this last hunk is applied the idev->addr_list
> >>> traversal
> >>> is safe.
> >>>
> >>> Please let me know if no one is working on this, I would rebase it
> >>> then. 
> >>
> >> I will rebase my patch on latest net-next. I am assuming this patch
> >> looks good to you...
> > 
> > Yes, I am fine with the apporach you took. Perhaps you could describe
> > why the non-idev-locked call to__ipv6_get_lladdr-call is ok in that place.
> > 
> > Thanks a lot,
> > 
> >   Hannes
> > 
> > 
> > 
> I think the problem is clear:
> 
> [...]
> 						
> so i think it is clear to describe the reason.

Sorry, I meant "...in a comment". ;)

Greetings,

  Hannes
