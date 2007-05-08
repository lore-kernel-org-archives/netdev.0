From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH] Intel IXP4xx network drivers v.2 - Ethernet and HSS
Date: Tue, 08 May 2007 18:34:06 +0200
Message-ID: <m37irj6zr5.fsf@maximus.localdomain>
References: <464034CF.20700@wpkg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	Michael Jones <mlj28@cam.ac.uk>
To: Tomasz Chmielewski <mangoo@wpkg.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:39061 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S968402AbXEHQeI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 May 2007 12:34:08 -0400
In-Reply-To: <464034CF.20700@wpkg.org> (Tomasz Chmielewski's message of "Tue, 08 May 2007 10:29:03 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tomasz Chmielewski <mangoo@wpkg.org> writes:

> Krzysztof, why is LE not supported?

I'm not yet sure how to do it best.

The trivial way is really trivial, allocate a set of 1536-byte
buffers and make a swap+copy on RX and TX, but I want to
investigate the data-coherent approach first.

> Do you need access to ixp4xx that starts in LE mode?

No, I have a nice experimental machine so there is no problem
with that. I'd have to recompile my tools (GNU suite and rest
of the system) LE, but it's a simple thing, too.

I just want to have the functional drivers in the tree and
only then improve them. Doing all the work in a single step
is just impossible, the target moves way too fast (at least
for my limited time budget).
-- 
Krzysztof Halasa
