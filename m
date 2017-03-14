From: YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>
Subject: Re: [PATCH v2] fjes: Do not load fjes driver if system does not have
 extended socket device.
Date: Tue, 14 Mar 2017 12:07:20 -0400
Message-ID: <81188b74-7f50-911e-9cac-ea20d10ea05a@gmail.com>
References: <7a1a2dbc-99e0-06ba-2261-6e6382937486@gmail.com>
 <20170309.173519.1406243244628930968.davem@davemloft.net>
 <b61b605a-d248-261c-6543-243a38d6f97e@gmail.com>
 <E86EADE93E2D054CBCD4E708C38D364A741CFE6B@G01JPEXMBYT21>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>, yasu.isimatu@gmail.com
To: "Izumi, Taku" <izumi.taku@jp.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:36740 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751070AbdCNQHX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Mar 2017 12:07:23 -0400
Received: by mail-qt0-f195.google.com with SMTP id n37so10530891qtb.3
        for <netdev@vger.kernel.org>; Tue, 14 Mar 2017 09:07:22 -0700 (PDT)
In-Reply-To: <E86EADE93E2D054CBCD4E708C38D364A741CFE6B@G01JPEXMBYT21>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 03/12/2017 09:02 PM, Izumi, Taku wrote:
> Ishimatsu-san,
>
>  Sorry for my late response.
>
>>
>> Which tree did you apply the patch to?
>>
>> The patch can apply to net-next tree with no conflicts as follows:
>
>   Not net-next but net tree:
>     git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git

I'll update the patch soon.

Thanks,
Yasuaki Ishimatsu

>
>   I'll review and test your patch soon.
>
>   Sincerely,
>   Taku Izumi
>
>>
>> # git clone
>> git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git
>> Cloning into 'net-next'...
>> remote: Counting objects: 5265118, done.
>> remote: Compressing objects: 100% (805485/805485), done.
>> Receiving objects: 100% (5265118/5265118), 910.11 MiB | 23.42 MiB/s, done.
>> remote: Total 5265118 (delta 4419240), reused 5264459 (delta 4418809)
>> Resolving deltas: 100% (4419240/4419240), done.
>> Checking out files: 100% (58005/58005), done.
>> # head -n 30 fjes.patch
>> Subject: [PATCH v2] fjes: Do not load fjes driver if system does not have
>> extended socket device.
>> Date: Wed, 8 Mar 2017 16:05:18 -0500
>> From: Yasuaki Ishimatsu <yasu.isimatu@gmail.com>
>> To: netdev@vger.kernel.org
>> CC: David Miller <davem@davemloft.net>, izumi.taku@jp.fujitsu.com
>>
>> The fjes driver is used only by FUJITSU servers and almost of all servers
>> in the world never use it. But currently if ACPI PNP0C02 is defined in the
>> ACPI table, the following message is always shown:
>>
>>   "FUJITSU Extended Socket Network Device Driver - version 1.2
>>    - Copyright (c) 2015 FUJITSU LIMITED"
>>
>> The message makes users confused because there is no reason that the message
>> is shown in other vendor servers.
>>
>> To avoid the confusion, the patch adds a check that the server has a extended
>> socket device or not.
>>
>> Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
>> CC: Taku Izumi <izumi.taku@jp.fujitsu.com>
>> ---
>> v2:
>> 	- Order local variable declarations from longest to shortest line
>>
>>   drivers/net/fjes/fjes_main.c | 52
>> +++++++++++++++++++++++++++++++++++++++-----
>>   1 file changed, 47 insertions(+), 5 deletions(-)
>>
>> diff --git a/drivers/net/fjes/fjes_main.c b/drivers/net/fjes/fjes_main.c
>> index b77e4ecf..a57c2cb 100644 # cd net-next/ # git am ../fjes.patch
>> Applying: fjes: Do not load fjes driver if system does not have extended
>> socket device.
>> #
>>
>>
>> Thanks,
>> Yasuaki Ishimatsu
>
