From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Change S390 anti-dependency to CONFIG_GENERIC_HARDIRQS
 dependency
Date: Tue, 14 Oct 2008 22:16:47 -0700 (PDT)
Message-ID: <20081014.221647.184282035.davem@davemloft.net>
References: <48F52E89.9050104@redhat.com>
	<20081014.165211.53009170.davem@davemloft.net>
	<48F5345B.6060108@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: afleming@gmail.com, afleming@freescale.com, netdev@vger.kernel.org
To: csnook@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50309
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751018AbYJOFRL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Oct 2008 01:17:11 -0400
In-Reply-To: <48F5345B.6060108@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chris Snook <csnook@redhat.com>
Date: Tue, 14 Oct 2008 20:07:55 -0400

> But then it will be much more of a pain to exclude the vast swath of
> irrelevant code in the kernel tree from your builds on these exotic
> architectures.  Have you ever built a kernel on s390?

That's totally irrelevant.

Does S390 have ethernet or ethernet-like devices?  If so, the someday
it might in fact might want to use something like phylib instead of
adding yet another implementation of programming a particular PHY
chip.

So in fact, something like phylib should be possible to enable even on
s390.

And this current situation means s390 builds get less coverage, making
allmodconfig test builds (which the s390 folks are obviously doing
since they hit this originally reported build failure) less
useful than they could be.

I would even be happy to make it such that SBUS drivers can be
enabled for test building on x86, and in fact right now in
Linus's tree that's very close to doable.
