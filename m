From: David Miller <davem@davemloft.net>
Subject: Re: [Bug 11633] Kernel panic after patch
 f3994eceebf64cf356a82ffb2718ef538eb8d4f4
Date: Wed, 01 Oct 2008 07:10:17 -0700 (PDT)
Message-ID: <20081001.071017.71670834.davem@davemloft.net>
References: <20080925023622.GA15800@gondor.apana.org.au>
	<20080924.194955.209981542.davem@davemloft.net>
	<20080925032554.GA16155@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41017
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751845AbYJAOK2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2008 10:10:28 -0400
In-Reply-To: <20080925032554.GA16155@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 25 Sep 2008 11:25:54 +0800

> net: BUG instead of corrupting memory in pskb_expand_head
> 
> If the caller of pskb_expand_head specifies a negative nhead
> we'll silently overwrite other people's memory.  This patch
> makes it BUG instead.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied to net-next-2.6, thanks!
