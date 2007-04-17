From: David Miller <davem@davemloft.net>
Subject: Re: TCP connection stops after high load.
Date: Tue, 17 Apr 2007 12:39:41 -0700 (PDT)
Message-ID: <20070417.123941.119226635.davem@davemloft.net>
References: <7e63f56c0704161151p405c4597x5fbac6021b635d84@mail.gmail.com>
	<20070416.121558.48807497.davem@davemloft.net>
	<7e63f56c0704170058m35d44a8ajfe5d97c4c7a8d87a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jheffner@psc.edu, netdev@vger.kernel.org, greearb@candelatech.com,
	moser.michael@gmail.com
To: coroberti@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37384
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1031159AbXDQTjj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2007 15:39:39 -0400
In-Reply-To: <7e63f56c0704170058m35d44a8ajfe5d97c4c7a8d87a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Robert Iakobashvili" <coroberti@gmail.com>
Date: Tue, 17 Apr 2007 10:58:04 +0300

> David,
> 
> On 4/16/07, David Miller <davem@davemloft.net> wrote:
> > > > Commit: 53cdcc04c1e85d4e423b2822b66149b6f2e52c2c
> > > > Author: John Heffner <jheffner@psc.edu> Fri, 16 Mar 2007 15:04:03 -0700
> > > >
> > > >      [TCP]: Fix tcp_mem[] initialization.
> > > >      Change tcp_mem initialization function.  The fraction of total memory
> > > >      is now a continuous function of memory size, and independent of page
> > > >      size.
> > >
> > >
> > > Kernels 2.6.19 and 2.6.20 series are effectively broken right now.
> > > Don't you wish to patch them?
> >
> > Can you verify that this patch actually fixes your problem?
> 
> Yes, it fixes.

Thanks, I will submit it to -stable branch.
