From: Dave Jones <davej@redhat.com>
Subject: Re: [PATCH 1/2] 8139too: Make PIO/MMIO a modparam
Date: Thu, 29 May 2008 14:41:06 -0400
Message-ID: <20080529184106.GB24408@redhat.com>
References: <20080429171403.GA21035@redhat.com> <48177905.4000409@garzik.org> <20080429215626.GC2859@redhat.com> <48179B56.7000606@garzik.org> <20080429153240.7200e1a3.akpm@linux-foundation.org> <4818546C.4060703@garzik.org> <20080529150752.GB8247@redhat.com> <483EF385.3000103@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:58164 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752861AbYE2Ss3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 May 2008 14:48:29 -0400
Content-Disposition: inline
In-Reply-To: <483EF385.3000103@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 29, 2008 at 02:18:45PM -0400, Jeff Garzik wrote:
 > Dave Jones wrote:
 > > Make PIO/MMIO a runtime thing via a module parameter.
 > > This is needed to support devices that only work with PIO
 > > without penalising devices that work fine with MMIO in
 > > distro kernels.
 > > 
 > > Signed-off-by: Dave Jones <davej@redhat.com>
 > 
 > two comments:
 > 
 > 1) should use pci_iomap() for both PIO and MMIO
 > 
 > 2) modparam should be "use_io" mirroring existing drivers

Ok, I'll take a stab at those later today (and also your comment
from the other mail).

One other thing: I wasn't sure about my changes to rtl8139_get_regs
and rtl8139_get_regs_len.  Is what I did there safe?
Obviously actually implementing support for PIO reg dumping would
be better, but I think that's beyond the scope of what I'm trying
to do for now.

	Dave

-- 
http://www.codemonkey.org.uk
