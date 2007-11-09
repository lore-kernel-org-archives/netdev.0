From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 3/5] memory accounting
Date: Fri, 9 Nov 2007 21:07:58 +0800
Message-ID: <20071109130758.GE27984@gondor.apana.org.au>
References: <47264E2D.4080109@redhat.com> <47264F49.90308@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Satoshi Oshima <satoshi.oshima.fk@hitachi.com>,
	Andi Kleen <andi@firstfloor.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	yoshfuji@linux-ipv6.org,
	Yumiko Sugita <yumiko.sugita.yf@hitachi.com>
To: Hideo AOKI <haoki@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4871 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752407AbXKINIK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2007 08:08:10 -0500
Content-Disposition: inline
In-Reply-To: <47264F49.90308@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 29, 2007 at 05:23:21PM -0400, Hideo AOKI wrote:
> This patch adds UDP memory usage accounting in IPv4.
> 
> --
> Hideo Aoki
> Hitachi Computer Products (America) Inc.

> 
> Signed-off-by: Satoshi Oshima <satoshi.oshima.fk@hitachi.com>
> Signed-off-by: Hideo Aoki <haoki@redhat.com>

This looks fine for now.  Although in future I'd prefer this
to use the forward alloc model used by stream sockets.  In fact
we should be able to share most of that code too.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
