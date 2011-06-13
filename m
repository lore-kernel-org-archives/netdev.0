From: Fernando Luis Vazquez Cao <fernando@oss.ntt.co.jp>
Subject: [PATCH 0/2] IGMP snooping: set mrouters_only flag properly
Date: Mon, 13 Jun 2011 11:59:55 +0900
Message-ID: <1307933995.2704.11.camel@nausicaa>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from serv2.oss.ntt.co.jp ([222.151.198.100]:41884 "EHLO
	serv2.oss.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752278Ab1FMC75 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jun 2011 22:59:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Herbert,

I am sending you a fix for a IGMP snooping bug that bit us when we tried
to deploy it in production. This bug has been present since day one in
the IGMP code and I think the fix deserves a backport to -stable
(>=2.6.34).

The reason I am sending you separate patches for IPv4 and IPv6 is that I
wanted to acknowledge Hayato Kakuta for his extensive testing of IPv4's
IGMP code.

Thanks,
Fernando

