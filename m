From: David Miller <davem@davemloft.net>
Subject: Re: bnx2 dirver's firmware images
Date: Tue, 18 Sep 2007 14:31:34 -0700 (PDT)
Message-ID: <20070918.143134.112198097.davem@davemloft.net>
References: <1190145951.9540.230.camel@dell>
	<20070918.122150.124083496.davem@davemloft.net>
	<20070918213025.GF10199@1wt.eu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, vda.linux@googlemail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: w@1wt.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41506
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753599AbXIRWLC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2007 18:11:02 -0400
In-Reply-To: <20070918213025.GF10199@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Willy Tarreau <w@1wt.eu>
Date: Tue, 18 Sep 2007 23:30:25 +0200

> On Tue, Sep 18, 2007 at 12:21:50PM -0700, David Miller wrote:
> > From: "Michael Chan" <mchan@broadcom.com>
> > Date: Tue, 18 Sep 2007 13:05:51 -0700
> > 
> > > The bnx2 firmware changes quite frequently.  A new driver quite often
> > > requires new firmware to work correctly.  Splitting them up makes things
> > > difficult for the user.
> > > 
> > > The firmware in tg3 is a lot more mature and I don't expect it to
> > > change.  I think tg3 is better suited for using request_firmware().
> > 
> > Like I said, I think neither should change and the driver should
> > be fully functional when built statically into the kernel.
> 
> Michael, doesn't a functional-yet-suboptimal firmware exist ? I mean,
> just the same principle as we all have kernels, boot CDs, statically
> built tools, etc... which run everywhere. If you have such a beast,
> maybe it would be a good start to have it in the kernel, and provide
> the users with the ability to upgrade the firmware once the system
> is able to do more complex things.
> 
> Just a thought...

So let's save 60K instead of 80K.

I mean, the entire discussion is just plain silly :)
