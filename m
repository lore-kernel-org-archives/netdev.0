From: David Miller <davem@davemloft.net>
Subject: Re: More prefetch fall-out
Date: Sun, 22 May 2011 20:39:55 -0400 (EDT)
Message-ID: <20110522.203955.566217644017018932.davem@davemloft.net>
References: <1306088626.12435.27.camel@edumazet-laptop>
	<BANLkTimQAhP17Hg6D84gtCO3nJ_SSsDAeg@mail.gmail.com>
	<BANLkTikyURmhfkgYNFc-KNvmQ8ndx_=m=Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: paul.gortmaker@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53531 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755803Ab1EWAkE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 May 2011 20:40:04 -0400
In-Reply-To: <BANLkTikyURmhfkgYNFc-KNvmQ8ndx_=m=Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@gmail.com>
Date: Sun, 22 May 2011 17:02:08 -0400

> I just did a cheezy script (embedded in the attached commit) that should
> help make the grunt work less annoying by doing a mechanical 1st pass
> on fixing the drivers/net ones.   Script is tested -- compile isn't (I'm not
> currently somewhere that I can do a yesconfig/compile without growing
> old waiting for it).  Feel free to use the script and scrap the commit, or
> whatever makes things easiest for people.

Looks good, thanks Paul.

I'll try to get it so we can remove the linux/prefetch.h thing
from skbuff.h
