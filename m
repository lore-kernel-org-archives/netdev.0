From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 0/10] DMA-API debugging facility
Date: Fri, 21 Nov 2008 18:18:02 +0100
Message-ID: <20081121171802.GK733@elte.hu>
References: <1227284770-19215-1-git-send-email-joerg.roedel@amd.com> <1227286492.4901.208.camel@macbook.infradead.org> <20081121165722.GD1386@amd.com> <1227287215.4901.213.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joerg Roedel <joerg.roedel@amd.com>,
	Ingo Molnar <mingo@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>, netdev@vger.kernel.org,
	iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:49510 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752429AbYKURSb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Nov 2008 12:18:31 -0500
Content-Disposition: inline
In-Reply-To: <1227287215.4901.213.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* David Woodhouse <dwmw2@infradead.org> wrote:

> On Fri, 2008-11-21 at 17:57 +0100, Joerg Roedel wrote:
> > Yes, in principle we could move most of it to generic code. There is
> > nothing architecture specific in it.
> > Anybody who prefers this to be arch/x86 before moving it to lib/?
> 
> I think it's better to start off with a generic version, and test it 
> on more than one architecture before feeding it upstream. That way, 
> you know you aren't going to have to go back to the drawing board 
> with it.

Joerg, i'd suggest to make the generic conceptual bits generic, and 
add an HAVE_DMA_DEBUG_SUPPORT Kconfig bool flag to every architecture 
that enables it. It needs active changes to every architecture that 
supports this facility.

	Ingo
