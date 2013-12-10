From: Maxime Bizon <mbizon@freebox.fr>
Subject: Re: [PATCH 2/3] xfrm: Increase the garbage collector threshold
Date: Tue, 10 Dec 2013 15:38:43 +0100
Message-ID: <1386686323.22947.26.camel@sakura.staff.proxad.net>
References: <1383294107-7509-1-git-send-email-steffen.klassert@secunet.com>
	 <1383294107-7509-3-git-send-email-steffen.klassert@secunet.com>
Reply-To: mbizon@freebox.fr
Mime-Version: 1.0
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.iliad.fr ([212.27.33.1]:33471 "EHLO ns.iliad.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752900Ab3LJOir (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Dec 2013 09:38:47 -0500
In-Reply-To: <1383294107-7509-3-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Fri, 2013-11-01 at 09:21 +0100, Steffen Klassert wrote:

Hello Steffen,

> It turned out that the current threshold before we
> start garbage collecting is much to small for some
> workloads, so increase it from 1024 to 32768. This
> means that we start the garbage collector if we have
> more than 32768 dst entries in the system and refuse
> new allocations if we are above 65536.

sorry to dig an old thread, but could you please explain the lifetime of
those dst entries ?

After basic tests it seems the ipv4 dst entry needs to be released first
before the xfrm dst can be released by gc.

-- 
Maxime
