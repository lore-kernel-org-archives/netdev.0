From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v5 00/11] ipv6: Only create RTF_CACHE route
 after encountering pmtu exception
Date: Fri, 28 Aug 2015 11:27:53 -0700 (PDT)
Message-ID: <20150828.112753.622854363543577182.davem@davemloft.net>
References: <55CEEECA.8000702@ahsoftware.de>
	<55D1ACB8.3040500@ahsoftware.de>
	<20150828073429.GA67211@kafai-mba.gkf168.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: holler@ahsoftware.de, netdev@vger.kernel.org,
	hannes@stressinduktion.org, ja@ssi.bg,
	steffen.klassert@secunet.com, Kernel-team@fb.com,
	stable@vger.kernel.org, linux-kernel@vger.kernel.org
To: kafai@fb.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20150828073429.GA67211@kafai-mba.gkf168.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Martin KaFai Lau <kafai@fb.com>
Date: Fri, 28 Aug 2015 00:36:38 -0700

> On Mon, Aug 17, 2015 at 11:43:20AM +0200, Alexander Holler wrote:
>> That's why I vote to check out if it's possible/reasonable to backport this
>> series to the stable kernels.
> I have backported to 4.0.y without major issue, so possible.
> 
> I did try on 3.1x and gave up.
> 
> It is a lot of changes,  so I don't think it is a good idea for -stable.

I am absolutely, firmly, against any of this work going into -stable.

It is completely inappropriate, the potential for regressions is
enormous.
