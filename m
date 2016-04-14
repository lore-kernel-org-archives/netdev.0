From: David Miller <davem@davemloft.net>
Subject: Re: [git pull] sock_recvmsg() redundant argument
Date: Thu, 14 Apr 2016 00:42:12 -0400 (EDT)
Message-ID: <20160414.004212.1362172610995340744.davem@davemloft.net>
References: <20160409200704.GE25498@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: viro@ZenIV.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34323 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750796AbcDNEmT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 00:42:19 -0400
In-Reply-To: <20160409200704.GE25498@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Al Viro <viro@ZenIV.linux.org.uk>
Date: Sat, 9 Apr 2016 21:07:05 +0100

> Preparation for a bunch of iov_iter stuff; I'm not sure if all of those should
> go via net-next (e.g. cifs stuff almost certainly doesn't, etc.), but this
> bit is common to all those series and it would be better off in your tree.
> sendmsg counterpart was "get rid of the size argument of sock_sendmsg()" and
> it went in more than a year ago; this one sat in my private queue since
> then.

Pulled, thanks Al.
