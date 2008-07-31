From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: using software TSO on non-TSO capable netdevices
Date: Thu, 31 Jul 2008 19:45:46 +0200
Message-ID: <20080731174546.GD31160@xi.wantstofly.org>
References: <20080730235004.GC21999@xi.wantstofly.org> <4891EFB0.4040003@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Ashish Karkare <akarkare@marvell.com>,
	Nicolas Pitre <nico@cam.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:32829 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754996AbYGaRpu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2008 13:45:50 -0400
Content-Disposition: inline
In-Reply-To: <4891EFB0.4040003@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 31, 2008 at 10:00:32AM -0700, Rick Jones wrote:

> >When using sendfile() to send a GiB worth of zeroes over a single TCP
> >connection to another host on a 100 Mb/s network, with a vanilla
> >2.6.27-rc1 kernel, this runs as expected at wire speed, taking the
> >following amount of CPU time per test:
> >
> >	sys     0m5.410s
> >	sys     0m5.380s
> >	sys     0m5.620s
> >	sys     0m5.360s
> 
> That's output from "time" run against your test program right?  Are 
> folks confident that will account for all the CPU time consumed on 
> behalf of that program?

No, but I wasn't drawing absolute conclusions, just comparing runs
without GSO with runs with GSO.  :-)
