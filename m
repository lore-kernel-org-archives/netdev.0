From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] tcp: Fix slowness in read /proc/net/tcp
Date: Mon, 07 Jun 2010 10:49:03 +0200
Message-ID: <87eigjgrcw.fsf@basil.nowhere.org>
References: <alpine.DEB.1.00.1006062020180.24064@pokey.mtv.corp.google.com>
	<1275895167.2545.8.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Herbert <therbert@google.com>, davem@davemloft.net,
	netdev@vger.kernel.org, Yakov Lerner <iler.ml@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:52707 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753363Ab0FGItF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jun 2010 04:49:05 -0400
In-Reply-To: <1275895167.2545.8.camel@edumazet-laptop> (Eric Dumazet's message of "Mon\, 07 Jun 2010 09\:19\:27 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:
>
> BTW, another problem of /proc/net/tcp is the buffer size used by netstat
> utility : 1024 bytes instead of PAGE_SIZE, making O(N^2) behavior even
> more palpable.

That would be easily fixable in netstat.

But I'm not sure net-tools is still maintained as a separate package,
afaik the standard procedure is to submit a patch to a big distribution
and the others take it from there.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.
