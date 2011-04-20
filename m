From: Pekka Enberg <penberg@cs.helsinki.fi>
Subject: Re: [Bugme-new] [Bug 33502] New: Caught 64-bit read from uninitialized
 memory in __alloc_skb
Date: Wed, 20 Apr 2011 11:21:30 +0300
Message-ID: <4DAE978A.9040900@cs.helsinki.fi>
References: <bug-33502-10286@https.bugzilla.kernel.org/>	 <20110418153852.153d3ed3.akpm@linux-foundation.org>	 <1303181466.4152.39.camel@edumazet-laptop>	 <1303182557.4152.48.camel@edumazet-laptop>	 <1303183217.4152.49.camel@edumazet-laptop>	 <alpine.DEB.2.00.1104191210011.17888@router.home>	 <1303244270.2756.3.camel@edumazet-laptop> <4DAE7579.3020400@cs.helsinki.fi>	 <1303279470.2756.17.camel@edumazet-laptop>	 <1303285519.4dae8f0fdf9b1@imp.free.fr>  <4DAE901C.2090809@cs.helsinki.fi> <1303286998.3186.18.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: casteyde.christian@free.fr, Christoph Lameter <cl@linux.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Vegard Nossum <vegardno@ifi.uio.no>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:57532 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750753Ab1DTIVc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2011 04:21:32 -0400
In-Reply-To: <1303286998.3186.18.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/20/11 11:09 AM, Eric Dumazet wrote:
> Le mercredi 20 avril 2011 =C3=A0 10:49 +0300, Pekka Enberg a =C3=A9cr=
it :
>> On 4/20/11 10:45 AM, casteyde.christian@free.fr wrote:
>>> Indeed I can reproduce each time I boot, however I didn't managed t=
o apply the
>>> patch to test it on -rc3 (neither -rc4), only the first hunk passed=
=2E
>>
>> That's odd. Eric?
>>
>
> I dont know, my patches were linux-2.6 based, and I pull tree very
> often ;)

Btw, the patch applies fine here on top of 2.6.39-rc4.
