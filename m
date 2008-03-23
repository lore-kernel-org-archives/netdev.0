From: Matti Aarnio <matti.aarnio@zmailer.org>
Subject: O(n^2) or worse ?   cat /proc/net/tcp
Date: Mon, 24 Mar 2008 00:43:07 +0200
Message-ID: <20080323224307.GL3700@mea-ext.zmailer.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from z2.cat.iki.fi ([212.16.98.133]:48959 "EHLO z2.cat.iki.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755929AbYCWWnM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Mar 2008 18:43:12 -0400
Received: (mea@mea-ext) by mail.zmailer.org id S3540613AbYCWWnH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2008 00:43:07 +0200
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have about 750 TCP socket on one multi-threaded server application, and 
about 250 on three single-threaded clients.

I did observe odd slowness at first with  "lsof -p .."  program, then at
"netstat -na".  Same slowdown happens with:  cat /proc/net/tcp
(that 'cat' took 25 seconds...)

Sure this is not earth shatterinly dangerous thing, rather a nuisance
when a monitoring application is not as fast as one would expect.


Application works fine, though.

  /Matti Aarnio
