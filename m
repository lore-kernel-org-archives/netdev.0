From: David Miller <davem@davemloft.net>
Subject: Re: ip_frag_reasm() can return uninitialized variable
Date: Thu, 18 Oct 2007 04:47:19 -0700 (PDT)
Message-ID: <20071018.044719.115915456.davem@davemloft.net>
References: <20071018105203.GJ3778@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: bunk@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36368
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1762001AbXJRLrG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 07:47:06 -0400
In-Reply-To: <20071018105203.GJ3778@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@kernel.org>
Date: Thu, 18 Oct 2007 12:52:03 +0200

> Since commit 1706d58763c36133d7fce6cc78b1444fd40db28c ip_frag_reasm() 
> can return the value of an uninitialized variable:

I have a fix for this in my net-2.6 tree, thanks Adrian.
