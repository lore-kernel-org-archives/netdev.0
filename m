From: Pekka Enberg <penberg@cs.helsinki.fi>
Subject: Re: [Bugme-new] [Bug 33502] New: Caught 64-bit read from uninitialized
 memory in __alloc_skb
Date: Wed, 20 Apr 2011 10:49:48 +0300
Message-ID: <4DAE901C.2090809@cs.helsinki.fi>
References: <bug-33502-10286@https.bugzilla.kernel.org/>  <20110418153852.153d3ed3.akpm@linux-foundation.org>  <1303181466.4152.39.camel@edumazet-laptop>  <1303182557.4152.48.camel@edumazet-laptop>  <1303183217.4152.49.camel@edumazet-laptop>  <alpine.DEB.2.00.1104191210011.17888@router.home>  <1303244270.2756.3.camel@edumazet-laptop> <4DAE7579.3020400@cs.helsinki.fi> <1303279470.2756.17.camel@edumazet-laptop> <1303285519.4dae8f0fdf9b1@imp.free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Christoph Lameter <cl@linux.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Vegard Nossum <vegardno@ifi.uio.no>
To: casteyde.christian@free.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:43723 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753858Ab1DTHtt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2011 03:49:49 -0400
In-Reply-To: <1303285519.4dae8f0fdf9b1@imp.free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/20/11 10:45 AM, casteyde.christian@free.fr wrote:
> Indeed I can reproduce each time I boot, however I didn't managed to apply the
> patch to test it on -rc3 (neither -rc4), only the first hunk passed.

That's odd. Eric?

> I simply boot on this laptop with kmemcheck activated to get the warning, with
> vanilla -rc3. I've also tested -rc4 yersterday (without the patch therefore),
> the warning was not the same (it's a bit later, I will post the dmesg output on
> bugzilla tonight).

That's expected. You're unlikely to see the problem in the exact same 
place across different kernel configs and versions.

			Pekka
