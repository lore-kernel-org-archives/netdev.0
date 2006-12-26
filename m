From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/14] Spidernet DMA coalescing
Date: Tue, 26 Dec 2006 16:09:11 -0500
Message-ID: <45918F77.1010806@pobox.com>
References: <20061213210010.GR4329@austin.ibm.com> <20061213210659.GA1915@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, Christoph Hellwig <hch@infradead.org>,
	Ishizaki Kou <kou.ishizaki@toshiba.co.jp>,
	Jens Osterkamp <Jens.Osterkamp@gmx.de>,
	James K Lewis <jim@jklewis.com>,
	Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:41337 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932782AbWLZVJ3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Dec 2006 16:09:29 -0500
To: Linas Vepstas <linas@austin.ibm.com>
In-Reply-To: <20061213210659.GA1915@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linas Vepstas wrote:
> The current driver code performs 512 DMA mappings of a bunch of 
> 32-byte ring descriptor structures. This is silly, as they are 
> all in contiguous memory. This patch changes the code to 
> dma_map_coherent() each rx/tx ring as a whole.
> 
> Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
> Cc: James K Lewis <jklewis@us.ibm.com>
> Cc: Arnd Bergmann <arnd@arndb.de>

applied 1-13 of 14 to netdev-2.6.git#upstream


