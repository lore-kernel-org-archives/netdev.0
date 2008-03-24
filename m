From: Matti Aarnio <matti.aarnio@zmailer.org>
Subject: Re: O(n^2) or worse ? cat /proc/net/tcp
Date: Mon, 24 Mar 2008 05:33:29 +0200
Message-ID: <20080324033329.GM3700@mea-ext.zmailer.org>
References: <20080323224307.GL3700@mea-ext.zmailer.org> <20080323.162021.184196552.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from z2.cat.iki.fi ([212.16.98.133]:48797 "EHLO z2.cat.iki.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751084AbYCXDdd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Mar 2008 23:33:33 -0400
Received: (mea@mea-ext) by mail.zmailer.org id S3540613AbYCXDd3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2008 05:33:29 +0200
Content-Disposition: inline
In-Reply-To: <20080323.162021.184196552.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 23, 2008 at 04:20:21PM -0700, David Miller wrote:
> From: Matti Aarnio <matti.aarnio@zmailer.org>
> Date: Mon, 24 Mar 2008 00:43:07 +0200
> 
> > I have about 750 TCP socket on one multi-threaded server application, and 
> > about 250 on three single-threaded clients.
> > 
> > I did observe odd slowness at first with  "lsof -p .."  program, then at
> > "netstat -na".  Same slowdown happens with:  cat /proc/net/tcp
> > (that 'cat' took 25 seconds...)
> > 
> > Sure this is not earth shatterinly dangerous thing, rather a nuisance
> > when a monitoring application is not as fast as one would expect.
> 
> There have been some improvements in this area over the
> past few releases.
> 
> If you tell us what version you're running we can try to
> dig out the changes that matter.

Bleeding edgeish Fedora:

  2.6.25-0.90.rc3.git5.fc9 #1 SMP Tue Mar 4 20:19:33 EST 2008 x86_64 x86_64 x86_64 GNU/Linux

/Matti Aarnio
