From: Alexander Holler <holler@ahsoftware.de>
Subject: Re: [PATCH net-next v5 00/11] ipv6: Only create RTF_CACHE route after
 encountering pmtu exception
Date: Wed, 29 Jul 2015 11:25:40 +0200
Message-ID: <55B89C14.2070700@ahsoftware.de>
References: <1432353366-2296465-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Julian Anastasov <ja@ssi.bg>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Kernel Team <Kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from h1446028.stratoserver.net ([85.214.92.142]:40216 "EHLO
	mail.ahsoftware.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751882AbbG2JZv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2015 05:25:51 -0400
Received: from wandq.ahsoftware (p4FC374AF.dip0.t-ipconnect.de [79.195.116.175])
	(using TLSv1 with cipher ADH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mail.ahsoftware.de (Postfix) with ESMTPSA id 5F2982C9C219
	for <netdev@vger.kernel.org>; Wed, 29 Jul 2015 11:25:49 +0200 (CEST)
In-Reply-To: <1432353366-2296465-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 23.05.2015 um 05:55 schrieb Martin KaFai Lau:

> This series is to avoid creating a RTF_CACHE route whenever we are consulting
> the fib6 tree with a new destination.  Instead, only create RTF_CACHE route
> when we see a pmtu exception.

That even helps on systems without an IPv6-connection to world because 
it avoids the IPv6 route add/delete pairs which happened before whenever 
an IPv6-connection was tried (e.g. by Happy Eyeballs algorithms).

I think that's worse a laud. thanks.

Alexander Holler
