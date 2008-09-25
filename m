From: David Miller <davem@davemloft.net>
Subject: Re: [Bug 11633] Kernel panic after patch
 f3994eceebf64cf356a82ffb2718ef538eb8d4f4
Date: Wed, 24 Sep 2008 19:49:55 -0700 (PDT)
Message-ID: <20080924.194955.209981542.davem@davemloft.net>
References: <20080925011035.GA15055@gondor.apana.org.au>
	<20080925012105.GA15241@gondor.apana.org.au>
	<20080925023622.GA15800@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58263
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752166AbYIYCuI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2008 22:50:08 -0400
In-Reply-To: <20080925023622.GA15800@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 25 Sep 2008 10:36:22 +0800

> Here's the fix.
> 
> ipsec: Fix pskb_expand_head corruption in xfrm_state_check_space
> 
> We're never supposed to shrink the headroom or tailroom.  In fact,
> shrinking the headroom is a fatal action.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks a lot for diagnosing this and writing the patch Herbert.

I'll integrate this when I next get a chance.
