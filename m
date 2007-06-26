From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [NET] au1000_eth: Fix warnings.
Date: Tue, 26 Jun 2007 13:42:42 +0200
Message-ID: <20070626114242.GB14930@linux-mips.org>
References: <20070624135953.GA16754@linux-mips.org> <20070625160216.e9e29d7f.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:56064 "EHLO
	ftp.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752276AbXFZLmx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2007 07:42:53 -0400
Received: from localhost.localdomain ([127.0.0.1]:62160 "EHLO
	dl5rb.ham-radio-op.net") by ftp.linux-mips.org with ESMTP
	id S20022104AbXFZLmv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jun 2007 12:42:51 +0100
Content-Disposition: inline
In-Reply-To: <20070625160216.e9e29d7f.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 25, 2007 at 04:02:16PM -0700, Andrew Morton wrote:

> That's more than a warning fix.  On most platforms, dma_alloc_noncoherent()
> is a #define so the driver just won't link there.
> 
> <looks>
> 
> But the driver is mips-only, and MIPS uses a regular C function for
> dma_alloc_noncoherent(), so you got lucky.

Yep, the way this driver is being used (32-bit only) it happens to just
work.

> Still, I'd say this is for-2.6.22.

Yep.

  Ralf
