From: Yasuyuki KOZAKAI <yasuyuki.kozakai@toshiba.co.jp>
Subject: Re: [PATCH 2/10] [SKBUFF]: Add skb_morph
Date: Tue, 27 Nov 2007 15:50:15 +0900 (JST)
Message-ID: <200711270650.lAR6oGDr005426@toshiba.co.jp>
References: <E1Igv4m-00030E-00@gondolin.me.apana.org.au>
	<200711260650.lAQ6oOL9006774@toshiba.co.jp>
	<20071126151030.GC28022@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yasuyuki.kozakai@toshiba.co.jp, kaber@trash.net,
	davem@davemloft.net, hadi@cyberus.ca, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from imx9.toshiba.co.jp ([202.33.96.51]:55501 "EHLO
	imx9.toshiba.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750729AbXK0G6X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2007 01:58:23 -0500
Received: from imx12.toshiba.co.jp (imx12 [61.202.160.132])
	by imx9.toshiba.co.jp  with ESMTP id lAR6wKF3010304
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 27 Nov 2007 15:58:21 +0900 (JST)
Received: from arc11.toshiba.co.jp ([133.199.90.127])
	by imx12.toshiba.co.jp  with ESMTP id lAR6oISg028263
	for <netdev@vger.kernel.org>; Tue, 27 Nov 2007 15:50:18 +0900 (JST)
Received: (from root@localhost)
	by arc11.toshiba.co.jp  id lAR6oImk029424
	for netdev@vger.kernel.org; Tue, 27 Nov 2007 15:50:18 +0900 (JST)
Received: from mx2.toshiba.co.jp (localhost [127.0.0.1])
	by ovp11.toshiba.co.jp  with ESMTP id lAR6oHg4025627
	for <netdev@vger.kernel.org>; Tue, 27 Nov 2007 15:50:17 +0900 (JST)
In-Reply-To: <20071126151030.GC28022@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


From: Herbert Xu <herbert@gondor.apana.org.au>

> On Mon, Nov 26, 2007 at 03:50:22PM +0900, Yasuyuki KOZAKAI wrote:
> >
> > The refcount of nfct is leaked by this function. As a result,
> > nf_conntrack_ipv6.ko cannot be unloaded after doing "ping6 -s 2000 ..." .
> > dst->dst and dst->secpath are also needed to be released, I think.
> > 
> > Please consider to apply this patch.
> 
> Good catch! Thanks for spotting this.
> 
> I'm going to add the following patch to net-2.6.

That looks better.

-- Yasuyuki Kozakai
