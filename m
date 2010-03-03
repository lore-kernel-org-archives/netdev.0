From: Dick Hollenbeck <dick@softplc.com>
Subject: Re: KS8695: possible NAPI issue
Date: Tue, 02 Mar 2010 23:01:29 -0600
Message-ID: <4B8DED29.9000605@softplc.com>
References: <f69abfc31003020404y7af77fe5icefeee4644c7d08e@mail.gmail.com>	 <4B8D1C02.1010204@softplc.com> <c6ed1ac51003021746n2b246591g880b584550ec5e84@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Yegor Yefremov <yegorslists@googlemail.com>,
	netdev@vger.kernel.org, zealcook@gmail.com
To: figo zhang <figo1802@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kcmailp04.birch.net ([216.212.0.99]:57230 "EHLO mx01.birch.net"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750746Ab0CCFBJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Mar 2010 00:01:09 -0500
In-Reply-To: <c6ed1ac51003021746n2b246591g880b584550ec5e84@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

figo zhang wrote:
> 2010/3/2 Dick Hollenbeck <dick@softplc.com>:
>   
>> Yegor Yefremov wrote:
>>     
>>> I'm using 2.6.33 kernel and I noticed such a strange behavior:
>>>
>>> after system start I transfer one file via netcat from my development
>>> host, after this transfer the network is not functioning i.e. no pings
>>> possible etc.
>>>
>>> To narrow down the problem I checked out this commit
>>>
>>> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=451f14439847db302e5104c44458b2dbb4b1829d.
>>> Till here the network driver is functioning as intended, but after
>>> NAPI introduction I have this issue. With latest git-pull of "Linus'
>>> kernel tree" I can't even ping right after the systems start.
>>>
>>> Any Ideas? What am I missing?
>>>
>>>       
>> No idea, although I am using the same ARM chip, my kernel is at 2.6.30.5,
>> and except for this occasional loss of connection I get, the ethernet driver
>> seems to work better than what you are reporting.
>>     
>
> from linux-2.6.32, this ethernet  driver have add NAPI support, would
> you like to
> try using this version?
>   

Seems like a lot of work for me, given that my 2.6.30.5 kernel is mostly 
working.   Yegor is having the problems on the newer kernels, newer than 
mine.  Sounds like a warning flag to me, not an incentive.

What is NAPI and why do I care?

Dick


