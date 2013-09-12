From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/4] bridge: Don't use VID 0 and 4095 in vlan
 filtering
Date: Thu, 12 Sep 2013 15:55:33 -0400 (EDT)
Message-ID: <20130912.155533.521690436399073964.davem@davemloft.net>
References: <1378808874.3988.2.camel@ubuntu-vm-makita>
	<1378809144.3988.6.camel@ubuntu-vm-makita>
	<522F2B22.5010007@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: makita.toshiaki@lab.ntt.co.jp, netdev@vger.kernel.org
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37534 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756662Ab3ILTzn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Sep 2013 15:55:43 -0400
In-Reply-To: <522F2B22.5010007@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevic@redhat.com>
Date: Tue, 10 Sep 2013 10:22:26 -0400

> On 09/10/2013 06:32 AM, Toshiaki Makita wrote:
>> IEEE 802.1Q says that:
>> - VID 0 shall not be configured as a PVID, or configured in any
>> - Filtering
>> Database entry.
>> - VID 4095 shall not be configured as a PVID, or transmitted in a tag
>> header. This VID value may be used to indicate a wildcard match for
>> the VID
>> in management operations or Filtering Database entries.
>> (See IEEE 802.1Q-2005 6.7.1 and Table 9-2)
>>
>> Don't accept adding these VIDs in the vlan_filtering implementation.
>>
>> Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
> 
> Reviewed-by: Vlad Yasevich <vyasevich@redhat.com>

Vlad, as far as I can see your redhat.com email ends just with a "c"
not a "ch".  It's your gmail account that ends in a "ch".

I'm fixing this up while applying these patches, if you have something
automatically generating these reviewed-by strings please fix it up
although I note that some are correct and some are not so maybe you
do this by hand :-)
