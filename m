From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] net: add ability to clear stats via ethtool -
 e1000/pcnet32
Date: Thu, 29 May 2008 15:45:25 +0100
Message-ID: <20080529154525.3916c7b5@core>
References: <482DA5B6.1020606@sngx.net>
	<482DB46A.8020103@cosmosbay.com>
	<482EF192.4070707@sngx.net>
	<482F5113.5090703@cosmosbay.com>
	<482F610D.2080108@sngx.net>
	<20080518003104.GK28241@solarflare.com>
	<482FBA09.80201@sngx.net>
	<483E0AAE.2020107@sngx.net>
	<20080528221118.63da4092.akpm@linux-foundation.org>
	<483EA2D1.8050603@sngx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: James Cammarata <jimi@sngx.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:57351 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751751AbYE2PFE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 May 2008 11:05:04 -0400
In-Reply-To: <483EA2D1.8050603@sngx.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > Many of the kernel's accounting accumulators cannot be reset.  We
> > handle that in userspace tools by using subtraction.
> 
> I don't think that should preclude the ability to reset these, unless it is
> shown that it would break something very badly.

For one quite a few of the network cards keep the stats in hardware and
don't neccessarily have a way to reset them. In other cases there is a
mix of OS accumulated stats bulk updated by overflow events on the device
itself.

Its a lot of complexity, and changes all over the places for the sake of
a trivial userspace change. I would suggest you instead write a quick bit
of perl or python that fetches the stats and then updates every second
with the changes.

Alan
