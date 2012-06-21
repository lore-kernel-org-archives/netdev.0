From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Allow receiving packets on the fallback tunnel if they
 pass sanity checks
Date: Wed, 20 Jun 2012 21:04:05 -0700 (PDT)
Message-ID: <20120620.210405.2231549940491911080.davem@davemloft.net>
References: <20120605154058.GA16615@ipom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, phild@fb.com
To: phil@ipom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48816 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750934Ab2FUEEI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jun 2012 00:04:08 -0400
In-Reply-To: <20120605154058.GA16615@ipom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Dibowitz <phil@ipom.com>
Date: Tue, 5 Jun 2012 08:40:58 -0700

> From b413062771afbba064ae9bc49b5daed7abb1243d Mon Sep 17 00:00:00 2001
> From: Ville Nuorvala <ville.nuorvala@gmail.com>
> Subject: [PATCH] Allow receiving packets on the fallback tunnel if they pass sanity checks
> 
> The same IPv6 address checks are performed as with any normal tunnel,
> but as the fallback tunnel endpoint addresses are unspecified, the checks
> must be performed on a per-packet basis, rather than at tunnel
> configuration time.
> 
> Signed-off-by: Ville Nuorvala <ville.nuorvala@gmail.com>
> Tested-by: Phil Dibowitz <phil@ipom.com>

I've reviewed this change but I still have no idea why it's
necessary.

You need to compose a more lengthy and detailed commit log message
explaining everything before I'm going to consider applying this
patch.

You can't just say "we have some problem at Facebook, this patch fixes
it", and then merely describe word by word the content of the patch
without explaining the "why".  That simply doesn't cut it.

Thanks.
