From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/2] [IPV4] UDP: Always checksum even if without socket filter
Date: Tue, 20 Nov 2007 14:31:40 +0800
Message-ID: <20071120063140.GA14520@gondor.apana.org.au>
References: <20071119152933.GA19126@one.firstfloor.org> <20071119.142313.63549156.davem@davemloft.net> <20071120002945.91fafb2b.billfink@mindspring.com> <20071119.221531.142096724.davem@davemloft.net> <47427DD3.9030700@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, billfink@mindspring.com,
	andi@firstfloor.org, netdev@vger.kernel.org
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3304 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752063AbXKTGcP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 01:32:15 -0500
Content-Disposition: inline
In-Reply-To: <47427DD3.9030700@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 20, 2007 at 02:25:23PM +0800, Wang Chen wrote:
>
> I want to wait for more suggestions until make such patch.
> Because this solution leads to troubles with some apps, such as NFS.
> (http://bugzilla.kernel.org/show_bug.cgi?id=6660#c2)

Well that's easy.  Just get NFS to increment the counters itself.
Of course if someone could merge that code so that NFS uses more
generic code then it's even better.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
