From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ucc_geth: use correct UCCE macros
Date: Thu, 08 Jan 2009 11:18:33 -0800 (PST)
Message-ID: <20090108.111833.163761985.davem@davemloft.net>
References: <1231359172-6119-1-git-send-email-timur@freescale.com>
	<ed82fe3e0901071217y44900869n7af2e99d6174fd45@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leoli@freescale.com,
	galak@kernel.crashing.org, linuxppc-dev@ozlabs.org
To: timur@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33800
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755622AbZAHTSc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2009 14:18:32 -0500
In-Reply-To: <ed82fe3e0901071217y44900869n7af2e99d6174fd45@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Timur Tabi" <timur@freescale.com>
Date: Wed, 7 Jan 2009 14:17:04 -0600

> On Wed, Jan 7, 2009 at 2:12 PM, Timur Tabi <timur@freescale.com> wrote:
> 
> > This patch will break ucc_geth.c if my other patch, "powerpc: add Ethernet
> > UPSMR definitions to QE library" isn't also applied.  That patch is currently
> > in Kumar's 'next' branch, so it will make 2.6.29-rc0.  Therefore, it should
> > be safe to apply this patch to 'net-next' today, with the understanding that
> > everything will be peachy once Linus pulls everyone's 2.6.29 branches.
> 
> David,
> 
> as I mentioned here, Kumar already has the pre-req patch in his 'next'
> branch (for 2.6.29), so if you apply this patch to your 'next',
> ucc_geth.c will break until Linus pulls from Kumar and you pull from
> Linus.  I think that's OK.

I think I'll wait for Kumar's stuff to hit Linus's tree, then
apply this patch.

The patch is safely stored in my inbox and patchwork so there
is no need to fear it getting lost :-)
