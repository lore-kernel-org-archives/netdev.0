From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all architectures
Date: Thu, 9 Aug 2007 14:41:25 +0200
Message-ID: <200708091441.28511.arnd@arndb.de>
References: <20070809131423.GA9927@shell.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	torvalds@linux-foundation.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org, ak@suse.de, heiko.carstens@de.ibm.com,
	davem@davemloft.net, schwidefsky@de.ibm.com, wensong@linux-vs.org,
	horms@verge.net.au, wjiang@resilience.com, cfriesen@nortel.com,
	zlynx@acm.org, rpjday@mindspring.com, jesper.juhl@gmail.com
To: Chris Snook <csnook@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:51224 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762128AbXHIN4J convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2007 09:56:09 -0400
In-Reply-To: <20070809131423.GA9927@shell.boston.redhat.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 09 August 2007, Chris Snook wrote:
> This patchset makes the behavior of atomic_read uniform by removing t=
he
> volatile keyword from all atomic_t and atomic64_t definitions that cu=
rrently
> have it, and instead explicitly casts the variable as volatile in
> atomic_read(). =A0This leaves little room for creative optimization b=
y the
> compiler, and is in keeping with the principles behind "volatile cons=
idered
> harmful".
>=20

Just an idea: since all architectures already include asm-generic/atomi=
c.h,
why not move the definitions of atomic_t and atomic64_t, as well as any=
thing
that does not involve architecture specific inline assembly into the ge=
neric
header?

	Arnd <><
