From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH v2] Re: WAN: new PPP code for generic HDLC
Date: Tue, 25 Mar 2008 15:39:49 +0100
Message-ID: <m33aqedg0a.fsf@maximus.localdomain>
References: <m3prtzsszg.fsf@maximus.localdomain>
	<m3tzj92xq6.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:38628 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753774AbYCYOjv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Mar 2008 10:39:51 -0400
In-Reply-To: <m3tzj92xq6.fsf@maximus.localdomain> (Krzysztof Halasa's message of "Fri\, 14 Mar 2008 15\:20\:49 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I wrote:

> New synchronous PPP implementation for generic HDLC.

So are we leaving the generic-HDLC+PPP in broken state for 2.6.25,
aren't we?

If we do, perhaps a "|| BROKEN" in drivers/net/wan/Kconfig would make
sense? Any attempt to use it will cause kernel panic immediately (PPP
with generic HDLC only; drivers using syncppp.c directly are not
affected). I can make that trivial Kconfig patch of course.
-- 
Krzysztof Halasa
