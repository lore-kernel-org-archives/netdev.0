From: Daniil Stolnikov <danila.st@mail.ru>
Subject: Re: Add IPSec IP Range in Linux kernel
Date: Wed, 9 Nov 2011 09:36:07 +0800
Message-ID: <1289495586.20111109093607@mail.ru>
References: <92909814.20111108111036@mail.ru> <1320733465.21617.4.camel@ppwaskie-mobl2> <CACVxJT887ATwt97iw7mPEkH+KXgy1WbsP_aUB_X-8uLQ+6YsLQ@mail.gmail.com> <20111108.121620.2044664919065812135.davem@davemloft.net>
Reply-To: Daniil Stolnikov <danila.st@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1251
Content-Transfer-Encoding: 8BIT
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	<linux-crypto@vger.kernel.org>,
	<linux-security-module@vger.kernel.org>, <davem@davemloft.net>,
	<adobriyan@gmail.com>, <peter.p.waskiewicz.jr@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111108.121620.2044664919065812135.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: Daniil Stolnikov <danila.st@mail.ru>
> Date: Tue, 08 Nov 2011 12:40:13 +0400

>> I turned to you, the developers, but rather to urge you to implement
>> this feature using IP range.

> This won't be implemented, the keys used for IPSEC rule lookups supported by
> the kernel are already way too complex.

> From: Alexey Dobriyan <adobriyan@gmail.com>
> Date: Tue, 8 Nov 2011 14:08:24 +0200

>> changing addr_match() is trivial for ipv4 and easy for ipv6. :-)

> No, this is not happening.  This added complexity screws up all the hash table
> and lookup optimizations we have in the XFRM layer.

I never imagined that it will cause some difficulties. Several questions arise:

1) How complex is this implementation?
2) How to do this time?
3) Will this feature is implemented vsetaki? If so, how soon and what will it take?


> Ranges can be synthesized by userspace, and that's the way it has to
> be supported.

That is, you want to say that all this can be done at the user level? How so?

In general, if there are alternative implementations of this feature without support at the kernel level? What are some loopholes, tricks? It is meant to create multiple connections to the same subnet subranges without the use of masks such as / 29. Perhaps this can be achieved through l2tp? There, in the present setup IP range. Or is it both?
