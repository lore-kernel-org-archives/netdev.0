From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] net: sctp: remove sctp_ep_common struct
 member 'malloced'
Date: Mon, 15 Apr 2013 14:14:05 -0400 (EDT)
Message-ID: <20130415.141405.2008713283094215984.davem@davemloft.net>
References: <1366032438-4412-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34788 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755828Ab3DOSOI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Apr 2013 14:14:08 -0400
In-Reply-To: <1366032438-4412-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Mon, 15 Apr 2013 15:27:17 +0200

> There is actually no need to keep this member in the structure, because
> after init it's always 1 anyway, thus always kfree called. This seems to
> be an ancient leftover from the very initial implementation from 2.5
> times. Only in case the initialization of an association fails, we leave
> base.malloced as 0, but we nevertheless kfree it in the error path in
> sctp_association_new().
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied.
