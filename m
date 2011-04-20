From: casteyde.christian@free.fr
Subject: Re: [Bugme-new] [Bug 33502] New: Caught 64-bit read from uninitialized memory in __alloc_skb
Date: Wed, 20 Apr 2011 09:45:19 +0200
Message-ID: <1303285519.4dae8f0fdf9b1@imp.free.fr>
References: <bug-33502-10286@https.bugzilla.kernel.org/>  <20110418153852.153d3ed3.akpm@linux-foundation.org>  <1303181466.4152.39.camel@edumazet-laptop>  <1303182557.4152.48.camel@edumazet-laptop>  <1303183217.4152.49.camel@edumazet-laptop>  <alpine.DEB.2.00.1104191210011.17888@router.home>  <1303244270.2756.3.camel@edumazet-laptop> <4DAE7579.3020400@cs.helsinki.fi> <1303279470.2756.17.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Pekka Enberg <penberg@cs.helsinki.fi>,
	Christoph Lameter <cl@linux.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, casteyde.christian@free.fr,
	Vegard Nossum <vegardno@ifi.uio.no>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpfb2-g21.free.fr ([212.27.42.10]:46062 "EHLO
	smtpfb2-g21.free.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751360Ab1DTHwG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2011 03:52:06 -0400
Received: from smtp2-g21.free.fr (smtp2-g21.free.fr [212.27.42.2])
	by smtpfb2-g21.free.fr (Postfix) with ESMTP id C8CAACA95BD
	for <netdev@vger.kernel.org>; Wed, 20 Apr 2011 09:46:02 +0200 (CEST)
In-Reply-To: <1303279470.2756.17.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Eric Dumazet <eric.dumazet@gmail.com>:


> > Looks good to me! Can we get someone to test it as well?
>
> I tested first patch, but was not able to trigger the fault anyway
> without it. I'll try a bit more today if time permits...
>
> It would be nice if Christian can reproduce the initial problem easily
> and give us the steps...
>
>
>
>

Indeed I can reproduce each time I boot, however I didn't managed to apply the
patch to test it on -rc3 (neither -rc4), only the first hunk passed.

I simply boot on this laptop with kmemcheck activated to get the warning, with
vanilla -rc3. I've also tested -rc4 yersterday (without the patch therefore),
the warning was not the same (it's a bit later, I will post the dmesg output on
bugzilla tonight).

For info, my laptop is single core if that matters, it is preemptible, with
slub, 64bits, on an old CPU (Athlon64 3000 pre- lahf in 64bits).
