From: Greg KH <greg@kroah.com>
Subject: Re: [1/6] 2.6.21-rc2: known regressions
Date: Sun, 4 Mar 2007 20:34:43 -0800
Message-ID: <20070305043443.GA29158@kroah.com>
References: <Pine.LNX.4.64.0702272105220.12485@woody.linux-foundation.org> <20070305015031.GF3441@stusta.de> <45EB961D.6030808@rtr.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Adrian Bunk <bunk@stusta.de>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Sid Boyce <g3vbv@blueyonder.co.uk>,
	Pavel Machek <pavel@ucw.cz>,
	Marcel Holtmann <marcel@holtmann.org>, linux-pm@lists.osdl.org,
	maxk@qualcomm.com, bluez-devel@lists.sourceforge.net,
	Matt Mackall <mpm@selenic.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	Albert Hopkins <kernel@marduk.letterboxes.org>,
	Ayaz Abdulla <aabdulla@nvidia.com>,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
To: Mark Lord <lkml@rtr.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kroah.org ([69.55.234.183]:44119 "EHLO perch.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752659AbXCEEuO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Mar 2007 23:50:14 -0500
Content-Disposition: inline
In-Reply-To: <45EB961D.6030808@rtr.ca>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Mar 04, 2007 at 11:01:33PM -0500, Mark Lord wrote:
> Adrian Bunk wrote:
> >
> >Subject    : Bluetooth RFComm locks up the machine  (device_move() related)
> >References : http://lkml.org/lkml/2007/3/4/64
> >Submitter  : Mark Lord <lkml@rtr.ca>
> >Caused-By  : Marcel Holtmann <marcel@holtmann.org>
> >             commit c1a3313698895d8ad4760f98642007bf236af2e8
> >Status     : unknown
> 
> A 2-line patch exists for fs/sysfs/dir.c to address this.
> Waiting on Greg to apply it or substitute something prettier.  ;)

I want to see if Marcel agrees with it, as he did the original patch in
that area.

thanks,

greg k-h
