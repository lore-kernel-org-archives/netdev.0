From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/3] inet_diag: validate byte code to prevent oops
 in inet_diag_bc_run()
Date: Sun, 09 Dec 2012 19:01:38 -0500 (EST)
Message-ID: <20121209.190138.1226210899759529416.davem@davemloft.net>
References: <1355031803-14547-1-git-send-email-ncardwell@google.com>
	<1355031803-14547-2-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49920 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753998Ab2LJABk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Dec 2012 19:01:40 -0500
In-Reply-To: <1355031803-14547-2-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Sun,  9 Dec 2012 00:43:22 -0500

> Add logic to validate INET_DIAG_BC_S_COND and INET_DIAG_BC_D_COND
> operations.
> 
> Previously we did not validate the inet_diag_hostcond, address family,
> address length, and prefix length. So a malicious user could make the
> kernel read beyond the end of the bytecode array by claiming to have a
> whole inet_diag_hostcond when the bytecode was not long enough to
> contain a whole inet_diag_hostcond of the given address family. Or
> they could make the kernel read up to about 27 bytes beyond the end of
> a connection address by passing a prefix length that exceeded the
> length of addresses of the given family.
> 
> Signed-off-by: Neal Cardwell <ncardwell@google.com>

Applied.
