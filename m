From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] 6lowpan: Moving generic compression code
 into 6lowpan_iphc.c
Date: Tue, 10 Dec 2013 13:51:19 -0500 (EST)
Message-ID: <20131210.135119.1092004215853497854.davem@davemloft.net>
References: <1386576963-21764-1-git-send-email-jukka.rissanen@linux.intel.com>
	<20131209081833.GB2062@omega>
	<09E9761B-6A18-4F28-9315-DD6D44C45597@holtmann.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alex.aring@gmail.com, jukka.rissanen@linux.intel.com,
	netdev@vger.kernel.org, linux-zigbee-devel@lists.sourceforge.net
To: marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51177 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751262Ab3LJSvW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 13:51:22 -0500
In-Reply-To: <09E9761B-6A18-4F28-9315-DD6D44C45597@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcel Holtmann <marcel@holtmann.org>
Date: Tue, 10 Dec 2013 13:12:10 +0100

> Hi Alexander,
> 
>> thanks for working on this! Now my acked-by is correct, sry. Didn't
>> catch the debug output at first time.
>> 
>>> Because the IEEE 802154 and Bluetooth share the IP header compression
>>> and uncompression code, the common code is moved to 6lowpan_iphc.c
>>> file.
>>> 
>>> Signed-off-by: Jukka Rissanen <jukka.rissanen@linux.intel.com>
>>> ---
>> 
>> Acked-by: Alexander Aring <alex.aring@gmail.com>
> 
> are you fine with us carrying these patches through bluetooth-next tree.
> 
> Dave, or do you want to merge this one into net-next and then we have wireless-next pulling that in.

You guys can put it in via bluetooth-next.
