From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] depca: Fix section mismatch derived from
 depca_isa_probe()
Date: Mon, 03 Jan 2011 13:28:05 -0800 (PST)
Message-ID: <20110103.132805.241454856.davem@davemloft.net>
References: <1294089735-3031-1-git-send-email-sedat.dilek@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	sedat.dilek@gmail.com
To: sedat.dilek@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49705
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754895Ab1ACV1e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jan 2011 16:27:34 -0500
In-Reply-To: <1294089735-3031-1-git-send-email-sedat.dilek@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sedat Dilek <sedat.dilek@googlemail.com>
Date: Mon,  3 Jan 2011 22:22:15 +0100

> This fixes the following warning:
> 
> WARNING: drivers/net/depca.o(.data+0x0): Section mismatch in reference from the variable depca_isa_driver to the function .init.text:depca_isa_probe()
> The variable depca_isa_driver references
> the function __init depca_isa_probe()
> If the reference is valid then annotate the
> variable with __init* or __refdata (see linux/init.h) or name the variable:
> *_template, *_timer, *_sht, *_ops, *_probe, *_probe_one, *_console,
> 
> Tested with linux-next (next-20101231)
> 
> Signed-off-by: Sedat Dilek <sedat.dilek@gmail.com>

Applied.
