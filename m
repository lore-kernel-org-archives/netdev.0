From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH 0/8] l2tp: introduce L2TPv3 support
Date: Tue, 24 Feb 2009 14:39:08 +0800
Message-ID: <20090224063908.GA20652@gondor.apana.org.au>
References: <200902221752.n1MHqK2b006531@bert.katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:60692 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753429AbZBXGjP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2009 01:39:15 -0500
Content-Disposition: inline
In-Reply-To: <200902221752.n1MHqK2b006531@bert.katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

James Chapman <jchapman@katalix.com> wrote:
> This patch series implements L2TPv3. It replaces the existing pppol2tp
> driver with a number of separate drivers, namely:-
> 
> l2tp_core    - L2TP driver core. Always required.
> l2tp_ppp     - L2TP PPP
> l2tp_eth     - L2TPv3 ethernet pseudowire
> l2tp_ip      - L2TPv3 IP encapsulation
> l2tp_netlink - L2TPv3 netlink API

Have you thought by using the rtnl_link_ops interface instead
of your own netlink API?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
