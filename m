From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [patch 6/7] drivers/net/sfc/falcon.c: fix min() warnings
Date: Wed, 29 Oct 2008 21:29:04 +0000
Message-ID: <1225315744.3068.54.camel@achroite>
References: <200810292122.m9TLMHts020208@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:37786 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753715AbYJ2V3M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 17:29:12 -0400
In-Reply-To: <200810292122.m9TLMHts020208@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-10-29 at 14:22 -0700, akpm@linux-foundation.org wrote:
> From: Andrew Morton <akpm@linux-foundation.org>
> 
> drivers/net/sfc/falcon.c: In function 'falcon_spi_write_limit':
> drivers/net/sfc/falcon.c:1679: warning: comparison of distinct pointer types lacks a cast
> drivers/net/sfc/falcon.c: In function 'falcon_spi_read':
> drivers/net/sfc/falcon.c:1720: warning: comparison of distinct pointer types lacks a cast

These were already fixed by 31b760202a0911384fa07796df9d1905e9e89a7f.

> Driver seems rather confused about types.  Try to help it.
[...]

Maybe, but in order to fix that you'll need to revert
31b760202a0911384fa07796df9d1905e9e89a7f along with making these
changes.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

