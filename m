From: David Miller <davem@davemloft.net>
Subject: Re: [patch 04/11] net: configure out IGMP support
Date: Wed, 30 Jul 2008 14:45:21 -0700 (PDT)
Message-ID: <20080730.144521.200750150.davem@davemloft.net>
References: <200807301937.m6UJbafn012434@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, thomas.petazzoni@free-electrons.com,
	mpm@selenic.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36793
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752945AbYG3VpV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 17:45:21 -0400
In-Reply-To: <200807301937.m6UJbafn012434@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Wed, 30 Jul 2008 12:37:36 -0700

> From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
> 
> tAdd adds the CONFIG_IGMP option which allows to remove support for the
> Internet Group Management Protocol, used in multicast.  Multicast is not
> necessarly used by applications, particularly on embedded devices.  As
> this is a size-reduction option, it depends on CONFIG_EMBEDDED.  It allows
> to save ~10 kilobytes of kernel code/data:
> 
>    text	   data	    bss	    dec	    hex	filename
> 1718857	 143672	 221184	2083713	 1fcb81	vmlinux
> 1708838	 143640	 221184	2073662	 1fa43e	vmlinux.new
>  -10019     -32       0  -10051   -2743 +/-
> 
> This patch has been originally written by Matt Mackall <mpm@selenic.com>,
> and is part of the Linux Tiny project.
> 
> Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
> Cc: Matt Mackall <mpm@selenic.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

I'm not applying this.

This removes core parts of the BSD socket API from applications.
Like TCP and UDP, multicast capabilities are something applications
can always depend upon being available.

If you want a broken networking implementation, you have the source
code, so you can do it in your own tree.
