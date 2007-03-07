From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [PATCH 1/2] pcnet32: only allocate init_block dma consistent
Date: Wed, 7 Mar 2007 19:22:28 +0000
Message-ID: <20070307192228.GA13273@linux-mips.org>
References: <20070306184523.GA23268@verizon.net> <20070307031011.GA4281@linux-mips.org> <f2b55d220703061939w731dfcc4t8e0ddcf238203bd@mail.gmail.com> <20070307042155.GA6495@linux-mips.org> <f2b55d220703070835n16fbb052ub80be3e3e6d326a3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Don Fry <pcnet32@verizon.net>, jgarzik@pobox.com,
	netdev@vger.kernel.org
To: "Michael K. Edwards" <medwards.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:33356 "EHLO
	ftp.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2992490AbXCGTYZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Mar 2007 14:24:25 -0500
Received: from localhost.localdomain ([127.0.0.1]:33764 "EHLO
	dl5rb.ham-radio-op.net") by ftp.linux-mips.org with ESMTP
	id S20021622AbXCGTYY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Mar 2007 19:24:24 +0000
Content-Disposition: inline
In-Reply-To: <f2b55d220703070835n16fbb052ub80be3e3e6d326a3@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 07, 2007 at 08:35:30AM -0800, Michael K. Edwards wrote:

> >Price question: why would this patch make a difference under VMware? :-)
> 
> Moving the struct pcnet32_private from the GFP_DMA32 init_block to the
> GFP_KERNEL netdev allocation may be a win even on systems where
> GFP_DMA32 is normally cached, because the private area will get read
> ahead into cache when the netdev is touched.

GFP_* flags have no influence on caching or prefetching.

  Ralf
