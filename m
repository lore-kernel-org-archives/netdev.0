From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [PATCH] Fix/Rewrite of the mipsnet driver
Date: Mon, 29 Oct 2007 00:25:17 +0000
Message-ID: <20071029002517.GB16913@linux-mips.org>
References: <20071028043846.GM29176@networkno.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-mips@linux-mips.org, netdev@vger.kernel.org
To: Thiemo Seufer <ths@networkno.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:60682 "EHLO
	ftp.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750749AbXJ1RCQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Oct 2007 13:02:16 -0400
Received: from localhost.localdomain ([127.0.0.1]:57264 "EHLO
	dl5rb.ham-radio-op.net") by ftp.linux-mips.org with ESMTP
	id S20023070AbXJ1RCP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Oct 2007 17:02:15 +0000
Content-Disposition: inline
In-Reply-To: <20071028043846.GM29176@networkno.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Oct 28, 2007 at 04:38:46AM +0000, Thiemo Seufer wrote:

> Hello All,
> 
> currently the mipsnet driver fails after transmitting a number of
> packages because SKBs are allocated but never freed. I fixed that
> and coudn't refrain from removing the most egregious warts.
> 
> - mipsnet.h folded into mipsnet.c, as it doesn't provide any
>   useful external interface.
> - Free SKB after transmission.
> - Call free_irq in mipsnet_close, to balance the request_irq in
>   mipsnet_open.
> - Removed duplicate read of rxDataCount.
> - Some identifiers are now less verbose.
> - Removed dead and/or unnecessarily complex code.
> - Code formatting fixes.
> 
> Tested on Qemu's mipssim emulation, with this patch it can boot a
> Debian NFSroot.

The patch does no longer apply to a recent tree, can you respin it?

  Ralf
