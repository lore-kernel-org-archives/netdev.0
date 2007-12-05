From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH 2/3] [UDP]: Restore missing inDatagrams increments
Date: Wed, 05 Dec 2007 09:42:45 +0800
Message-ID: <47560215.6050104@cn.fujitsu.com>
References: <20071204125844.GA2750@gondor.apana.org.au> <20071204130109.GA3098@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [222.73.24.84] ([222.73.24.84]:58151 "EHLO song.cn.fujitsu.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752541AbXLEBpg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2007 20:45:36 -0500
In-Reply-To: <20071204130109.GA3098@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu said the following on 2007-12-4 21:01:
> Hi Dave:
> 
> You were right about the SUNRPC stuff being missing after all.  I'd
> only looked in svcsock.c and missed the call in xprtsock.c.
> 
> [UDP]: Restore missing inDatagrams increments
> 
> The previous move of the the UDP inDatagrams counter caused the
> counting of encapsulated packets, SUNRPC data (as opposed to call)
> packets and RXRPC packets to go missing.
> 
> This patch restores all of these.
> 

I apologize for my miss in previous patch.

Herbert, don't you think the udp6inDatagrams should be counted too
in xprtsock?

