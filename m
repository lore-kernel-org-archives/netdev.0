From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH ipsec-next] pfkey: fix SADB_X_EXT_FILTER length check
Date: Fri, 21 Feb 2014 07:51:39 +0100
Message-ID: <20140221065139.GG32371@secunet.com>
References: <20140220100735.GA25752@elgon.mountain>
 <1392904361-11127-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <herbert@gondor.apana.org.au>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>, <dan.carpenter@oracle.com>,
	<kbuild-all@01.org>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:41440 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750852AbaBUGvp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Feb 2014 01:51:45 -0500
Content-Disposition: inline
In-Reply-To: <1392904361-11127-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 20, 2014 at 02:52:41PM +0100, Nicolas Dichtel wrote:
> This patch fixes commit d3623099d350 ("ipsec: add support of limited SA dump").
> 
> sadb_ext_min_len array should be updated with the new type (SADB_X_EXT_FILTER).
> 
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Thanks for the quick fix, applied to ipsec-next.
