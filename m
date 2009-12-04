From: kapil dakhane <kdakhane@gmail.com>
Subject: Re: [PATCH] tcp: fix a timewait refcnt race
Date: Thu, 3 Dec 2009 19:20:21 -0800
Message-ID: <99d458640912031920n7e4e0f39o4c04e9c51b46efd@mail.gmail.com>
References: <99d458640911301802i4bde20f4wa314668d543e3170@mail.gmail.com>
	 <4B152F97.1090409@gmail.com>
	 <20091202.005937.177088443.davem@davemloft.net>
	 <4B163226.50801@gmail.com> <4B164293.7070804@gmail.com>
	 <20091202113213.GA18453@ioremap.net>
	 <99d458640912021118y42a6fe4bm7b742a2046ad7a3b@mail.gmail.com>
	 <99d458640912021843y21ad07a4j724003328da07e9@mail.gmail.com>
	 <4B17979D.4040301@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter@vger.kernel.org, Evgeniy Polyakov <zbr@ioremap.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f171.google.com ([209.85.223.171]:58056 "EHLO
	mail-iw0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754115AbZLDDUP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 22:20:15 -0500
In-Reply-To: <4B17979D.4040301@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric,

On Thu, Dec 3, 2009 at 2:49 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:

> I believe I found another timewait problem, I am not sure
> it is what makes your test fail, but we make progress :)
>
> I cooked a patch against last net-next-2.6 + my previous patch.
>
> (2nd take of [PATCH net-next-2.6] tcp: connect() race with timewait reuse)
>
> [PATCH net-next-2.6] tcp: fix a timewait refcnt race
>

I applied your changes are suggested above. It appears that the patch
successfully resolves the race condition it addressed. I managed to
push the system to 1.9 gbps, previously I could not push it beyond 1.6
gbps. Unfortunately, there appear to be more race conditions, as the
fault happened again when I attempted to push it to 2.3 gbps. This
time I did not get any error message in /var/log/messages, although
they appear on the console the same way as before.

Kapil
