From: Daniele Palmas <dnlplm@gmail.com>
Subject: Re: [PATCH 0/2] net: usb: cdc_ncm: Adding support for two new Dell devices
Date: Thu, 17 Dec 2015 13:40:40 +0100
Message-ID: <CAGRyCJGGC-yAo5ShJ+XaeEuJYpW6YUasfqGxwV82fgs=yM9WWg@mail.gmail.com>
References: <1450258765-11215-1-git-send-email-dnlplm@gmail.com>
	<1450285954.23793.15.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-usb <linux-usb@vger.kernel.org>
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f181.google.com ([209.85.217.181]:35321 "EHLO
	mail-lb0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755630AbbLQMkn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2015 07:40:43 -0500
In-Reply-To: <1450285954.23793.15.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dan,

2015-12-16 18:12 GMT+01:00 Dan Williams <dcbw@redhat.com>:
> On Wed, 2015-12-16 at 10:39 +0100, Daniele Palmas wrote:
>> This patch series add support in the cdc_ncm driver for two devices
>> based on the same platform, that are different only for carrier
>> customization.
>>
>> The devices do not have ARP capabilities.
>>
>> Daniele Palmas (2):
>>   net: usb: cdc_ncm: Adding Dell DW5812 LTE Verizon Mobile Broadband
>>     Card
>>   net: usb: cdc_ncm: Adding Dell DW5813 LTE AT&T Mobile Broadband
>> Card
>
> Quite interesting; Google knows nothing about these devices that I can
> find.  What platform are these based on?
>

those devices are still in the testing stage, so there is nothing
about them in the web. They are Infineon based.

> But in any case, since these blocks are almost identical to the DW5550
> block, maybe update the comments to indicate that they need NOARP
> unlike the MBM platform that the 5550 is based on?

Sure, I can do a V2 patch for that.

>
> Dan

Thanks,
Daniele
