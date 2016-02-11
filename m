From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 0/7] Faster SO_REUSEPORT for TCP
Date: Thu, 11 Feb 2016 03:54:48 -0500 (EST)
Message-ID: <20160211.035448.1600254996189463191.davem@davemloft.net>
References: <1455123041-22638-1-git-send-email-kraigatgoog@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kraigatgoog@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49366 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932103AbcBKIyv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Feb 2016 03:54:51 -0500
In-Reply-To: <1455123041-22638-1-git-send-email-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Craig Gallek <kraigatgoog@gmail.com>
Date: Wed, 10 Feb 2016 11:50:34 -0500

> This patch series complements an earlier series (6a5ef90c58da)
> which added faster SO_REUSEPORT lookup for UDP sockets by
> extending the feature to TCP sockets.  It uses the same
> array-based data structure which allows for socket selection
> after finding the first listening socket that matches an incoming
> packet.  Prior to this feature, every socket in the reuseport
> group needed to be found and examined before a selection could be
> made.
> 
> With this series the SO_ATTACH_REUSEPORT_CBPF and
> SO_ATTACH_REUSEPORT_EBPF socket options now work for TCP sockets
> as well.  The test at the end of the series includes an example of
> how to use these options to select a reuseport socket based on the
> cpu core id handling the incoming packet.
> 
> There are several refactoring patches that precede the feature
> implementation.  Only the last two patches in this series
> should result in any behavioral changes.

Series applied, thanks Craig.
