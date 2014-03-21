From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] csum experts, csum_replace2() is too expensive
Date: Fri, 21 Mar 2014 11:30:17 -0700
Message-ID: <1395426617.9117.0.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1395341341.9114.93.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140321.140730.1007660405690890605.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, herbert@gondor.apana.org.au, hkchu@google.com,
	mwdalton@google.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:43399 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750748AbaCUSa2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2014 14:30:28 -0400
Received: by mail-pa0-f52.google.com with SMTP id rd3so2746895pab.39
        for <netdev@vger.kernel.org>; Fri, 21 Mar 2014 11:30:28 -0700 (PDT)
In-Reply-To: <20140321.140730.1007660405690890605.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-03-21 at 14:07 -0400, David Miller wrote:

> Yeah the csum_replace*() are extremely suboptimal.
> 
> We should be able to cons up something cheap like the trick that
> ip_decrease_ttl() uses.
> 
> https://tools.ietf.org/html/rfc1624
> https://tools.ietf.org/html/rfc1141

Thanks for the pointers, I'll cook a patch.
