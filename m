From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 6/7] drivers/net/sfc/falcon.c: fix min() warnings
Date: Wed, 29 Oct 2008 14:35:40 -0700
Message-ID: <20081029143540.c4e24fb5.akpm@linux-foundation.org>
References: <200810292122.m9TLMHts020208@imap1.linux-foundation.org>
	<1225315744.3068.54.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:52452 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754149AbYJ2VgQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 17:36:16 -0400
In-Reply-To: <1225315744.3068.54.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 29 Oct 2008 21:29:04 +0000
Ben Hutchings <bhutchings@solarflare.com> wrote:

> On Wed, 2008-10-29 at 14:22 -0700, akpm@linux-foundation.org wrote:
> > From: Andrew Morton <akpm@linux-foundation.org>
> > 
> > drivers/net/sfc/falcon.c: In function 'falcon_spi_write_limit':
> > drivers/net/sfc/falcon.c:1679: warning: comparison of distinct pointer types lacks a cast
> > drivers/net/sfc/falcon.c: In function 'falcon_spi_read':
> > drivers/net/sfc/falcon.c:1720: warning: comparison of distinct pointer types lacks a cast
> 
> These were already fixed by 31b760202a0911384fa07796df9d1905e9e89a7f.

That patch worsened things.

> > Driver seems rather confused about types.  Try to help it.
> [...]
> 
> Maybe, but in order to fix that you'll need to revert
> 31b760202a0911384fa07796df9d1905e9e89a7f along with making these
> changes.

I have plenty of things to be going on with.
