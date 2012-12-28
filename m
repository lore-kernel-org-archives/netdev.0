From: Eric Wong <normalperson@yhbt.net>
Subject: Re: ppoll() stuck on POLLIN while TCP peer is sending
Date: Fri, 28 Dec 2012 07:06:52 +0000
Message-ID: <20121228070652.GA6292@dcvr.yhbt.net>
References: <20121228014503.GA5017@dcvr.yhbt.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andreas Voellmy <andreas.voellmy@yale.edu>,
	viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org,
	"Junchang(Jason) Wang" <junchang.wang@yale.edu>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dcvr.yhbt.net ([64.71.152.64]:52762 "EHLO dcvr.yhbt.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750964Ab2L1HGw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Dec 2012 02:06:52 -0500
Content-Disposition: inline
In-Reply-To: <20121228014503.GA5017@dcvr.yhbt.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Wong <normalperson@yhbt.net> wrote:
> I'm finding ppoll() unexpectedly stuck when waiting for POLLIN on a
> local TCP socket.  The isolated code below can reproduces the issue
> after many minutes (<1 hour).  It might be easier to reproduce on
> a busy system while disk I/O is happening.

Ugh, I can't seem to reproduce this anymore...  Will try something
else tomorrow.
