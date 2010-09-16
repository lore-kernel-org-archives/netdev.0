From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: Remaining BKL users, what to do
Date: Thu, 16 Sep 2010 16:07:59 +0100
Message-ID: <20100916160759.4411786c@lxorguk.ukuu.org.uk>
References: <201009161632.59210.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: codalist@TELEMANN.coda.cs.cmu.edu, autofs@linux.kernel.org,
	linux-media@vger.kernel.org, dri-devel@lists.freedesktop.org,
	Christoph Hellwig <hch@infradead.org>,
	Mikulas Patocka <mikulas@artax.karlin.mff.cuni.cz>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	Petr Vandrovec <vandrove@vc.cvut.cz>,
	Anders Larsen <al@alarsen.net>, Jan Kara <jack@suse.cz>,
	Evgeniy Dushistov <dushistov@mail.ru>,
	Ingo Molnar <mingo@elte.hu>, netdev@vger.kernel.org,
	Samuel Ortiz <samuel@sortiz.org>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	Andrew Hendry <andrew.hendry@gmail.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:46064 "EHLO
	www.etchedpixels.co.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754584Ab0IPOuv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Sep 2010 10:50:51 -0400
In-Reply-To: <201009161632.59210.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> net/appletalk:
> net/ipx/af_ipx.c:
> net/irda/af_irda.c:
> 	Can probably be saved from retirement in drivers/staging if the
> 	maintainers still care.

IPX and Appletalk both have active users. They also look fairly fixable
as the lock_kernel just maps to a stack private mutex, or in several
cases can simply be dropped - its just a push down legacy.

IRDA may well be a candidate for staging
