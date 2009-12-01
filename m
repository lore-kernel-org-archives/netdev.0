From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] Update embedded copy of ethtool.h from kernel 2.6.30
Date: Tue, 01 Dec 2009 15:21:18 +0000
Message-ID: <1259680878.2831.3.camel@achroite.uk.solarflarecom.com>
References: <20091201151750.GG5694@axis.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
To: Jesper Nilsson <jesper.nilsson@axis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:18627 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752658AbZLAPVO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2009 10:21:14 -0500
In-Reply-To: <20091201151750.GG5694@axis.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-12-01 at 16:17 +0100, Jesper Nilsson wrote:
> Commit 0c09c1a49cc7b819b33566a49d9901f7cfdd6889 in the Linux kernel
> added a new field mdio_support inside the struct ethtool_cmd,
> changing the struct size for architectures that does not pad structs.
> (for example the CRIS architecture)

CRIS has no alignment requirements?!  Wow.  Sorry for changing the
structure, then.

> This size mismatch lead to the ethtool_cmd struct being written
> as 44 bytes in the kernel, but only 43 bytes allocated on stack,
> overwriting one byte in the stack frame.
> 
> Update the ethtool copy of the definition to match the 2.6.30 kernel.
[...]

This has already been done.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

