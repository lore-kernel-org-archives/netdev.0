From: David Miller <davem@davemloft.net>
Subject: Re: [patch -next v2] 6LoWPAN: double free in lowpan_fragment_xmit()
Date: Wed, 16 Nov 2011 18:14:08 -0500 (EST)
Message-ID: <20111116.181408.1718342285438189705.davem@davemloft.net>
References: <20111116083254.GB4349@mwanda>
	<20111116083643.GA25612@mwanda>
	<CAJmB2rBTHCTcetstpZkNkxX4CAxYF3Sd=Vrg3dmTMDzFQK0vqg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dan.carpenter@oracle.com, dbaryshkov@gmail.com, slapin@ossfans.org,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34169 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753182Ab1KPXO0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2011 18:14:26 -0500
In-Reply-To: <CAJmB2rBTHCTcetstpZkNkxX4CAxYF3Sd=Vrg3dmTMDzFQK0vqg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Date: Wed, 16 Nov 2011 11:42:07 +0300

> 2011/11/16 Dan Carpenter <dan.carpenter@oracle.com>:
>> dev_queue_xmit() consumes its own skb, so the call to dev_kfree_skb()
>> in lowpan_fragment_xmit() is a double free.
>>
>> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
 ...
> 
> Acked-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>

Applied, thanks.
