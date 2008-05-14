From: Greg KH <greg@kroah.com>
Subject: Re: [patch 2/8] net: hso driver uses rfkill functions
Date: Wed, 14 May 2008 16:38:15 -0700
Message-ID: <20080514233815.GB19768@kroah.com>
References: <200805142319.m4ENJfqo026554@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	randy.dunlap@oracle.com, jeff@garzik.org,
	paulius.zaleckas@teltonika.lt
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:34950 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754452AbYENXiy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2008 19:38:54 -0400
Content-Disposition: inline
In-Reply-To: <200805142319.m4ENJfqo026554@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 14, 2008 at 04:19:41PM -0700, akpm@linux-foundation.org wrote:
> From: Randy Dunlap <randy.dunlap@oracle.com>
> 
> hso driver uses rfkill functions so should either depend on RFKILL
> or select it.  This patch uses depends on RFKILL.
> 
> drivers/built-in.o: In function `hso_disconnect':
> hso.c:(.text+0x868c9): undefined reference to `rfkill_unregister'
> drivers/built-in.o: In function `hso_probe':
> hso.c:(.text+0x88226): undefined reference to `rfkill_allocate'
> hso.c:(.text+0x8829e): undefined reference to `rfkill_register'
> hso.c:(.text+0x8860f): undefined reference to `rfkill_free'
> make[1]: *** [.tmp_vmlinux1] Error 1
> 
> On Mon, 12 May 2008 11:29:20 +0300
> Paulius Zaleckas <paulius.zaleckas@teltonika.lt> wrote:
> 
> > AFAIK Greg has (or he is going to do it) patch for rfkill so no more 
> > depends or select RFKILL will be needed.

This is already merged into my tree, in the version that I sent to Jeff.

So you can safely drop it.

thanks,

greg k-h
