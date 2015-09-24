From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] BNX2: fix a Null Pointer for stats_blk
Date: Wed, 23 Sep 2015 22:34:36 -0700 (PDT)
Message-ID: <20150923.223436.53190852255282400.davem@davemloft.net>
References: <56014CC0.3050201@huawei.com>
	<20150923.153117.2291008783799112683.davem@davemloft.net>
	<5603594D.70408@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sony.chacko@qlogic.com, Dept-HSGLinuxNICDev@qlogic.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	rui.xiang@huawei.com
To: wangweidong1@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48541 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751247AbbIXFek (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2015 01:34:40 -0400
In-Reply-To: <5603594D.70408@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Weidong Wang <wangweidong1@huawei.com>
Date: Thu, 24 Sep 2015 10:00:45 +0800

> It does affect the intention. Although, the problem exists then makes the
> system panic within some case.
> 
> Do you have any idea about it?

Allocate the statistics block at probe time so that this problem is
impossible.
