From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] inet_diag: Remove _bh suffix in
 inet_diag_dump_reqs().
Date: Tue, 23 Jun 2015 01:20:34 -0700 (PDT)
Message-ID: <20150623.012034.2003342970147447378.davem@davemloft.net>
References: <1434627654-3630-1-git-send-email-shimoda.hiroaki@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shimoda.hiroaki@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59916 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753377AbbFWIIp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jun 2015 04:08:45 -0400
In-Reply-To: <1434627654-3630-1-git-send-email-shimoda.hiroaki@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hiroaki Shimoda <shimoda.hiroaki@gmail.com>
Date: Thu, 18 Jun 2015 20:40:54 +0900

> inet_diag_dump_reqs() is called from inet_diag_dump_icsk() with BH
> disabled. So no need to disable BH in inet_diag_dump_reqs().
> 
> Signed-off-by: Hiroaki Shimoda <shimoda.hiroaki@gmail.com>

Applied.
