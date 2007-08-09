From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [patch] ipvs: force read of atomic_t in while loop
Date: Thu, 9 Aug 2007 15:36:59 +0200
Message-ID: <20070809133659.GA28532@one.firstfloor.org>
References: <20070808093300.GA14530@osiris.boeblingen.de.ibm.com> <46BA30DC.20207@redhat.com> <20070809001533.GA17798@one.firstfloor.org> <200708091435.18595.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, Chris Snook <csnook@redhat.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	schwidefsky@de.ibm.com, wensong@linux-vs.org, horms@verge.net.au,
	torvalds@osdl.org
To: Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:45881 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1765415AbXHINhC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2007 09:37:02 -0400
Content-Disposition: inline
In-Reply-To: <200708091435.18595.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Isn't it possible through some inline assembly trick
> that only a certain variable has to be reloaded?

A volatile cast does that already

-Andi

