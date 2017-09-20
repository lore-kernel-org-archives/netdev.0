From: =?UTF-8?Q?Pawe=c5=82_Staszewski?= <pstaszewski@itcare.pl>
Subject: Re: Latest net-next from GIT panic
Date: Wed, 20 Sep 2017 02:26:47 +0200
Message-ID: <fdaf967f-748f-cb56-3762-b347cd53028f@itcare.pl>
References: <4745525f-18e4-7f69-fe21-8e507e407b33@itcare.pl>
 <d8bbf6c1-20a3-195c-6980-45f29e9f9278@itcare.pl>
 <2aeb7871-fe89-c714-3355-c5f48651e70c@itcare.pl>
 <15d293fa-0f53-bdca-6358-6a58d1da77af@itcare.pl>
 <65e2195b-3bd1-c0b4-b474-e07dd08f71b9@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp16.iq.pl ([86.111.242.222]:41595 "EHLO smtp16.iq.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751561AbdITA3A (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 19 Sep 2017 20:29:00 -0400
Received: from [192.168.2.200] (unknown [185.78.72.19])
        (Authenticated sender: pstaszewski@itcare.pl)
        by smtp.iq.pl (Postfix) with ESMTPSA id 3xxgbG5rkMz3xJD
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 02:28:58 +0200 (CEST)
In-Reply-To: <65e2195b-3bd1-c0b4-b474-e07dd08f71b9@itcare.pl>
Content-Language: pl
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Latest working kernel with same configuration and kernel config 4.12.13

There is no panic after routes from all 6x bgp sessions are learned.

ip r | wc -l
653112




W dniu 2017-09-20 o 02:06, Paweł Staszewski pisze:
> Just checked kernel 4.13.2 and same problem
>
> Just after start all 6 bgp sessions - and kernel starts to learn 
> routes it panic.
>
> https://bugzilla.kernel.org/attachment.cgi?id=258509
>
>
>
> W dniu 2017-09-20 o 02:01, Paweł Staszewski pisze:
>> Some information about enviroment:
>> Server is acting as a ip router with bgp
>> There are 6x bgp sessions - each with full bgp table ~600k prefixes
>>
>> And it looks like panic is appearing after bgp sessions are connected 
>> - not by traffic - cause at time when panic occured there is almost 
>> no traffic.
>>
>> Also when I run tris server without turning on BGP and push thru this 
>> server traffic by pktgen there is no panic.
>>
>> just after it learn routes it panick
>>
>>
>>
>>
>>
>>
>>
>> W dniu 2017-09-20 o 01:45, Paweł Staszewski pisze:
>>> Added few more screenshoots from kernels 4.14-rc1(net-next) and 
>>> 4.14-rc1(linux-next)
>>>
>>> https://bugzilla.kernel.org/show_bug.cgi?id=197005
>>>
>>>
>>> W dniu 2017-09-20 o 00:35, Paweł Staszewski pisze:
>>>> Just tried latest net-next git and found kernel panic.
>>>>
>>>> Below link to bugzilla.
>>>>
>>>> https://bugzilla.kernel.org/attachment.cgi?id=258499
>>>>
>>>>
>>>>
>>>>
>>>>
>>>
>>>
>>
>>
>
>
