From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: Re: [PATCH BUG-FIX] ipv6: allow to send packet after receiving	ICMPv6
 Too Big message with MTU field less than  IPV6_MIN_MTU
Date: Mon, 19 Apr 2010 14:49:02 +0800
Message-ID: <4BCBFCDE.7090206@cn.fujitsu.com>
References: <4BCBC6CE.9020302@cn.fujitsu.com> <20100419035535.GA7011@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"yoshfuji@linux-ipv6.org >> YOSHIFUJI Hideaki"
	<yoshfuji@linux-ipv6.org>,
	=?UTF-8?B?6a2P5YuH5Yab?= <yjwei@cn.fujitsu.com>,
	vladislav.yasevich@hp.com, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, Patrick McHardy <kaber@trash.net>,
	eric.dumazet@gmail.com, sri@us.ibm.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-sctp@vger.kernel.org
To: Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:63753 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751282Ab0DSGum (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Apr 2010 02:50:42 -0400
In-Reply-To: <20100419035535.GA7011@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote, at 04/19/2010 11:55 AM:
> 
> The patch looks good to me.

Thanks for reviewing this patch.

> If we wanted to optimise the allfrags case it may be better
> to reserve the space beforehand and generate the fragment header
> at the same time as we're doing the IPv6 header.
> 
> But it can't be all that important as it's been broken for so
> many years.

If somebody needs one patch to fix the broken,
I am pleased to do so. 

-- 
Best Regards
-----
Shan Wei


> 
> Thanks,


