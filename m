From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] genetlink: simplify genl_notify
Date: Thu, 24 Sep 2015 12:25:37 -0700 (PDT)
Message-ID: <20150924.122537.332638217035871073.davem@davemloft.net>
References: <b1f238bfc117e127fef538257a3c43aa06d015d7.1442940978.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53373 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751290AbbIXTZi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2015 15:25:38 -0400
In-Reply-To: <b1f238bfc117e127fef538257a3c43aa06d015d7.1442940978.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Tue, 22 Sep 2015 18:56:43 +0200

> The genl_notify function has too many arguments for no real reason - all
> callers use genl_info to get them anyway. Just pass the genl_info down to
> genl_notify.
> 
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

Applied, thanks Jiri.
