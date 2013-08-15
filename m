From: David Miller <davem@davemloft.net>
Subject: Re: [patch] tun: signedness bug in tun_get_user()
Date: Thu, 15 Aug 2013 14:51:49 -0700 (PDT)
Message-ID: <20130815.145149.39135968046365706.davem@davemloft.net>
References: <20130815125257.GA16932@elgon.mountain>
	<20130815200834.GE20294@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dan.carpenter@oracle.com, jasowang@redhat.com, mst@redhat.com,
	edumazet@google.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46486 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751486Ab3HOVvu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Aug 2013 17:51:50 -0400
In-Reply-To: <20130815200834.GE20294@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Thu, 15 Aug 2013 16:08:35 -0400

> On Thu, Aug 15, 2013 at 03:52:57PM +0300, Dan Carpenter wrote:
>> The recent fix d9bf5f1309 "tun: compare with 0 instead of total_len" is
>> not totally correct.  Because "len" and "sizeof()" are size_t type, that
>> means they are never less than zero.
>> 
>> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
 ...
> Acked-by: Neil Horman <nhorman@tuxdriver.com>

Applied, thanks everyone.
