From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: modpost warning question
Date: Wed, 25 Jul 2007 02:49:14 -0500
Message-ID: <1409C32B-61A8-49D1-BF64-1CFAA5F8B93B@kernel.crashing.org>
References: <Pine.LNX.4.64.0707250210520.14366@blarg.am.freescale.net> <20070725072712.GB24093@uranus.ravnborg.org>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org,
	Andy Fleming <afleming@freescale.com>,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
To: Sam Ravnborg <sam@ravnborg.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:60945 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762019AbXGYHsf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jul 2007 03:48:35 -0400
In-Reply-To: <20070725072712.GB24093@uranus.ravnborg.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Jul 25, 2007, at 2:27 AM, Sam Ravnborg wrote:

> On Wed, Jul 25, 2007 at 02:14:12AM -0500, Kumar Gala wrote:
>> I'm seeing the following warning:
>>
>> WARNING: vmlinux.o(.init.text+0x1acdc): Section mismatch:  
>> reference to
>> .exit.text:gfar_mdio_exit (between 'gfar_init' and 'gfar_mdio_init')
>>
>> I don't understand why its not ok to access .exit.text  
>> from .init.text
>
> Several architectures discards .exit.text in the final linker
> script (arch/$(ARCH)/kernel/vmlinux.lds.S
>
> So any references to .exit.text will when a module is build-in result
> in a linker error because ld will flag it as an error when we  
> reference
> a symbol in a discarded section.
>
> For the popular architectures (i386,x86_64) we discard .exit.text at
> runtime so here we do not see the error from ld (sadly).

Fair point, wondering what we do with .exit on PPC, another thing for  
the list :)

- k
