From: David Miller <davem@davemloft.net>
Subject: Re: Add IPSec IP Range in Linux kernel
Date: Tue, 08 Nov 2011 20:42:53 -0500 (EST)
Message-ID: <20111108.204253.891598837549584662.davem@davemloft.net>
References: <CACVxJT887ATwt97iw7mPEkH+KXgy1WbsP_aUB_X-8uLQ+6YsLQ@mail.gmail.com>
	<20111108.121620.2044664919065812135.davem@davemloft.net>
	<1289495586.20111109093607@mail.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-crypto@vger.kernel.org,
	linux-security-module@vger.kernel.org, adobriyan@gmail.com,
	peter.p.waskiewicz.jr@intel.com
To: danila.st@mail.ru
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <1289495586.20111109093607@mail.ru>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daniil Stolnikov <danila.st@mail.ru>
Date: Wed, 9 Nov 2011 09:36:07 +0800

> I never imagined that it will cause some difficulties.

Ever feature has side effects and costs associated with it.  Some of
which can be non-trivial.

Like I said, if you want address ranges, ask the userland IPSEC daemon
authors to synthesize it.

I'm really not able to devote the time necessary to explain every
nuance of how we store IPSEC rules in the kernel side database and
what implications that has for expanding the kind of match keys we
support.
