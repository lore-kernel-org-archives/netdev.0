From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 09/10] bnx2x depends on ZLIB_INFLATE
Date: Mon, 17 Dec 2007 20:18:14 -0500
Message-ID: <47671FD6.9090308@garzik.org>
References: <200712140003.lBE0306f025535@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Lee.Schermerhorn@hp.com,
	eliezert@broadcom.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:34181 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753174AbXLRBSR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Dec 2007 20:18:17 -0500
In-Reply-To: <200712140003.lBE0306f025535@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

akpm@linux-foundation.org wrote:
> From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
> 
> The bnx2x module depends on the zlib_inflate functions.  The build will
> fail if ZLIB_INFLATE has not been selected manually or by building another
> module that automatically selects it.
> 
> Modify BNX2X config option to 'select ZLIB_INFLATE' like BNX2
> and others.  This seems to fix it.
> 
> Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
> Acked-by: Eliezer Tamir <eliezert@broadcom.com>
> Cc: Jeff Garzik <jeff@garzik.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/Kconfig |    1 +
>  1 file changed, 1 insertion(+)

applied #upstream


