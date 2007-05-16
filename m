From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH] Intel IXP4xx network drivers v.2 - Ethernet and HSS
Date: Wed, 16 May 2007 16:44:25 +0200
Message-ID: <m3vees96ba.fsf@maximus.localdomain>
References: <464034CF.20700@wpkg.org> <20070516071300.GB14222@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tomasz Chmielewski <mangoo@wpkg.org>, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	Michael Jones <mlj28@cam.ac.uk>
To: Christoph Hellwig <hch@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:36038 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756984AbXEPOo2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 May 2007 10:44:28 -0400
In-Reply-To: <20070516071300.GB14222@infradead.org> (Christoph Hellwig's message of "Wed, 16 May 2007 08:13:01 +0100")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Christoph Hellwig <hch@infradead.org> writes:

> Not even trying to support LE is a clear merge blocker.  Maybe Krzysztof
> can't actually test it himself, which is fine - but not even pretending
> to be endian clean is not what proper Linux drivers do.

The drivers can only work with IXP4xx CPU and that's not the typical
endianess problem cross-platform drivers sometimes have.

There is different functionality required with LE mode, unless some
other arch changes are implemented (which I'm now researching, if
I have some time of course).
-- 
Krzysztof Halasa
