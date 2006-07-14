From: Ralf Baechle <ralf@linux-mips.org>
Subject: [SLHC 1/4] Cleanup SLHC configuration
Date: Fri, 14 Jul 2006 12:11:53 +0100
Message-ID: <20060714111153.GA15058@linux-mips.org>
References: <20060713110615.GA19816@linux-mips.org> <20060713.220718.10298012.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kkeil@suse.de, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:14004 "EHLO
	ftp.linux-mips.org") by vger.kernel.org with ESMTP id S1750775AbWGNLMA
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Jul 2006 07:12:00 -0400
Received: from localhost.localdomain ([127.0.0.1]:56267 "EHLO bacchus.dhis.org")
	by ftp.linux-mips.org with ESMTP id S8133779AbWGNLL5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jul 2006 12:11:57 +0100
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060713.220718.10298012.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 13, 2006 at 10:07:18PM -0700, David Miller wrote:

> Subject: Re: [SLHC 1/4] Cleanup SLHC configuration
> From:	David Miller <davem@davemloft.net>
> Content-Type: Text/Plain; charset=us-ascii
> 
> From: Ralf Baechle <ralf@linux-mips.org>
> Date: Thu, 13 Jul 2006 12:06:15 +0100
> 
> > Convert selection of serial line header compression to use CONFIG_SLHC
> > rather than makefile ifeq uglyness.  This makes it easier to select
> > the SLHC module from other code.
> > 
> > Signed-off-by: Ralf Baechle <ralf@linux-mips.org>
> 
> Something is missing here?
> 
> I don't see where in the makefiles that you've added
> the seemingly necessary:
> 
> obj-${CONFIG_SLHC} += slhc.o
> 
> line?  How does it get linked in now?

This was sent from a corrupt mailfolder - the last segment wasn't even
valid, was truncated after three lines.  Will repost in separate mail.

  Ralf
