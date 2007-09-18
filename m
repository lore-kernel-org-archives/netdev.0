From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: bnx2 dirver's firmware images
Date: Tue, 18 Sep 2007 16:14:36 -0700
Message-ID: <1190157276.9540.242.camel@dell>
References: <1190145951.9540.230.camel@dell>
 <20070918.122150.124083496.davem@davemloft.net>
 <20070918213025.GF10199@1wt.eu>
 <20070918.143134.112198097.davem@davemloft.net>
 <20070918213736.GA31119@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, vda.linux@googlemail.com,
	linux-kernel@vger.kernel.org, "netdev" <netdev@vger.kernel.org>
To: "Willy Tarreau" <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2450 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752185AbXIRWQ4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Sep 2007 18:16:56 -0400
In-Reply-To: <20070918213736.GA31119@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-09-18 at 23:37 +0200, Willy Tarreau wrote:

> > > Michael, doesn't a functional-yet-suboptimal firmware exist ? I mean,
> > > just the same principle as we all have kernels, boot CDs, statically
> > > built tools, etc... which run everywhere. If you have such a beast,
> > > maybe it would be a good start to have it in the kernel, and provide
> > > the users with the ability to upgrade the firmware once the system
> > > is able to do more complex things.
> > > 
> > > Just a thought...
> > 
> > So let's save 60K instead of 80K.
> 
> That's not for this reason I said this. Michael said the firmware needs
> to be updated somewhat often. What I was wondering was if it was not
> possible to stick to a stable one (and hopefully small) so that the
> driver could require less frequent updates. Sorry if it's not the main
> point of the discussion, but I grepped on this :-)
> 

The bnx2 chip requires a lot of firmware to begin with, so it won't save
much space no matter what version is used in the kernel.  We update the
firmware to fix bugs and sometimes to add new features.  New features
often require matching changes in the driver.  For example, we're
planning to add S/G support for jumbo rx frames and this requires
changes in both driver and firmware.

It's possible to make the driver work with multiple firmware versions,
but that adds complexity to enable/disable certain features.  Testing
also becomes more difficult as it has to cover different combinations.


