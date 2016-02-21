From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] jme: remove the jme driver as it is no longer
 maintained
Date: Sat, 20 Feb 2016 19:16:59 -0500 (EST)
Message-ID: <20160220.191659.1399118945067159430.davem@davemloft.net>
References: <1456003203-10863-1-git-send-email-diego.viola@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	cooldavid@cooldavid.org
To: diego.viola@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55745 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753207AbcBUARF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Feb 2016 19:17:05 -0500
In-Reply-To: <1456003203-10863-1-git-send-email-diego.viola@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Sorry, this is not how things work.

You can suggest marking the driver unmaintained in MAINTAINERS if the
listed developer has been unresponsive for a very long time.

But removing the driver altogether is not prudent at all.

Just because it doesn't work %100 the way you like, and nobody
has worked on fixing your specific problems, isn't a reason to
remove an entire driver _nor_ move it to -staging.

In fact, this driver is quite cleanly written, follows all of the
various coding style rules we have, and uses the vast majority of the
kernel APIs properly.

And those are the criteria for having something in staging, not that
it has bugs.

In fact it is so cleanly written, that you should be able to read it
and figure out what the suspend/resume problem might be.  These are
exactly the kind of drivers we want to keep in the tree.

I'm sorry that your bugs didn't get fixed, but your response to that
happening is not reasonable at all.
