From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 00/10] e1000: Driver fixes and update to 7.0.38-k2
Date: Sat, 22 Apr 2006 22:53:45 -0700 (PDT)
Message-ID: <20060422.225345.125621531.davem@davemloft.net>
References: <443FF1A1.4000204@pobox.com>
	<E1FXAa6-0001Wt-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, auke-jan.h.kok@intel.com,
	netdev@vger.kernel.org, john.ronciak@intel.com,
	jesse.brandeburg@intel.com, Jeffrey.t.kirsher@intel.com,
	auke@foo-projects.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:27611
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751326AbWDWFxo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Apr 2006 01:53:44 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <E1FXAa6-0001Wt-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 22 Apr 2006 15:22:54 +1000

> Jeff Garzik <jgarzik@pobox.com> wrote:
> >
> >> 05/10: [PATCH] Update truesize with the length of the packet for
> >>                       packet split
> > 
> > These 10 patches look OK, but since the current kernel version is 
> > 2.6.17-rc1, that means we are in "bug fix only" mode right now.
> > 
> > Should I (a) apply these all to netdev2-.6.git#upstream, queueing them 
> > for 2.6.18, or (b) let you split the submission into two parts, bug 
> > fixes only and everything else?
> 
> It turns out that the truesize patch is pretty important as otherwise
> most of TCP receive socket buffer accounting falls apart.  So it should
> probably go into 2.6.17 and even 2.6.16-stable.

I totally agree.

Jeff please try to get at least this skb->truesize fix queued
to both -stable and current 2.6.x, it's really needed and
important for proper socket memory accounting on receive with
e1000.

Thanks.
