From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: flow_dissector.c missing include
 linux/export.h
Date: Tue, 24 Jan 2012 16:03:07 -0500 (EST)
Message-ID: <20120124.160307.599402013484638485.davem@davemloft.net>
References: <CAP=VYLr-28ZSG7tURdGbp5nG4JdOMh_GZfv0HnCxpjv+GggMLA@mail.gmail.com>
	<20120124.155135.1784877918701583546.davem@davemloft.net>
	<CAP=VYLpGk5+626QT31-nUkSJjay6ZnY8APxLfD-MUkqCJMxYng@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, jdb@comx.dk, netdev@vger.kernel.org,
	sfr@canb.auug.org.au
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41959 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755919Ab2AXVFP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2012 16:05:15 -0500
In-Reply-To: <CAP=VYLpGk5+626QT31-nUkSJjay6ZnY8APxLfD-MUkqCJMxYng@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Tue, 24 Jan 2012 15:59:00 -0500

> I've reproduced it locally, and verified it as a fix, but only *after*
> I've deleted the module.h from netprio_cgroup.h
> 
> Doing builds to see what else (aside from the dsa/mv88e6xxx)
> shakes loose.  Hopefully that is it.  If so, I'll send a patch
> shortly to delete the module.h

Ok, I'll apply Jesper's patch to 'net' then.

Thanks.
