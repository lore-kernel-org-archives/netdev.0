From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bonding: remove unwanted bond lock for enslave
 processing
Date: Mon, 10 Feb 2014 16:55:00 -0800 (PST)
Message-ID: <20140210.165500.1896172830915784091.davem@davemloft.net>
References: <52F88EF7.606@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, vfalico@redhat.com, andy@greyhouse.net,
	netdev@vger.kernel.org
To: dingtianhong@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57283 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752881AbaBKAzB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Feb 2014 19:55:01 -0500
In-Reply-To: <52F88EF7.606@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ding Tianhong <dingtianhong@huawei.com>
Date: Mon, 10 Feb 2014 16:33:59 +0800

> The bond enslave processing don't hold bond->lock anymore,
> so release an unlocked rw lock will cause warning message,
> remove the unwanted read_unlock(&bond->lock).
> 
> Cc: Jay Vosburgh <fubar@us.ibm.com>
> Cc: Veaceslav Falico <vfalico@redhat.com>
> Cc: Andy Gospodarek <andy@greyhouse.net>
> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>

Applied, thanks.
