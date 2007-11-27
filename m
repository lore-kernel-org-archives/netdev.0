From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [PATCH] SGISEEQ: use cached memory access to make driver work
	on IP28
Date: Tue, 27 Nov 2007 16:32:57 +0000
Message-ID: <20071127163257.GB23642@linux-mips.org>
References: <20071126223934.84BE7C2B26@solo.franken.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-mips@linux-mips.org,
	jgarzik@pobox.com
To: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:43352 "EHLO
	ftp.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753570AbXK0QdQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2007 11:33:16 -0500
Received: from localhost.localdomain ([127.0.0.1]:10202 "EHLO
	dl5rb.ham-radio-op.net") by ftp.linux-mips.org with ESMTP
	id S20027488AbXK0QdN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Nov 2007 16:33:13 +0000
Content-Disposition: inline
In-Reply-To: <20071126223934.84BE7C2B26@solo.franken.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Nov 24, 2007 at 01:29:19PM +0100, Thomas Bogendoerfer wrote:

> Following patch is clearly 2.6.25 material and is needed to get SGI IP28
> machines supported.
> 
> Thomas.
> 
> SGI IP28 machines would need special treatment (enable adding addtional
> wait states) when accessing memory uncached. To avoid this pain I changed
> the driver to use only cached access to memory.
> 
> Signed-off-by: Thomas Bogendoerfer <tsbogend@alpha.franken.de>

IP28 is clearly a maximum weirdo beast.  Technically the patch looks fine
it's just a few stilistic issues such as there no reason for
DMA_SYNC_DESC_CPU and DMA_SYNC_DESC_DEV being macros so why not using
inlines.

Acked-by: Ralf Baechle <ralf@linux-mips.org>

  Ralf
