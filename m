From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] fragment: add fast path
Date: Mon, 14 Jun 2010 14:15:17 +0900
Message-ID: <4C15BAE5.6010900@linux-ipv6.org>
References: <1276470995-21713-1-git-send-email-xiaosuo@gmail.com> <20100613.181857.189703148.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: xiaosuo@gmail.com, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, kaber@trash.net, netdev@vger.kernel.org,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:46931 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750756Ab0FNFPz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jun 2010 01:15:55 -0400
In-Reply-To: <20100613.181857.189703148.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
>> As the fragments are usually in order,
> 
> In what universe does this happen "usually"?
> 
> Linux has been outputting fragments in reverse order for more than 10
> years.
> 
> I'm not applying this patch.

Dave,  I know we've been sending in reverse order, of course.
And, as far as I know, it seems Linux is the only implementation
which sends fragments in reverse order.

This is receiving side.  I think we should accept the fact
that Linux is not the only implementation, no?

--yoshfuji
