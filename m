From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: Re: question about UFO behavior for bridge device
Date: Sat, 14 May 2011 17:54:06 +0800
Message-ID: <4DCE513E.9040002@cn.fujitsu.com>
References: <4DCCF803.5020805@cn.fujitsu.com> <1305292012.4065.441.camel@localhost> <20110513143627.GA29054@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.hengli.com.au>,
	Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:61498 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751860Ab1ENJyI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 May 2011 05:54:08 -0400
In-Reply-To: <20110513143627.GA29054@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote, at 05/13/2011 10:36 PM:
> On Fri, May 13, 2011 at 02:06:52PM +0100, Ben Hutchings wrote:
>>
>>> But, actually, i saw original big skb in eth0's tcpdump file, but not segmented skbs.
>>> The behavior is right or what we want?
>>> Is there anything missed about my analysis?
>>
>> I assume that packet capturing is handled earlier in the transmit path.
> 
> Yes it is.  It's the same with TSO.

Be cheated by tcpdump. :-(
dev_queue_xmit_nit(skb, dev) which dumps packet to user is called before handling GSO segments.

Thanks very much.

-- 
Best Regards
-----
Shan Wei
