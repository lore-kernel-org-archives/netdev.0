From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [IPV4]: Update MTU to all related cache entries in
 ip_rt_frag_needed()
Date: Tue, 29 Apr 2008 03:32:45 -0700 (PDT)
Message-ID: <20080429.033245.141337746.davem@davemloft.net>
References: <48105B67.7060804@iki.fi>
	<20080426.232756.259679168.davem@davemloft.net>
	<48143ADE.40304@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47656
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753957AbYD2Kcq convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Apr 2008 06:32:46 -0400
In-Reply-To: <48143ADE.40304@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Timo_Ter=E4s <timo.teras@iki.fi>
Date: Sun, 27 Apr 2008 11:35:42 +0300

> I understand your concern. It is pretty easy break routing cache with
> some seemingly unrelated changes. I tried to think about possible sid=
e
> effects, but concluded that this should be safe. Then again, I don't
> know all the tiny details and unusual scenarios. But I have been runn=
ing
> a 2.6.23 kernel with (backported) patch on a production machine (rout=
er
> connected to two ISPs, internal subnet and also having multiple gre
> tunnels), so far I have not encountered any problems.

I thought more about your patch and it should be OK.

I've applied it, thanks a lot.
