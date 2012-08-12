From: Domenico Andreoli <cavokz@gmail.com>
Subject: Re: [PATCH V3] CS89x0 : Use ioread16/iowrite16 on all platforms
Date: Sun, 12 Aug 2012 13:24:33 +0200
Message-ID: <20120812112433.GA31699@glitch>
References: <1337274702-19536-1-git-send-email-jaccon.bastiaansen@gmail.com>
 <20120517.190346.175685939436302276.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jaccon.bastiaansen@gmail.com, arnd@arndb.de,
	netdev@vger.kernel.org, s.hauer@pengutronix.de,
	romieu@fr.zoreil.com, joe@perches.com, gfm@funxed.com,
	festevam@gmail.com, linux-arm-kernel@lists.infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:62943 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751178Ab2HLLYF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Aug 2012 07:24:05 -0400
Received: by eaac11 with SMTP id c11so884643eaa.19
        for <netdev@vger.kernel.org>; Sun, 12 Aug 2012 04:24:03 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20120517.190346.175685939436302276.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 17, 2012 at 07:03:46PM -0400, David Miller wrote:
> From: Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>
> Date: Thu, 17 May 2012 19:11:42 +0200
> 
> > The use of the inw/outw functions by the cs89x0 platform driver
> > results in NULL pointer references on ARM platforms and
> > platforms that do not provide ISA-style programmed I/O accessors.
> > 
> > Using inw/outw also accesses the wrong address space on platforms
> > that have a PCI I/O space that is not identity-mapped into the
> > physical address space.
> > 
> > Signed-off-by: Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>
> 
> I could nit-pick more on this patch, but it's such a significant
> improvement I'm just going to apply this V3 as-is to net-next.

Is this going into v3.6 or v3.7?

cheers,
Domenico
