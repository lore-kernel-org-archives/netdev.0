From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: Add TCP_USER_TIMEOUT negative value check
Date: Fri, 27 Jul 2012 13:46:12 -0700 (PDT)
Message-ID: <20120727.134612.98239415160690955.davem@davemloft.net>
References: <1343379141-5516-1-git-send-email-liuhangbin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hkchu@google.com
To: liuhangbin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36691 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751314Ab2G0UqN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jul 2012 16:46:13 -0400
In-Reply-To: <1343379141-5516-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hangbin Liu <liuhangbin@gmail.com>
Date: Fri, 27 Jul 2012 16:52:21 +0800

> TCP_USER_TIMEOUT is a TCP level socket option that takes an unsigned int. But
> patch "tcp: Add TCP_USER_TIMEOUT socket option"(dca43c75) didn't check the negative
> values. If a user assign -1 to it, the socket will set successfully and wait
> for 4294967295 miliseconds. This patch add a negative value check to avoid
> this issue.
> 
> Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>

Applied.
