From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] tg3: add device id of Apple Thunderbolt Ethernet
 device
Date: Fri, 13 Jul 2012 03:00:02 -0700 (PDT)
Message-ID: <20120713.030002.136821791909658673.davem@davemloft.net>
References: <20120712205607.GA27999@kroah.com>
	<20120713013944.GB6445@kroah.com>
	<1342163198.7472.73.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, mcarlson@broadcom.com,
	netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39807 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754557Ab2GMKAC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jul 2012 06:00:02 -0400
In-Reply-To: <1342163198.7472.73.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Fri, 13 Jul 2012 00:06:38 -0700

> On Thu, 2012-07-12 at 18:39 -0700, Greg KH wrote: 
>> The Apple Thunderbolt ethernet device is already listed in the driver,
>> but not hooked up in the MODULE_DEVICE_TABLE().  This fixes that and
>> allows it to work properly.
>> 
>> Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
>> 
>> ---
>> Resent to Cc: the proper developers this time.
>> 
>> diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
>> index e47ff8b..3721833 100644
>> --- a/drivers/net/ethernet/broadcom/tg3.c
>> +++ b/drivers/net/ethernet/broadcom/tg3.c
>> @@ -298,6 +298,7 @@ static DEFINE_PCI_DEVICE_TABLE(tg3_pci_tbl) = {
>>  	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57795)},
>>  	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_5719)},
>>  	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_5720)},
>> +	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57762)},
>>  	{PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, PCI_DEVICE_ID_SYSKONNECT_9DXX)},
>>  	{PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, PCI_DEVICE_ID_SYSKONNECT_9MXX)},
>>  	{PCI_DEVICE(PCI_VENDOR_ID_ALTIMA, PCI_DEVICE_ID_ALTIMA_AC1000)},
>> 
> 
> ACK for net-next.  I don't know why Matt added everything to support
> this chip except the entry in the PCI ID table.
> 
> Acked-by: Michael Chan <mchan@broadcom.com>

Applied.
