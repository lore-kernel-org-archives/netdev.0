From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net: code cleanups
Date: Wed, 29 Sep 2010 20:13:49 -0700
Message-ID: <1285816429.1866.233.camel@Joe-Laptop>
References: <1285813497-7384-1-git-send-email-xiaosuo@gmail.com>
	 <1285814979.1866.229.camel@Joe-Laptop>
	 <AANLkTinRm7dB=n7KG8+TU0_=gf-19LUPV+40_m2YxbU2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:2563 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752672Ab0I3DNv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Sep 2010 23:13:51 -0400
In-Reply-To: <AANLkTinRm7dB=n7KG8+TU0_=gf-19LUPV+40_m2YxbU2@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-09-30 at 11:07 +0800, Changli Gao wrote:
> On Thu, Sep 30, 2010 at 10:49 AM, Joe Perches <joe@perches.com> wrote:
> > On Thu, 2010-09-30 at 10:24 +0800, Changli Gao wrote:
> >> Compare operations are more readable, and compilers generate the same code
> >> for the both.
> > As far as I know, not all supported versions of gcc
> > generate the same code.
> Is the former better for the compilers?

Yes.  I don't know how much it matters though.

> > Also, you could probably now remove the (__force u32) casts.
> Maybe Eric doesn't think so.

Comparisons of equal types don't need (__force u32) casts. 

They needed to be cast to u32 for the bitwise or's to avoid
compiler warnings.


