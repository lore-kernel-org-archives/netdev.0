From: YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>
Subject: Re: [PATCH v2] fjes: Do not load fjes driver if system does not have
 extended socket device.
Date: Tue, 14 Mar 2017 10:47:24 -0400
Message-ID: <d7976838-6888-2f34-7526-ab665d0ceaaf@gmail.com>
References: <7a1a2dbc-99e0-06ba-2261-6e6382937486@gmail.com>
 <87mvcqmjr2.fsf@miraculix.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
        izumi.taku@jp.fujitsu.com
To: =?UTF-8?Q?Bj=c3=b8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:35362 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751100AbdCNOr1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Mar 2017 10:47:27 -0400
Received: by mail-qk0-f196.google.com with SMTP id o135so41335467qke.2
        for <netdev@vger.kernel.org>; Tue, 14 Mar 2017 07:47:27 -0700 (PDT)
In-Reply-To: <87mvcqmjr2.fsf@miraculix.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 03/12/2017 02:29 PM, Bjørn Mork wrote:
> Yasuaki Ishimatsu <yasu.isimatu@gmail.com> writes:
>
>> The fjes driver is used only by FUJITSU servers and almost of all
>> servers in the world never use it. But currently if ACPI PNP0C02
>> is defined in the ACPI table, the following message is always shown:
>>
>>  "FUJITSU Extended Socket Network Device Driver - version 1.2
>>   - Copyright (c) 2015 FUJITSU LIMITED"
>
> Matching on PNP0C02 is fundamentally wrong. It's a way to load a device
> driver on all ACPI systems.  You should not do that. I don't think it is
> fair to make everyone suffer because of your inability to properly
> narrow down the driver matching rules.

There are so many similar matching rules. But these modules are not
listed in blacklist because these modules has proper check like my patch
and no one suffers.

So I don't think the matching rule is fundamentally wrong.

Thanks,
Yasuaki Ishimatsu
>
> Could we please just delete the whole MODULE_DEVICE_TABLE() from this
> driver until a proper solution is found? That way we don't need to
> blacklist the driver everywhere.

>
>
> Bjørn
>
