From: Ivan Vecera <ivecera@redhat.com>
Subject: Re: [PATCH net-next] be2net: log link status
Date: Wed, 22 Apr 2015 15:22:50 +0200
Message-ID: <5537A0AA.50407@redhat.com>
References: <1429707370-2792-1-git-send-email-ivecera@redhat.com> <1429708255.31675.42.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Sathya Perla <sathya.perla@emulex.com>,
	Subbu Seetharaman <subbu.seetharaman@emulex.com>,
	Ajit Khaparde <ajit.khaparde@emulex.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56953 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752208AbbDVNWy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Apr 2015 09:22:54 -0400
In-Reply-To: <1429708255.31675.42.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/22/2015 03:10 PM, Joe Perches wrote:
> On Wed, 2015-04-22 at 14:56 +0200, Ivan Vecera wrote:
>> The driver unlike other drivers does not log link state changes.
> []
>> diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
> []
>> @@ -662,6 +662,8 @@ void be_link_status_update(struct be_adapter *adapter, u8 link_status)
>>   		netif_carrier_on(netdev);
>>   	else
>>   		netif_carrier_off(netdev);
>> +
>> +	netdev_info(netdev, "Link is %s\n", link_status ? "Up" : "Down");
>>   }
>
> If this is valuable, it's also valuable to emit the
> link speed/duplex states like most other drivers.
>
Duplex state is not much valuable as for be2net link-up means 
full-duplex and link-down means unknown-duplex.
But link speed could be valuable. Will send v2.

Ivan
