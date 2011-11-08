From: David Miller <davem@davemloft.net>
Subject: Re: Add IPSec IP Range in Linux kernel
Date: Tue, 08 Nov 2011 12:15:26 -0500 (EST)
Message-ID: <20111108.121526.1753608364705399194.davem@davemloft.net>
References: <92909814.20111108111036@mail.ru>
	<1320733465.21617.4.camel@ppwaskie-mobl2>
	<E1RNhE5-0005rf-00.danila-st-mail-ru@f105.mail.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peter.p.waskiewicz.jr@intel.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-crypto@vger.kernel.org,
	linux-security-module@vger.kernel.org
To: danila.st@mail.ru
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <E1RNhE5-0005rf-00.danila-st-mail-ru@f105.mail.ru>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daniil Stolnikov <danila.st@mail.ru>
Date: Tue, 08 Nov 2011 12:40:13 +0400

> I turned to you, the developers, but rather to urge you to implement
> this feature using IP range.

This won't be implemented, the keys used for IPSEC rule lookups supported by
the kernel are already way too complex.

Ranges can be synthesized by userspace, and that's the way it has to
be supported.
