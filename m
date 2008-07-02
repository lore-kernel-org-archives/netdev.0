From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [GIT PULL net-next-2.6] IPv6 Updates
Date: Wed, 02 Jul 2008 18:46:12 +0900 (JST)
Message-ID: <20080702.184612.08424681.yoshfuji@linux-ipv6.org>
References: <20080702.123957.75682669.yoshfuji@linux-ipv6.org>
	<486B2B39.9090404@miraclelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: nooiwa@miraclelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:36005 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753597AbYGBJpK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2008 05:45:10 -0400
In-Reply-To: <486B2B39.9090404@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <486B2B39.9090404@miraclelinux.com> (at Wed, 02 Jul 2008 16:16:09 +0900), Naohiro Ooiwa <nooiwa@miraclelinux.com> says:

> Hi YOSHIFUJI-san
> 
> If I'm not missing something, the following code
> should be out side of the for-loop.
> 
> >
> > -		if (local)
> > -			return local;
> > +			if (local)
> > +				return local;
> >
> > -		if (flags & RT6_LOOKUP_F_IFACE)
> > -			return net->ipv6.ip6_null_entry;
> > +			if (flags & RT6_LOOKUP_F_IFACE)
> > +				return net->ipv6.ip6_null_entry;
> > +		}
> >  	}

I do agree....respinning...

--yoshfuji
