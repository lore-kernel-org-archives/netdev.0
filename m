From: Greg KH <gregkh@suse.de>
Subject: Re: Can we remove pci_find_device() yet?
Date: Thu, 7 Jan 2010 20:46:46 -0800
Message-ID: <20100108044646.GC6611@suse.de>
References: <20100108112236.462a3da2.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Karsten Keil <isdn@linux-pingi.de>,
	isdn4linux@listserv.isdn4linux.de
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:39023 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751618Ab0AHEzj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jan 2010 23:55:39 -0500
Content-Disposition: inline
In-Reply-To: <20100108112236.462a3da2.sfr@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 08, 2010 at 11:22:36AM +1100, Stephen Rothwell wrote:
> Hi all,
> 
> This interface has been deprecated since November 2006, so can something
> be done about the last users (I think only some ISDN drivers)?  Or should
> we just remove the interface and mark those drivers BROKEN (and maybe
> move them to staging)?

Ick, the "new" isdn drivers are still not merged that replace those
older ones?  I thought that happened a while ago.  Karsten, what are you
plans on dropping them?

I recommend putting them in staging if you want a way to get them out of
the kernel tree :)

thanks,

greg k-h
