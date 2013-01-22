From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH net-next] neigh: Keep neighbour cache entries if number
 of them is small enough.
Date: Wed, 23 Jan 2013 00:12:35 +0900
Message-ID: <50FEAC63.6000904@linux-ipv6.org>
References: <50FEAB99.5060408@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:51759 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753227Ab3AVPMh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 10:12:37 -0500
In-Reply-To: <50FEAB99.5060408@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

YOSHIFUJI Hideaki wrote:
> Since we have removed NCE (Neighbour Cache Entry) reference from
> routing entries, the only refcnt holders of an NCE are timer (if run)
> and the entry's owner table.  As a result, neigh_periodic_timer()

Oops, I should say neigh_periodic_work()...

--yoshfuji
