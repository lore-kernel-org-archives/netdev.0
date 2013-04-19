From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [RFC 1/2] netmap: infrastructure (in staging)
Date: Fri, 19 Apr 2013 12:45:37 -0700
Message-ID: <20130419194537.GA1633@kroah.com>
References: <20130419120651.4e646976@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:61475 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753519Ab3DSTpk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 15:45:40 -0400
Received: by mail-pd0-f181.google.com with SMTP id y10so2384205pdj.26
        for <netdev@vger.kernel.org>; Fri, 19 Apr 2013 12:45:39 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20130419120651.4e646976@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 19, 2013 at 12:06:51PM -0700, Stephen Hemminger wrote:
> Netmap is a framework for packet generation and capture from user
> space. It allows for efficient packet handling (up to line rate on
> 10Gb) with minimum system load.  For more info see:
> 	http://info.iet.unipi.it/~luigi/netmap/
> 
> This version is based on the latest version from Luigi Rizzo. It has
> been modified to live to work with current net-next kernel. It still
> has all the BSD ugliness, and that is why it needs to spend some time
> in the staging penalty box.
> 
> It builds and loads, but definitely needs more work.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumger.org>
> 
> ---
> Patch is against net-next
> 
>  drivers/staging/Kconfig              |    2 
>  drivers/staging/Makefile             |    1 
>  drivers/staging/netmap/Kconfig       |   16 
>  drivers/staging/netmap/Makefile      |    2 
>  drivers/staging/netmap/README        |  127 +
>  drivers/staging/netmap/TODO          |   16 
>  drivers/staging/netmap/netmap.c      | 2514 +++++++++++++++++++++++++++++++++++
>  drivers/staging/netmap/netmap_mem2.c |  974 +++++++++++++
>  include/netmap/bsd_glue.h            |  263 +++
>  include/netmap/netmap_kern.h         |  474 ++++++
>  include/uapi/Kbuild                  |    1 
>  include/uapi/linux/if.h              |    1 
>  include/uapi/netmap/Kbuild           |    3 
>  include/uapi/netmap/netmap.h         |  289 ++++
>  include/uapi/netmap/netmap_user.h    |   95 +
>  15 files changed, 4778 insertions(+)

I have no objection for this to go into staging.  If you want it to go
through the net-next tree, feel free to add my ack:

Acked-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

Otherwise, I'll be glad to take it through the staging-next tree.

thanks,

greg k-h
