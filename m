From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] [IPV6] ADDRCONF: Lifetime handling fixes
Date: Fri, 28 Jul 2006 01:11:03 -0700 (PDT)
Message-ID: <20060728.011103.21926965.davem@davemloft.net>
References: <20060727.185726.133626295.yoshfuji@linux-ipv6.org>
	<20060727102802.GM6026@innerghost.net>
	<20060727.194929.796987341.takamiya@po.ntts.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hsantos@av.it.pt, yoshfuji@linux-ipv6.org, vnuorval@tcs.hut.fi,
	anttit@tcs.hut.fi, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:30404
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1161092AbWG1ILY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Jul 2006 04:11:24 -0400
To: takamiya@po.ntts.co.jp
In-Reply-To: <20060727.194929.796987341.takamiya@po.ntts.co.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>
Date: Thu, 27 Jul 2006 19:49:29 +0900 (JST)

> >> Thu, 27 Jul 2006 11:28:02 +0100
> >> [Subject: Re: [RFC] [IPV6] ADDRCONF: Lifetime handling fixes] wrote...
> >> Hugo Santos <hsantos@av.it.pt> wrote...
> 
> > > +	ifp = ipv6_get_ifaddr(pfx, dev, 1);
> > > +	if (ifp == NULL)
> > > +		return -ENOENT;
> > > +
> > > +	if (!valid_lft || (prefered_lft > valid_lft))
> > > +		return -EINVAL;
> >                 ^^^^^^^^^^^^^^^
> > 
> >    Unreleased ifp? This test should go before ipv6_get_ifaddr.
> 
>   That's right. Thanks.

Thank you Takamiya-san.

Besides this correction, the rest of the changes look fine to me.
I think we should get these fixes into 2.6.18, if you don't mind.

So please resubmit with the correction.

Thanks again.
