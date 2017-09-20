From: =?UTF-8?Q?Pawe=c5=82_Staszewski?= <pstaszewski@itcare.pl>
Subject: Re: Latest net-next from GIT panic
Date: Wed, 20 Sep 2017 02:01:57 +0200
Message-ID: <15d293fa-0f53-bdca-6358-6a58d1da77af@itcare.pl>
References: <4745525f-18e4-7f69-fe21-8e507e407b33@itcare.pl>
 <d8bbf6c1-20a3-195c-6980-45f29e9f9278@itcare.pl>
 <2aeb7871-fe89-c714-3355-c5f48651e70c@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
To: =?UTF-8?Q?Pawe=c5=82_Staszewski?= <pstaszewski@itcare.pl>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp16.iq.pl ([86.111.242.222]:50604 "EHLO smtp16.iq.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751074AbdITAEK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 19 Sep 2017 20:04:10 -0400
In-Reply-To: <2aeb7871-fe89-c714-3355-c5f48651e70c@itcare.pl>
Content-Language: pl
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some information about enviroment:
Server is acting as a ip router with bgp
There are 6x bgp sessions - each with full bgp table ~600k prefixes

And it looks like panic is appearing after bgp sessions are connected - 
not by traffic - cause at time when panic occured there is almost no 
traffic.

Also when I run tris server without turning on BGP and push thru this 
server traffic by pktgen there is no panic.

just after it learn routes it panick







W dniu 2017-09-20 o 01:45, Paweł Staszewski pisze:
> Added few more screenshoots from kernels 4.14-rc1(net-next) and 
> 4.14-rc1(linux-next)
>
> https://bugzilla.kernel.org/show_bug.cgi?id=197005
>
>
> W dniu 2017-09-20 o 00:35, Paweł Staszewski pisze:
>> Just tried latest net-next git and found kernel panic.
>>
>> Below link to bugzilla.
>>
>> https://bugzilla.kernel.org/attachment.cgi?id=258499
>>
>>
>>
>>
>>
>
>
