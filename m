From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] PHYLIB: Spinlock fixes for softirqs
Date: Fri, 28 Sep 2007 22:40:55 -0700
Message-ID: <20070928224055.4415e47e.akpm@linux-foundation.org>
References: <Pine.LNX.4.64N.0709181532190.9650@blysk.ds.pg.gda.pl>
	<46FDE348.3010801@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Maciej W. Rozycki" <macro@linux-mips.org>,
	Andy Fleming <afleming@freescale.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:33320 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752702AbXI2Flv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Sep 2007 01:41:51 -0400
In-Reply-To: <46FDE348.3010801@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 29 Sep 2007 01:31:52 -0400 Jeff Garzik <jgarzik@pobox.com> wrote:

> doesn't Andrew have a version of these patches that move the useful 
> patch text into the area where it will get copied into the permanent 
> kernel changelog?
> 
> also, your PHYLIB patches give no notion at all of proper patch order.
> 

Andrew has patches coming out of his ears.  umm....

Applying order:

phylib-spinlock-fixes-for-softirqs.patch
phylib-irq-event-workqueue-handling-fixes.patch
phylib-fix-an-interrupt-loop-potential-when-halting.patch

ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.23-rc8/2.6.23-rc8-mm2/broken-out/phylib-spinlock-fixes-for-softirqs.patch
ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.23-rc8/2.6.23-rc8-mm2/broken-out/phylib-irq-event-workqueue-handling-fixes.patch
ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.23-rc8/2.6.23-rc8-mm2/broken-out/phylib-fix-an-interrupt-loop-potential-when-halting.patch

Let me unload some netdev patches at you...
