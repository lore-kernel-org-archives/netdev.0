From: Christoph Hellwig <hch@infradead.org>
Subject: Re: sock_valbool_flag is required by VMware
Date: Sun, 2 Dec 2007 13:58:51 +0000
Message-ID: <20071202135851.GA1164@infradead.org>
References: <47508616.4030705@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pavel Emelyanov <xemul@openvz.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Jiri Slaby <jirislaby@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:36873 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754159AbXLBN6y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Dec 2007 08:58:54 -0500
Content-Disposition: inline
In-Reply-To: <47508616.4030705@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 30, 2007 at 10:52:22PM +0100, Jiri Slaby wrote:
> Hi,
> 
> this commit:
>     [NET]: Move sock_valbool_flag to socket.c
> 
>     The sock_valbool_flag() helper is used in setsockopt to
>     set or reset some flag on the sock. This helper is required
>     in the net/socket.c only, so move it there.
> 
>     Besides, patch two places in sys_setsockopt() that repeat
>     this helper functionality manually.
> 
>     Since this is not a bugfix, but a trivial cleanup, I
>     prepared this patch against net-2.6.25, but it also
>     applies (with a single offset) to the latest net-2.6.
> 
> breaks vmware module compilation, since it uses sock_valbool_flag(). Is this
> their business (and they should use sock_set_flag/sock_reset_flag) or should
> this be reverted?

It's their business, they should never have used it.

