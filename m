From: Greg KH <greg@kroah.com>
Subject: Re: [RFC] Patch to option HSO driver to the kernel
Date: Tue, 15 Apr 2008 09:10:01 -0700
Message-ID: <20080415161001.GD9704@kroah.com>
References: <20080414213238.GB28833@kroah.com> <200804151555.06698.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Filip Aben <f.aben@option.com>,
	Paulius Zaleckas <paulius.zaleckas@teltonika.lt>,
	ajb@spheresystems.co.uk
To: Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:37191 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751434AbYDOQOs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2008 12:14:48 -0400
Content-Disposition: inline
In-Reply-To: <200804151555.06698.oliver@neukum.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 15, 2008 at 03:55:06PM +0200, Oliver Neukum wrote:
> Am Montag, 14. April 2008 23:32:39 schrieb Greg KH:
> > Hi all,
> > 
> > Here's a patch that I have cleaned up for context only from Option that
> > is a USB serial / network device all in one.
> > 
> > I'd like to see this go into 2.6.26, so any review comments by anyone
> > who wishes to review any portion of this would be greatly apprecited.
> 
> This patch removes a creative abuse of in_interrupt(). Locking
> is always done with a mutex now. No need for atomic operations.
> 
> Signed-off-by: Oliver Neukum <oneukum@suse.de>

Very nice, thanks for the change, applied.

greg k-h
