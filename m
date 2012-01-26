From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: explicitly add jump_label.h header to sock.h
Date: Thu, 26 Jan 2012 17:28:37 -0500 (EST)
Message-ID: <20120126.172837.2167915547235168983.davem@davemloft.net>
References: <1327615768-13709-1-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: geert@linux-m68k.org, netdev@vger.kernel.org, sfr@canb.auug.org.au
To: glommer@parallels.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35377 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752361Ab2AZWbt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2012 17:31:49 -0500
In-Reply-To: <1327615768-13709-1-git-send-email-glommer@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Glauber Costa <glommer@parallels.com>
Date: Fri, 27 Jan 2012 02:09:28 +0400

> Commit 36a1211970193ce215de50ed1e4e1272bc814df1 removed linux/module.h
> include statement from one of the headers that end up in net/sock.h.
> It was providing us with static_branch() definition implicitly, so
> after its removal the build got broken.
> 
> To fix this, and avoid having this happening in the future,
> let me do the right thing and include linux/jump_label.h
> explicitly in sock.h.
> 
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> Reported-by: Randy Dunlap <rdunlap@xenotime.net>

Applied, thanks.
