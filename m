From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] be2net: fix a race in be_xmit()
Date: Fri, 08 Jun 2012 14:44:39 -0700 (PDT)
Message-ID: <20120608.144439.2206391950312069751.davem@davemloft.net>
References: <1339145999.6001.62.camel@edumazet-glaptop>
	<3367B80B08154D42A3B2BC708B5D41F647C6A0B900@EXMAIL.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: Sathya.Perla@Emulex.Com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52923 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934508Ab2FHVok (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jun 2012 17:44:40 -0400
In-Reply-To: <3367B80B08154D42A3B2BC708B5D41F647C6A0B900@EXMAIL.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <Sathya.Perla@Emulex.Com>
Date: Fri, 8 Jun 2012 03:06:14 -0700

> 
>>-----Original Message-----
>>From: Eric Dumazet <edumazet@google.com>
>>
>>As soon as hardware is notified of a transmit, we no longer can assume
>>skb can be dereferenced, as TX completion might have freed the packet.
>>
>>Signed-off-by: Eric Dumazet <edumazet@google.com>
>>Cc: Sathya Perla <sathya.perla@emulex.com>
> 
> Good catch. Thanks!
> Acked-by: Sathya Perla <sathya.perla@emulex.com>

Applied.
