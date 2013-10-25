From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: add missing dev_put() in
 __netdev_adjacent_dev_insert
Date: Fri, 25 Oct 2013 19:04:44 -0400 (EDT)
Message-ID: <20131025.190444.1094472725050309053.davem@davemloft.net>
References: <1382534936-23080-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vfalico@redhat.com
To: nikolay@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35978 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752752Ab3JYXEp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Oct 2013 19:04:45 -0400
In-Reply-To: <1382534936-23080-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@redhat.com>
Date: Wed, 23 Oct 2013 15:28:56 +0200

> I think that a dev_put() is needed in the error path to preserve the
> proper dev refcount.
> 
> CC: Veaceslav Falico <vfalico@redhat.com>
> Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>

Applied.
