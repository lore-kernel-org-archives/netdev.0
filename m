From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 04/11] net: configure out IGMP support
Date: Wed, 30 Jul 2008 14:51:36 -0700
Message-ID: <20080730145136.1c604b6a.akpm@linux-foundation.org>
References: <200807301937.m6UJbafn012434@imap1.linux-foundation.org>
	<20080730.144521.200750150.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, thomas.petazzoni@free-electrons.com,
	mpm@selenic.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:53151 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754068AbYG3Vv4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 17:51:56 -0400
In-Reply-To: <20080730.144521.200750150.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 30 Jul 2008 14:45:21 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: akpm@linux-foundation.org
> Date: Wed, 30 Jul 2008 12:37:36 -0700
> 
> > From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
> > 
> > tAdd adds the CONFIG_IGMP option which allows to remove support for the
> > Internet Group Management Protocol, used in multicast.  Multicast is not
> > necessarly used by applications, particularly on embedded devices.  As
> > this is a size-reduction option, it depends on CONFIG_EMBEDDED.  It allows
> > to save ~10 kilobytes of kernel code/data:
> > 
> >    text	   data	    bss	    dec	    hex	filename
> > 1718857	 143672	 221184	2083713	 1fcb81	vmlinux
> > 1708838	 143640	 221184	2073662	 1fa43e	vmlinux.new
> >  -10019     -32       0  -10051   -2743 +/-
> > 
> > This patch has been originally written by Matt Mackall <mpm@selenic.com>,
> > and is part of the Linux Tiny project.
> > 
> > Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
> > Cc: Matt Mackall <mpm@selenic.com>
> > Cc: "David S. Miller" <davem@davemloft.net>
> > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> 
> I'm not applying this.
> 
> This removes core parts of the BSD socket API from applications.
> Like TCP and UDP, multicast capabilities are something applications
> can always depend upon being available.

That's just a bogus argument.  Embedded device developers have 100%
control over 100% of the applications which run on their devices.  If
they know that their applications don't use multicast then those devices
won't use multicast.   Ever.

