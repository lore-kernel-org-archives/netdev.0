From: David Miller <davem@davemloft.net>
Subject: Re: [patch] Fix handling of overlength pathname in AF_UNIX sun_path
Date: Tue, 17 Apr 2012 22:36:14 -0400 (EDT)
Message-ID: <20120417.223614.629911246108750471.davem@davemloft.net>
References: <4F8D497F.8060601@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, penguin-kernel@i-love.sakura.ne.jp,
	linux-api@vger.kernel.org, yoshfuji@linux-ipv6.org,
	jengelh@medozas.de, w@1wt.eu, alan@lxorguk.ukuu.org.uk
To: mtk.manpages@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:32918 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751533Ab2DRCj4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2012 22:39:56 -0400
In-Reply-To: <4F8D497F.8060601@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Kerrisk <mtk.manpages@gmail.com>
Date: Tue, 17 Apr 2012 22:44:15 +1200

> 1. Changing the kernel behavior prevents userspace having 
>    to go through the sort of contortions described above
>    in order to handle the 108-non-NUL-bytes-in-sun_path case.

The problem with this logic is that it ignores every single Linux
system that exists right now.

You need to code this logic into your application unless you don't
want it to run properly on every Linux system that actually exists.

Sorry, we're not making this change.
