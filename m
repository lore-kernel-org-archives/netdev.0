From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/7 net-2.6.26] [TIPC]: Add argument validation for
 shutdown()
Date: Tue, 04 Mar 2008 13:43:54 -0800 (PST)
Message-ID: <20080304.134354.42311642.davem@davemloft.net>
References: <1204665619-6345-1-git-send-email-allan.stephens@windriver.com>
	<1204665619-6345-3-git-send-email-allan.stephens@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: allan.stephens@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37825
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753993AbYCDVoB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 16:44:01 -0500
In-Reply-To: <1204665619-6345-3-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>
Date: Tue,  4 Mar 2008 16:20:14 -0500

> This patch validates that the "how" argument to shutdown()
> is SHUT_RDWR, since this is the only form that TIPC supports.
> 
> Signed-off-by: Allan Stephens <allan.stephens@windriver.com>

You really didn't generate this patch against the current
net-2.6.26 tree:

davem@sunset:~/src/GIT/net-2.6.26$ pcheck diff
+ git apply --check --whitespace=error-all diff
error: patch failed: net/tipc/socket.c:1432
error: net/tipc/socket.c: patch does not apply

The line numbers are all off.  Likely you generated this
against a net-2.6.26 tree from before the semaphore-->mutex
TIPC changeset went in, throwing all the line numbers
off.

I'm not looking at the rest of your patches, sorry.

