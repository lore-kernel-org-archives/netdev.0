From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net-bnx2x: dont reload on GRO change
Date: Mon, 20 May 2013 00:17:03 -0700 (PDT)
Message-ID: <20130520.001703.3222910244436114.davem@davemloft.net>
References: <1368897293.3301.152.camel@edumazet-glaptop>
	<504C9EFCA2D0054393414C9CB605C37F20C5054D@SJEXCHMB06.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, eilong@broadcom.com
To: dmitry@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54614 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751362Ab3ETHRE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 May 2013 03:17:04 -0400
In-Reply-To: <504C9EFCA2D0054393414C9CB605C37F20C5054D@SJEXCHMB06.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Dmitry Kravkov" <dmitry@broadcom.com>
Date: Sat, 18 May 2013 21:36:07 +0000

>> -----Original Message-----
>> From: Eric Dumazet [mailto:eric.dumazet@gmail.com]
>> Sent: Saturday, May 18, 2013 8:15 PM
>> To: David Miller
>> Cc: netdev; Dmitry Kravkov; Eilon Greenstein
>> Subject: [PATCH net-next] net-bnx2x: dont reload on GRO change
>> 
>> From: Eric Dumazet <edumazet@google.com>
>> 
>> bnx2x_set_features() forces a driver reload if GRO setting is changed.
>> 
>> A reload makes the ethernet port unresponsive for about 5 seconds.
>> 
>> This is not needed in the common case LRO is enabled, as LRO
>> (TPA_ENABLE_FLAG) has precedence over GRO (GRO_ENABLE_FLAG)
>> 
>> Tested:
>>  Verified that "ethtool -K eth0 gro {on|off}" doesn't blackout
>>  the NIC anymore
>> 
>> Google-Bug-Id: 8440442
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
...
> Looks good! Thanks, Eric
> 
> Acked-by: Dmitry Kravkov <dmitry@broadcom.com>
> 

Applied, thanks.
