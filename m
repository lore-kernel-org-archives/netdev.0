From: Jamie Iles <jamie@jamieiles.com>
Subject: Re: [PATCHv3 4/9] macb: convert printk to netdev_ and friends
Date: Thu, 11 Aug 2011 10:01:47 +0100
Message-ID: <20110811090147.GD2732@pulham.picochip.com>
References: <1312881411-2376-1-git-send-email-jamie@jamieiles.com>
 <1312881411-2376-5-git-send-email-jamie@jamieiles.com>
 <1312921227.11924.35.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamie Iles <jamie@jamieiles.com>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, plagnioj@jcrosoft.com
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:51329 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753279Ab1HKJBy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2011 05:01:54 -0400
Received: by wwf5 with SMTP id 5so1827645wwf.1
        for <netdev@vger.kernel.org>; Thu, 11 Aug 2011 02:01:52 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1312921227.11924.35.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 09, 2011 at 01:20:27PM -0700, Joe Perches wrote:
> On Tue, 2011-08-09 at 10:16 +0100, Jamie Iles wrote:
> > macb is already using the dev_dbg() and friends helpers so use netdev_()
> > along with a pr_fmt() definition to make the printing a little cleaner.
> []
> > diff --git a/drivers/net/macb.c b/drivers/net/macb.c
> []
> > @@ -8,6 +8,7 @@
> []
> > +#define pr_fmt(fmt) "macb: " fmt
> 
> Hi Jamie.
> 
> Just trivia.
> 
> Please use #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt 
> instead.  There would be no output difference.
> 
> That'll make it easier to remove later when all of
> of these #defines pr_fmt that use just KBUILD_MODNAME
> can be removed.

I hadn't noticed KBUILD_MODNAME before, thanks for pointing that out 
Joe.  I'll update with this change.

Jamie
