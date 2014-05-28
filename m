From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: Scaling 'ip addr add' (was Re: What's the right way to use a
 *large* number of source addresses?)
Date: Wed, 28 May 2014 07:23:29 -0400
Message-ID: <5385C731.5060709@mojatatu.com>
References: <CACP96tRSpop=Sf58qE6TXeF+a-5nqfCj5d12bwD9WaYue_6_UA@mail.gmail.com>	<1401241268.5367.266.camel@edumazet-glaptop2.roam.corp.google.com> <CACP96tRo1OthQqDhPLVgai2vJPkd6macpdkD3MKwePZa8GMUnQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?B?TmllbHMgTcO2bGxlcg==?= <nisse@southpole.se>,
	netdev <netdev@vger.kernel.org>, Jonas Bonn <jonas@southpole.se>
To: sowmini varadhan <sowmini05@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:34289 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752292AbaE1LXc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 May 2014 07:23:32 -0400
Received: by mail-ig0-f181.google.com with SMTP id h3so2289822igd.8
        for <netdev@vger.kernel.org>; Wed, 28 May 2014 04:23:31 -0700 (PDT)
In-Reply-To: <CACP96tRo1OthQqDhPLVgai2vJPkd6macpdkD3MKwePZa8GMUnQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/28/14 06:01, sowmini varadhan wrote:
>> You did not provide kernel version you used.
>>
>> Last time I checked, we were spending _lot_ of time in check_lifetime()
>>
>> ( this stuff was added in linux-3.9 )
>>
>
> Built the latest kernel (vmlinuz-3.15.0-rc6+) from a clone
> of kernel.git from may 24
>
> --Sowmini
>

Did you try the scenario where you add many IP addresses to the same
interface? Try to do a listing of the ip addresses then, should be
fun.

cheers,
jamal
