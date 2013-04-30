From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next 2/3] bridge: only expire the mdb entry when
 query is received
Date: Tue, 30 Apr 2013 11:32:04 +0800
Message-ID: <1367292724.3216.6.camel@cr0>
References: <1367220392-17496-1-git-send-email-amwang@redhat.com>
	 <1367220392-17496-2-git-send-email-amwang@redhat.com>
	 <1367291857.3216.2.camel@cr0> <20130430032221.GA20471@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Adam Baker <linux@baker-net.org.uk>
To: Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14218 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757179Ab3D3DcU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Apr 2013 23:32:20 -0400
In-Reply-To: <20130430032221.GA20471@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-04-30 at 11:22 +0800, Herbert Xu wrote:
> On Tue, Apr 30, 2013 at 11:17:37AM +0800, Cong Wang wrote:
> > 
> > One problem with this solution is that the temp mdb entry will no longer
> > be expired automatically any more, since no query no timer.
> > 
> > I am wondering if we should find other way to fix it, for example,
> > touching the timer as long as there is multicast traffic (non-IGMP).
> 
> mdb entries represent group subscriptions.  So what you're saying
> is that group subscriptions aren't expiring.
> 
> Which isn't a problem at all since if there is no querier then group
> subscriptions shouldn't expire.  There has to be at least one querier
> in the network for this thing to work.  Otherwise it just degenerates
> into a non-snooping switch, which is OK.

Makes sense. I will put this in the changelog.

Thanks.
