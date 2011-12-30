From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 1/1] via-rhine: Fix hanging with high CPU load on low-end broads.
Date: Fri, 30 Dec 2011 13:56:55 +0100
Message-ID: <20111230125655.GA32031@electric-eye.fr.zoreil.com>
References: <CACPM=kXOddA+T6vQPijR6sh8x5cMO=4baKGeKxEmMKG896Lz4g@mail.gmail.com> <20111229153902.GB21946@electric-eye.fr.zoreil.com> <20111229183902.GC21946@electric-eye.fr.zoreil.com> <20111229.170514.1766899380937848638.davem@davemloft.net> <CACPM=kV8NwYLAdODQHxYmJ21X0RmZ8KJT9szKdY2xa-DsesvQg@mail.gmail.com> <CACPM=kVfsXgFhKheevTS1pm7kCoezKO3M+102O=PRbXzxebxxg@mail.gmail.com> <20111229235312.GA27092@electric-eye.fr.zoreil.com> <CACPM=kXTqY1kVWrEMB-Z0Lqy6t+rXvMzixcSUy7fAz6g_ajV9g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	bhutchings@solarflare.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, rl@hellgate.ch
To: Bjarke Istrup Pedersen <gurligebis@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:33314 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752825Ab1L3NFm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Dec 2011 08:05:42 -0500
Content-Disposition: inline
In-Reply-To: <CACPM=kXTqY1kVWrEMB-Z0Lqy6t+rXvMzixcSUy7fAz6g_ajV9g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bjarke Istrup Pedersen <gurligebis@gentoo.org> :
[...]
> Sorry for asking a probably obvious question, but whats next to get it
> fixed and ready for inclusion?

It should be there for testing and deeper review within a pair of hours.
I ended up vandalizing most of the locking. From a testing viewpoint it
means some amount of work (not mine :o) ) to get a decent coverage.

Once it is known tested and reviewed - it may need a few iterations - it
can be formally submitted for inclusion.

-- 
Ueimor
