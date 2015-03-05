From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: I can tell no FIB
Date: Thu, 05 Mar 2015 14:01:45 -0800
Message-ID: <54F8D249.4080404@gmail.com>
References: <CAE4R7bBwrB8==aYuN9gYoADwZHDwr5zYjL3tL=jqPP24p74VUw@mail.gmail.com>	<54F8C802.1010706@gmail.com> <20150305.162711.545663291988773902.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: sfeldma@gmail.com, alexander.h.duyck@redhat.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:42168 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750834AbbCEWBr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 17:01:47 -0500
Received: by padfa1 with SMTP id fa1so45861862pad.9
        for <netdev@vger.kernel.org>; Thu, 05 Mar 2015 14:01:46 -0800 (PST)
In-Reply-To: <20150305.162711.545663291988773902.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/05/2015 01:27 PM, David Miller wrote:
> From: Alexander Duyck <alexander.duyck@gmail.com>
> Date: Thu, 05 Mar 2015 13:17:54 -0800
>
>> On 03/05/2015 12:49 PM, Scott Feldman wrote:
>>> Hi Alex, turns out you're required to take a mandatory week-long
>>> vacation after your fourth patch set to net/ipv4/fib_*.  See you in a
>>> week!  Take lots of pictures.
>>>
>>> -scott
>> Well I have one more set of 9 and then I will stop for a while.  I was
>> planning to send it later tonight.  Then I can probably take that
>> week-long vacation..
>>
>> I'm going to drop the portion of the patches I had where I was
>> up-levelling the key vector since I still don't have a solution for the
>> extra costs of insertion/deletion from the trie.  Also I don't think it
>> would work well with the merge of the main and local tries if that is
>> the route we are planning to take.
> Ok, where do you want to place the main/local tree patch then?
>
> Scott's L3 work logically depends upon that, and actually I think
> Scott is sending you on vacation so that he doesn't have to rebase so
> much :-)

Yeah, I kind of figured that might be the case.  If needed I can hold
off for a day or so while Scott gets the FIB offloading stuff in and I
could just submit the remaining 9 plus the main/local merge patch as an
RFC so that it can be reviewed while the offload stuff is accepted.

- Alex
