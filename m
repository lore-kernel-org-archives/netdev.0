From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 0/10] DMA-API debugging facility
Date: Fri, 21 Nov 2008 18:45:51 +0100
Message-ID: <20081121174551.GC4336@elte.hu>
References: <1227284770-19215-1-git-send-email-joerg.roedel@amd.com> <1227286492.4901.208.camel@macbook.infradead.org> <20081121165722.GD1386@amd.com> <1227287215.4901.213.camel@macbook.infradead.org> <20081121171802.GK733@elte.hu> <20081121172046.GF1386@amd.com> <1227288269.4901.222.camel@macbook.infradead.org> <20081121172722.GG1386@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Woodhouse <dwmw2@infradead.org>,
	Ingo Molnar <mingo@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>, netdev@vger.kernel.org,
	iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org
To: Joerg Roedel <joerg.roedel@amd.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:56807 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755661AbYKURqY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Nov 2008 12:46:24 -0500
Content-Disposition: inline
In-Reply-To: <20081121172722.GG1386@amd.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Joerg Roedel <joerg.roedel@amd.com> wrote:

> On Fri, Nov 21, 2008 at 05:24:29PM +0000, David Woodhouse wrote:
> > On Fri, 2008-11-21 at 18:20 +0100, Joerg Roedel wrote:
> > > Ok, I will move the generic bits to lib/ and include/linux and let
> > > architectures decide if they want to use it.
> > 
> > Once you've done that, I'll try to hook it up on PowerPC to make 
> > sure it works there.
> 
> Ok, cool. Thanks

i'll give it a whirl on x86 once the allocation bug is resolved. x86 
testing will be the most interesting in practice, because most drivers 
there are developed with no dynamic DMA in mind. (many of the x86 
drivers were developed before IOMMUs were supported in Linux)

	Ingo
