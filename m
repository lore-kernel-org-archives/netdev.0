From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 33502] New: Caught 64-bit read from
 uninitialized memory in __alloc_skb
Date: Wed, 20 Apr 2011 21:55:00 +0200
Message-ID: <1303329300.2690.25.camel@edumazet-laptop>
References: <bug-33502-10286@https.bugzilla.kernel.org/>
	 <alpine.DEB.2.00.1104200942020.9266@router.home>
	 <1303311687.3186.100.camel@edumazet-laptop>
	 <201104202136.52568.casteyde.christian@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Vegard Nossum <vegardno@ifi.uio.no>
To: Christian Casteyde <casteyde.christian@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:40210 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752737Ab1DTTzE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2011 15:55:04 -0400
Received: by wya21 with SMTP id 21so896499wya.19
        for <netdev@vger.kernel.org>; Wed, 20 Apr 2011 12:55:03 -0700 (PDT)
In-Reply-To: <201104202136.52568.casteyde.christian@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 20 avril 2011 =C3=A0 21:36 +0200, Christian Casteyde a =C3=A9=
crit :

> I'm not sure it's the same problem anyway as I've said previously.
> I append my config file used to build this kernel.

This is not the same problem, and is a known false positive from skb
reallocation. (skb_reserve() doesnt mark memory as initialized)=20



