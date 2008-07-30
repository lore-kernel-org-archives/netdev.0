From: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
Subject: Re: [patch nacked? 2/4] 3c59x: fix PCI resource management
Date: Thu, 31 Jul 2008 00:10:40 +0200
Message-ID: <20080730221040.GA29548@bayes.mathematik.tu-chemnitz.de>
References: <200807301940.m6UJel33012679@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org, sshtylyov@ru.mvista.com,
	jgarzik@pobox.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lana.hrz.tu-chemnitz.de ([134.109.132.3]:49653 "EHLO
	lana.hrz.tu-chemnitz.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752087AbYG3WKp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 18:10:45 -0400
Content-Disposition: inline
In-Reply-To: <200807301940.m6UJel33012679@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 30, 2008 at 12:40:47PM -0700, akpm@linux-foundation.org wrote:
> From: Sergei Shtylyov <sshtylyov@ru.mvista.com>
> 
> The driver wrongly claimed I/O ports at an address returned by pci_iomap()
> -- even if it was passed an MMIO address.  Fix this by claiming/releasing
> all PCI resources in the PCI driver probe/remove handlers instead and get
> rid of the must_free_region flag weirdness (why would Cardbus claim
> anything for us?).
> 
> Also, the remove handler was trying to talk to the chip after having
> disabled its address decoders (at least on x86) -- fix this and get rid of
> useless VORTEX_PCI() calls.
> 
> While at it, fix some cases of the overly indented code...
> 

The compile error of that patch should be fixed by git commit
0da0ead90122578ef6e4afba9ba4bcd3455fd8e8 at least.

I'll take this one and look at it.

Steffen
