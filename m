From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/xfrm: Use an IS_ERR test rather than a NULL test
Date: Tue, 02 Sep 2008 17:24:48 -0700 (PDT)
Message-ID: <20080902.172448.84151776.davem@davemloft.net>
References: <200809011053.34028.brunel@diku.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: brunel@diku.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60522
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752280AbYICAYy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2008 20:24:54 -0400
In-Reply-To: <200809011053.34028.brunel@diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julien Brunel <brunel@diku.dk>
Date: Mon, 1 Sep 2008 10:53:33 +0200

> In case of error, the function xfrm_bundle_create returns an ERR
> pointer, but never returns a NULL pointer. So a NULL test that comes
> after an IS_ERR test should be deleted.
> 
> The semantic match that finds this problem is as follows:
> (http://www.emn.fr/x-info/coccinelle/)
> 
> // <smpl>
> @match_bad_null_test@
> expression x, E;
> statement S1,S2;
> @@
> x =  xfrm_bundle_create(...)
> ... when != x = E
> *  if (x != NULL) 
> S1 else S2
> // </smpl>
> 
> Signed-off-by:  Julien Brunel <brunel@diku.dk>
> Signed-off-by:  Julia Lawall <julia@diku.dk>

Looks good, patch applied, thanks.
