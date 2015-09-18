From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] fjes: fix off-by-one error at
 fjes_hw_update_zone_task()
Date: Thu, 17 Sep 2015 22:34:27 -0700 (PDT)
Message-ID: <20150917.223427.280285201756783729.davem@davemloft.net>
References: <1442499681-16712-1-git-send-email-izumi.taku@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dan.carpenter@oracle.com
To: izumi.taku@jp.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48671 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751418AbbIRFe2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 01:34:28 -0400
In-Reply-To: <1442499681-16712-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Date: Thu, 17 Sep 2015 23:21:21 +0900

> Dan Carpenter reported off-by-one error of fjes at
> http://www.mail-archive.com/netdev@vger.kernel.org/msg77520.html
> 
> Actually this is a bug.
> ep_shm_info[epidx].{es_status, zone} should be update
> inside for loop.
> 
> This patch fixes this bug.
> 
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>

Applied.
