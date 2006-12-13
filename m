From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 0/14]: Spidernet RX-side patches
Date: Wed, 13 Dec 2006 15:00:10 -0600
Message-ID: <20061213210010.GR4329@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org, jgarzik@pobox.com,
	Christoph Hellwig <hch@infradead.org>,
	Ishizaki Kou <kou.ishizaki@toshiba.co.jp>,
	Jens Osterkamp <Jens.Osterkamp@gmx.de>,
	James K Lewis <jim@jklewis.com>,
	Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:41477 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750896AbWLMVAU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Dec 2006 16:00:20 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id kBDL0Ctw003274
	for <netdev@vger.kernel.org>; Wed, 13 Dec 2006 16:00:12 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kBDL0CVU175020
	for <netdev@vger.kernel.org>; Wed, 13 Dec 2006 16:00:12 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kBDL0ASX021185
	for <netdev@vger.kernel.org>; Wed, 13 Dec 2006 16:00:11 -0500
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Andrew, 

Please apply; these patches obsolete/replace the series of 16 patches
I'd previously sent, by addressing problems raised by Christoph Hellwig
and Jeff Garzik. 

Most of te focus of this series of patches is to simplify the RX code
be removing extraneous flags, branches, arguments, etc. The first
few patches are the biggest: using dma_alloc_coherent for the rings,
and removing a bogus tasklet that does work that could be better done in
the poll loop. The rest are mostly cleanup.

--linas
