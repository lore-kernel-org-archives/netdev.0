From: Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>
Subject: Re: [RFC] [IPV6] ADDRCONF: Lifetime handling fixes
Date: Thu, 27 Jul 2006 19:49:29 +0900 (JST)
Message-ID: <20060727.194929.796987341.takamiya@po.ntts.co.jp>
References: <20060727.185726.133626295.yoshfuji@linux-ipv6.org>
	<20060727102802.GM6026@innerghost.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, davem@davemloft.net, vnuorval@tcs.hut.fi,
	anttit@tcs.hut.fi, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.ics.ntts.co.jp ([202.32.24.45]:51901 "EHLO
	mail1.ics.ntts.co.jp") by vger.kernel.org with ESMTP
	id S1751122AbWG0Kw6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Jul 2006 06:52:58 -0400
To: hsantos@av.it.pt
In-Reply-To: <20060727102802.GM6026@innerghost.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

  This is Takamiya, from USAGI Project.

>> Thu, 27 Jul 2006 11:28:02 +0100
>> [Subject: Re: [RFC] [IPV6] ADDRCONF: Lifetime handling fixes] wrote...
>> Hugo Santos <hsantos@av.it.pt> wrote...

> > +	ifp = ipv6_get_ifaddr(pfx, dev, 1);
> > +	if (ifp == NULL)
> > +		return -ENOENT;
> > +
> > +	if (!valid_lft || (prefered_lft > valid_lft))
> > +		return -EINVAL;
>                 ^^^^^^^^^^^^^^^
> 
>    Unreleased ifp? This test should go before ipv6_get_ifaddr.

  That's right. Thanks.

--
Noriaki Takamiya
