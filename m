From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH v2] Re: WAN: new PPP code for generic HDLC
Date: Tue, 22 Apr 2008 21:06:12 +0200
Message-ID: <m33apdyajf.fsf@maximus.localdomain>
References: <20080412115950.1cbb9cfa@core>
	<m33apqomgf.fsf@maximus.localdomain>
	<m33apjp32f.fsf@maximus.localdomain>
	<20080418.153256.253949503.davem@davemloft.net>
	<m3ve2b9qe8.fsf@maximus.localdomain> <480CEB7D.8070702@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, alan@lxorguk.ukuu.org.uk,
	akpm@linux-foundation.org, jeff@garzik.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ZSM1387.piap.pl ([195.187.100.11]:41779 "EHLO khc.piap.pl"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754393AbYDVTGP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Apr 2008 15:06:15 -0400
In-Reply-To: <480CEB7D.8070702@katalix.com> (James Chapman's message of "Mon\, 21 Apr 2008 20\:31\:09 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

James Chapman <jchapman@katalix.com> writes:

> Generic ppp isn't specialized at all, and it isn't limited to async
> serial devices. PPPoE, PPPoATM and L2TP use it.

Perhaps I should write "dial-up" and other non-fixed connections.

It's complex, I think kernel interface to generic HDLC would mean more
code than PPP implementation required for fixed lines.
Additional requirement - userspace daemon with additional plugin - may
not be the best thing for fixed lines either.

That would break backward compatibility, too.

Personally I think it could be acceptable but it's not for me to
decide.
-- 
Krzysztof Halasa
