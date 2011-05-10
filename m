From: Christoph Lameter <cl@linux.com>
Subject: Re: [Bugme-new] [Bug 33502] New: Caught 64-bit read from uninitialized
 memory in __alloc_skb
Date: Tue, 10 May 2011 11:33:09 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1105101132230.2611@router.home>
References: <bug-33502-10286@https.bugzilla.kernel.org/>  <1303181466.4152.39.camel@edumazet-laptop>  <1303182557.4152.48.camel@edumazet-laptop>  <1303183217.4152.49.camel@edumazet-laptop>  <alpine.DEB.2.00.1104191210011.17888@router.home>
 <1303244270.2756.3.camel@edumazet-laptop> <4DC90D7D.9030808@cs.helsinki.fi> <1305022632.2614.18.camel@edumazet-laptop> <4DC91137.4030109@cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463811839-2087014141-1305045191=:2611"
Cc: Eric Dumazet <eric.dumazet@gmail.com>, casteyde.christian@free.fr,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Vegard Nossum <vegardno@ifi.uio.no>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp108.prem.mail.ac4.yahoo.com ([76.13.13.47]:20291 "HELO
	smtp108.prem.mail.ac4.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752451Ab1EJQdN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 12:33:13 -0400
In-Reply-To: <4DC91137.4030109@cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811839-2087014141-1305045191=:2611
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Tue, 10 May 2011, Pekka Enberg wrote:

> On 5/10/11 1:17 PM, Eric Dumazet wrote:
> > Le mardi 10 mai 2011 =C3=A0 13:03 +0300, Pekka Enberg a =C3=A9crit :
> >
> > > Can't we fix the issue by putting kmemcheck_mark_initialized() to
> > > set_freepointer()?
> >
> > This would solve kmemcheck problem, not DEBUG_PAGEALLOC
>
> Oh, right. Christoph? We need to support DEBUG_PAGEALLOC with SLUB.

Well back to the #ifdef then? Or has DEBUG_PAGEALLOC some override
mechanism that we can do a speculative memory access?

---1463811839-2087014141-1305045191=:2611--
