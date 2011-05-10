From: Pekka Enberg <penberg@cs.helsinki.fi>
Subject: Re: [Bugme-new] [Bug 33502] New: Caught 64-bit read from uninitialized
 memory in __alloc_skb
Date: Tue, 10 May 2011 13:19:35 +0300
Message-ID: <4DC91137.4030109@cs.helsinki.fi>
References: <bug-33502-10286@https.bugzilla.kernel.org/>	 <1303181466.4152.39.camel@edumazet-laptop>	 <1303182557.4152.48.camel@edumazet-laptop>	 <1303183217.4152.49.camel@edumazet-laptop>	 <alpine.DEB.2.00.1104191210011.17888@router.home>	 <1303244270.2756.3.camel@edumazet-laptop> <4DAE7579.3020400@cs.helsinki.fi>	 <1303279470.2756.17.camel@edumazet-laptop>	 <1303285519.4dae8f0fdf9b1@imp.free.fr>  <4DAE901C.2090809@cs.helsinki.fi>	 <1303286998.3186.18.camel@edumazet-laptop>	 <1303290464.3186.32.camel@edumazet-laptop>	 <1303293765.3186.74.camel@edumazet-laptop>	 <alpine.DEB.2.00.1104200904440.8634@router.home>	 <1303309591.3186.84.camel@edumazet-laptop>	 <alpine.DEB.2.00.1104200942020.9266@router.home>	 <1303311687.3186.100.camel@edumazet-laptop>	 <alpine.DEB.2.00.1105092241390.6784@tiger>
 	 <alpine.DEB.2.00.1105091502260.26839@router.home>	 <1305016988.2614.6.camel@edumazet-laptop> <4DC90D7D.9030808@cs.helsinki.fi> <1305022632.2614.18.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Christoph Lameter <cl@linux.com>, casteyde.christian@free.fr,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Vegard Nossum <vegardno@ifi.uio.no>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:33380 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755728Ab1EJKTg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 06:19:36 -0400
In-Reply-To: <1305022632.2614.18.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/10/11 1:17 PM, Eric Dumazet wrote:
> Le mardi 10 mai 2011 =C3=A0 13:03 +0300, Pekka Enberg a =C3=A9crit :
>
>> Can't we fix the issue by putting kmemcheck_mark_initialized() to
>> set_freepointer()?
>
> This would solve kmemcheck problem, not DEBUG_PAGEALLOC

Oh, right. Christoph? We need to support DEBUG_PAGEALLOC with SLUB.
