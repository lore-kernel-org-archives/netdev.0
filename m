From: David Miller <davem@davemloft.net>
Subject: Re: TCP connection stops after high load.
Date: Mon, 16 Apr 2007 12:15:58 -0700 (PDT)
Message-ID: <20070416.121558.48807497.davem@davemloft.net>
References: <7e63f56c0704150849r5b019962v296b4266021a6fe1@mail.gmail.com>
	<4623BB7B.3010705@psc.edu>
	<7e63f56c0704161151p405c4597x5fbac6021b635d84@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jheffner@psc.edu, netdev@vger.kernel.org, greearb@candelatech.com
To: coroberti@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49166
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753370AbXDPTP5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Apr 2007 15:15:57 -0400
In-Reply-To: <7e63f56c0704161151p405c4597x5fbac6021b635d84@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Robert Iakobashvili" <coroberti@gmail.com>
Date: Mon, 16 Apr 2007 20:51:54 +0200

> > Commit: 53cdcc04c1e85d4e423b2822b66149b6f2e52c2c
> > Author: John Heffner <jheffner@psc.edu> Fri, 16 Mar 2007 15:04:03 -0700
> >
> >      [TCP]: Fix tcp_mem[] initialization.
> >      Change tcp_mem initialization function.  The fraction of total memory
> >      is now a continuous function of memory size, and independent of page
> >      size.
> 
> 
> Kernels 2.6.19 and 2.6.20 series are effectively broken right now.
> Don't you wish to patch them?

Can you verify that this patch actually fixes your problem?
