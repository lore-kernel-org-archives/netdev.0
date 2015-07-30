From: Alexander Holler <holler@ahsoftware.de>
Subject: Re: [PATCH net-next v5 00/11] ipv6: Only create RTF_CACHE route after
 encountering pmtu exception
Date: Thu, 30 Jul 2015 13:57:56 +0200
Message-ID: <55BA1144.9090203@ahsoftware.de>
References: <1432353366-2296465-1-git-send-email-kafai@fb.com>
 <55B89C14.2070700@ahsoftware.de>
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
Received: from h1446028.stratoserver.net ([85.214.92.142]:56281 "EHLO
	mail.ahsoftware.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750862AbbG3L6G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2015 07:58:06 -0400
Received: from wandq.ahsoftware (p4FC37192.dip0.t-ipconnect.de [79.195.113.146])
	(using TLSv1 with cipher ADH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mail.ahsoftware.de (Postfix) with ESMTPSA id 2DD2C2C9C21C
	for <netdev@vger.kernel.org>; Thu, 30 Jul 2015 13:58:03 +0200 (CEST)
In-Reply-To: <55B89C14.2070700@ahsoftware.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 29.07.2015 um 11:25 schrieb Alexander Holler:
> Am 23.05.2015 um 05:55 schrieb Martin KaFai Lau:
>
>> This series is to avoid creating a RTF_CACHE route whenever we are
>> consulting
>> the fib6 tree with a new destination.  Instead, only create RTF_CACHE
>> route
>> when we see a pmtu exception.
>
> That even helps on systems without an IPv6-connection to world because
> it avoids the IPv6 route add/delete pairs which happened before whenever
> an IPv6-connection was tried (e.g. by Happy Eyeballs algorithms).
>
> I think that's worse a laud. thanks.

Of course, I meant worth. Sorry, but the left part of my brain seems to 
be sometimes in a (maybe forced) power save mode. ;)

Also I wonder how the previous algorithm went into the kernel at all or 
why it wasn't fixed earlier. Anyway, it's great that someone took the 
time to fix that annoying behaviour (I've had on my radar since quiet 
some time).

Thanks again

> Alexander Holler
