From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH] prevent SSB compilation on s390 part 2
Date: Wed, 1 Aug 2007 08:24:09 -0400
Message-ID: <20070801122409.GC5474@tuxdriver.com>
References: <20070731230932.a9459617.akpm@linux-foundation.org> <20070801093404.GA12124@osiris.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Michael Buesch <mb@bu3sch.de>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:2610 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762607AbXHAMgb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Aug 2007 08:36:31 -0400
Content-Disposition: inline
In-Reply-To: <20070801093404.GA12124@osiris.boeblingen.de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 01, 2007 at 11:34:04AM +0200, Heiko Carstens wrote:
> From: Heiko Carstens <heiko.carstens@de.ibm.com>
> 
> drivers/ssb/Kconfig has already a depends on HAS_IOMEM which should
> prevent SSB from being selected. But appearantly it looks like this
> doesn't matter at all if it gets selected from somewhere else.
> So add an explicit depends on HAS_IOMEM to the Broadcom driver to
> prevent selection on s390.
> 
> Cc: "John W. Linville" <linville@tuxdriver.com>
> Cc: Michael Buesch <mb@bu3sch.de>
> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
> Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>

Note to reviewers: this is only relevant to -mm and wireless-dev at
the moment, AFAIK...

John
-- 
John W. Linville
linville@tuxdriver.com
