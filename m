From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] scm: Only support SCM_RIGHTS on unix domain sockets.
Date: Sun, 28 Feb 2010 18:49:25 -0800 (PST)
Message-ID: <20100228.184925.192660876.davem@davemloft.net>
References: <m1eik5d2t7.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40149
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752363Ab0CACtI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Feb 2010 21:49:08 -0500
In-Reply-To: <m1eik5d2t7.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Sun, 28 Feb 2010 03:20:36 -0800

> We use scm_send and scm_recv on both unix domain and
> netlink sockets, but only unix domain sockets support
> everything required for file descriptor passing,
> so error if someone attempts to pass file descriptors
> over netlink sockets.
> 
> Cc: stable@kernel.org
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Applied, thanks for fixing this Eric.
