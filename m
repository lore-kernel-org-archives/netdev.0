From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: kernel panic, inconsistent lock, vanilla 3.3.4, 32bit, tcp
Date: Sun, 29 Apr 2012 11:00:16 +0300
Message-ID: <6e1a75b751372f0ca5a58c2d0122a3cc@visp.net.lb>
References: <04009a9cbb27bf97cb7d86612191b751@visp.net.lb>
 <1335684762.2900.69.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Glauber Costa <glommer@parallels.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:51291 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752492Ab2D2IAU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Apr 2012 04:00:20 -0400
In-Reply-To: <1335684762.2900.69.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2012-04-29 10:32, Eric Dumazet wrote:
> On Sun, 2012-04-29 at 00:45 +0300, Denys Fedoryshchenko wrote:
>> Hi
>>
>> Just got repeatable kernel panic on loaded proxy server
>>
>> Here is the log:

>>
>> ---
>> Denys Fedoryshchenko
>
> Seems to be related to Glauber Costa work
>
> sk_memory_allocated_add() seems to assume __percpu_counter_add() is 
> irq
> safe (truth is : it is not safe)

Not sure if it is related, but at my case, CONFIG_CGROUPS is not set
