From: Sedat Dilek <sedat.dilek@googlemail.com>
Subject: Re: [PATCH net-next] net: fix skb_add_data_nocache() to calc csum correctly
Date: Thu, 7 Apr 2011 14:05:09 +0200
Message-ID: <BANLkTikFocF1oc4AbJFTVW3_rHj3WEersg@mail.gmail.com>
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Tom Herbert <therbert@google.com>
To: Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:39653 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755832Ab1DGMFK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2011 08:05:10 -0400
Received: by qyg14 with SMTP id 14so1701112qyg.19
        for <netdev@vger.kernel.org>; Thu, 07 Apr 2011 05:05:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[QUOTE]
From: Tom Herbert <therbert@google.com>
Date: Wed, 6 Apr 2011 21:50:55 -0700

> Nice catch.
>
> Acked-by: Tom Herbert <therbert@google.com>
>
> On Wed, Apr 6, 2011 at 9:40 PM, Wei Yongjun <yjwei@cn.fujitsu.com> wrote:
>> commit c6e1a0d12ca7b4f22c58e55a16beacfb7d3d8462 broken the calc
>>  (net: Allow no-cache copy from user on transmit)
>> of checksum, which may cause some tcp packets be dropped because
>> incorrect checksum. ssh does not work under today's net-next-2.6
>> tree.
>>
>> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>

Applied, thanks everyone.
[/QUOTE]

With reference to my asking in [1] feel free to add:

     Tested-by: Sedat Dilek <sedat.dilek@gmail.com>

- Sedat -

[1] http://marc.info/?l=linux-netdev&m=130217337305798&w=2
