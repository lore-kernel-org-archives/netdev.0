From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: bcmgenet: add BQL support
Date: Fri, 08 Apr 2016 16:36:48 -0400 (EDT)
Message-ID: <20160408.163648.2055481752216023669.davem@davemloft.net>
References: <1459903801-83727-1-git-send-email-pgynther@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com, opendmb@gmail.com,
	jaedon.shin@gmail.com
To: pgynther@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36761 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753927AbcDHUgu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 16:36:50 -0400
In-Reply-To: <1459903801-83727-1-git-send-email-pgynther@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petri Gynther <pgynther@google.com>
Date: Tue,  5 Apr 2016 17:50:01 -0700

> Add Byte Queue Limits (BQL) support to bcmgenet driver.
> 
> Signed-off-by: Petri Gynther <pgynther@google.com>

As Eric Dumazet indicated, your ->ndo_init() code to reset the queues is
probably not necessary at all.
