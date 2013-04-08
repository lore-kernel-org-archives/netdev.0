From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: how to test multipe unicast MAC address
Date: Mon, 08 Apr 2013 07:57:53 -0700
Message-ID: <5162DAF1.8060903@gmail.com>
References: <CAJ3bTp6xYkKwXNm_YZ9DTy9G8wdKqKEBQOVRjaGkmMURG2MaEA@mail.gmail.com> <1365430604.3887.8.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Rayagond K <rayagond@vayavyalabs.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:62495 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965400Ab3DHO6F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Apr 2013 10:58:05 -0400
Received: by mail-ob0-f181.google.com with SMTP id wo10so1435350obc.40
        for <netdev@vger.kernel.org>; Mon, 08 Apr 2013 07:58:04 -0700 (PDT)
In-Reply-To: <1365430604.3887.8.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/08/2013 07:16 AM, Eric Dumazet wrote:
> On Mon, 2013-04-08 at 12:38 +0530, Rayagond K wrote:
>> Hi All,
>>
>> How to assign multiple unicast MAC address to single interface ?
>> How to test multiple unicast MAC address filtering ?
>>
>> Thanks in advance.
>>
>
> Standard way would be to use macvlan
>
> ip link add link eth0 name foo02 addr 44:44:44:44:00:02 type macvlan
> ip link add link eth0 name foo03 addr 44:44:44:44:00:03 type macvlan
>

Or if you have a recent version of net-next you can add them directly
without using macvlan,

# bridge fdb add 44:44:44:44:00:02 dev eth0 self

But you'll need to wait a bit before that gets in a stable release.

-- 
John Fastabend         Intel Corporation
