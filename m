From: Yang Hongyang <yanghy@cn.fujitsu.com>
Subject: Re: [PATCH]IPv6:remove duplicate check of optlen when setsockopt
 with IPV6_PKTINFO option
Date: Wed, 14 Jan 2009 11:54:38 +0800
Message-ID: <496D61FE.7080500@cn.fujitsu.com>
References: <20090114034711.GA8361@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:53585 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753290AbZANDyq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jan 2009 22:54:46 -0500
In-Reply-To: <20090114034711.GA8361@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> Yang Hongyang <yanghy@cn.fujitsu.com> wrote:
>> Actually the condition (optlen == 0) is included in (optlen < sizeof(struct in6_pktinfo)),
>> so we do not need to check it separately.
> 
> You don't need to check optval == NULL either since that's the
> job of copy_from_user.

If optval==NULL, what we should return?EINVAL or EFAULT?
If it is EINVAL,then we should check it .otherwise it's the job of 
copy_from_user

> 
> Cheers,


-- 
Regards
Yang Hongyang
