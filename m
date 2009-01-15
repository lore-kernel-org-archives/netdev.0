From: Yang Hongyang <yanghy@cn.fujitsu.com>
Subject: Re: [PATCH]IPv6:remove duplicate check of optlen when setsockopt
 with IPV6_PKTINFO option
Date: Thu, 15 Jan 2009 13:25:22 +0800
Message-ID: <496EC8C2.1090107@cn.fujitsu.com>
References: <496D61FE.7080500@cn.fujitsu.com> <20090114044856.GA14726@gondor.apana.org.au> <20090114.210242.163189105.davem@davemloft.net> <20090115050449.GA30174@gondor.apana.org.au> <20090115050638.GA30224@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:60244 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754756AbZAOFZY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jan 2009 00:25:24 -0500
In-Reply-To: <20090115050638.GA30224@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Thu, Jan 15, 2009 at 04:04:49PM +1100, Herbert Xu wrote:
>> On Wed, Jan 14, 2009 at 09:02:42PM -0800, David Miller wrote:
>>> Actually, we return EINVAL just a few lines above this code
>>> block for some other socket option cases when optval==NULL.
>> Well the very next option IPV6_2292PKTOPTIONS returns EFAULT
>> by virtue of not explicitly checking optval == NULL :)
> 
> In fact checking for a NULL pointer is strictly speaking wrong
> since NULL may actually have been mapped in user-space :)

But there are some cases that user-space passes a NULL pointer
to the kernel,Otherwise,copy_from_user needn't to cheak the
NULL pointer either.:)

By the way,I think most part of the ipv6 socket option implementation
are kind of ugly:)

> 
> Cheers,


-- 
Regards
Yang Hongyang
