From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [bisected] [oops] gre/gro oops in skb_gro_receive+0x118/0x453
Date: Fri, 16 May 2014 09:50:27 -0700
Message-ID: <1400259027.7973.211.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140516104014.607d2d0f@vostro>
	 <1400245157.7973.150.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140516173443.0b40157e@vostro>
	 <1400257768.7973.204.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140516194037.4486cd63@vostro>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Timo Teras <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:58165 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750935AbaEPQua (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 12:50:30 -0400
Received: by mail-pa0-f48.google.com with SMTP id rd3so2778091pab.21
        for <netdev@vger.kernel.org>; Fri, 16 May 2014 09:50:29 -0700 (PDT)
In-Reply-To: <20140516194037.4486cd63@vostro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-05-16 at 19:40 +0300, Timo Teras wrote:

> Both the gre bound interface, and the inside interface are identical.
> 
> And you are right. It might be driver / hw / gro capability specific
> issue. I had also report from a user using similar gre/ipsec/forwarding
> setup, that 3.13-stable kernels works on his hardware.
> 

> Using unmodified in-tree r8169 module.
> 
> Please let me know if additional information is needed.

What happens if you disable gro on eth0 ?
