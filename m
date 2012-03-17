From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next 33/34] dmfe: stop using net_device.{base_addr, irq} and convert to __iomem.
Date: Sat, 17 Mar 2012 12:31:47 +0100
Message-ID: <20120317113147.GB20532@electric-eye.fr.zoreil.com>
References: <cover.1331814082.git.romieu@fr.zoreil.com> <6fbe1c856415aff0b1cf507a4687fe94cb9a384b.1331814082.git.romieu@fr.zoreil.com> <CANEJEGuoaTP1Pjs1yzRkx2uoC6VW2UV2n0Wgspbc38d6qdRBrQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Grant Grundler <grundler@parisc-linux.org>
To: Grant Grundler <grantgrundler@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:56931 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756267Ab2CQLdh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Mar 2012 07:33:37 -0400
Content-Disposition: inline
In-Reply-To: <CANEJEGuoaTP1Pjs1yzRkx2uoC6VW2UV2n0Wgspbc38d6qdRBrQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Grant Grundler <grantgrundler@gmail.com> :
[...]
> is there any reason you didn't want to directly use iowrite/ioread routines?

I wanted to keep this patch small and easy to review. David suggested doing
the right thing from the start. I'll send an updated version.

> There is a semantic difference between outl and iowrite. Having
> "outl()" source but instead generate an MMIO transaction could lead to
> misunderstanding/bugs about posted MMIO writes. So I'd rather see a
> direct transition to iowrite and just ditch all the inb/outb stuff.

Ok.

> I'm still suffering from jetlag right now and am not able to review
> the rest of the patch now. I'll try to take a look at it tomorrow.

Thanks. No need to hurry until I send an update though.

-- 
Ueimor
