From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] AFS/AF_RXRPC: Miscellaneous fixes
Date: Thu, 03 May 2007 03:11:49 -0700 (PDT)
Message-ID: <20070503.031149.51495514.davem@davemloft.net>
References: <20070501174747.19112.1985.stgit@warthog.cambridge.redhat.com>
	<20070501174752.19112.82814.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@osdl.org, akpm@osdl.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org,
	geert@linux-m68k.org
To: dhowells@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59095
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751965AbXECKLt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2007 06:11:49 -0400
In-Reply-To: <20070501174752.19112.82814.stgit@warthog.cambridge.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Howells <dhowells@redhat.com>
Date: Tue, 01 May 2007 18:47:52 +0100

> Make miscellaneous fixes to AFS and AF_RXRPC:
> 
>  (*) Make AF_RXRPC select KEYS rather than RXKAD or AFS_FS in Kconfig.
> 
>  (*) Don't use FS_BINARY_MOUNTDATA.
> 
>  (*) Remove a done 'TODO' item in a comemnt on afs_get_sb().
> 
>  (*) Don't pass a void * as the page pointer argument of kmap_atomic() as this
>      breaks on m68k.  Patch from Geert Uytterhoeven <geert@linux-m68k.org>.
> 
>  (*) Use match_*() functions rather than doing my own parsing.
> 
> Signed-off-by: David Howells <dhowells@redhat.com>

Applied.
