From: <Ajit.Khaparde@Emulex.Com>
Subject: RE: [PATCH net-next 1/5] be2net: add rxhash support
Date: Thu, 7 Apr 2011 12:57:27 -0700
Message-ID: <49395329523DD64492581B505F80C86D5A5BCD3949@EXMAIL.ad.emulex.com>
References: <20110407040743.GA4183@akhaparde-VBox>,<1302152725.2701.60.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht2.emulex.com ([138.239.113.184]:7289 "EHLO
	exht2.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756898Ab1DGUA6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2011 16:00:58 -0400
In-Reply-To: <1302152725.2701.60.camel@edumazet-laptop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

________________________________________
=46rom: Eric Dumazet [eric.dumazet@gmail.com]
Sent: Thursday, April 07, 2011 12:05 AM
To: Khaparde, Ajit
Cc: netdev@vger.kernel.org
Subject: Re: [PATCH net-next 1/5] be2net: add rxhash support

> Le mercredi 06 avril 2011 =E0 23:07 -0500, Ajit Khaparde a =E9crit :
>> Add rxhash support,
>> Based on initial work by Eric Dumazet.
>>
>> Cc: Eric Dumazet <eric.dumazet@gmail.com>
>> Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
>> ---
>>  drivers/net/benet/be.h         |    5 +++++
>>  drivers/net/benet/be_ethtool.c |   13 +++++++++++++
>>  drivers/net/benet/be_main.c    |   17 ++++++++++++-----
>>  3 files changed, 30 insertions(+), 5 deletions(-)
>>
>> diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
>> index 0899d91..8941b98 100644
>> --- a/drivers/net/benet/be.h
>> +++ b/drivers/net/benet/be.h
>> @@ -485,6 +485,11 @@ static inline void be_vf_eth_addr_generate(stru=
ct be_adapter *adapter, u8 *mac)
>>       memcpy(mac, adapter->netdev->dev_addr, 3);
>>  }
>>
> +static inline bool be_multi_rxq(struct be_adapter *adapter)

> static inline bool be_multi_rxq(const struct be_adapter *adapter)


>> +{
>> +     return (adapter->num_rx_qs > 1);

>        return adapter->num_rx_qs > 1;

>> +}
>> +

> Other parts seems fine, thanks !

Thanks Eric.

Dave, do you want me to respin patch or you can accomodate Eric's sugge=
stion?

Thanks
-Ajit