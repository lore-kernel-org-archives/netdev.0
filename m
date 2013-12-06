From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bonding: add arp_ip_target checks when install the
 module
Date: Thu, 05 Dec 2013 20:58:38 -0500 (EST)
Message-ID: <20131205.205838.257217220906300904.davem@davemloft.net>
References: <529F0B13.4050600@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, andy@greyhouse.net, nikolay@redhat.com,
	vfalico@redhat.com, netdev@vger.kernel.org
To: dingtianhong@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60560 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751726Ab3LFB6k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 20:58:40 -0500
In-Reply-To: <529F0B13.4050600@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ding Tianhong <dingtianhong@huawei.com>
Date: Wed, 4 Dec 2013 18:59:31 +0800

> When I install the bonding with the wrong arp_ip_target,
> just like arp_ip_target=500.500.500.500, the arp_ip_target
> was transfored to 245.245.245.244 and stored in the ip
> target success, it is uncorrect, so I add checks to avoid
> adding wrong address.
> 
> The in4_pton() will set wrong ip address to 0.0.0.0 and
> return 0, also use the micro IS_IP_TARGET_UNUSABLE_ADDRESS
> to simplify the code.
> 
> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>

Applied, thank you.
