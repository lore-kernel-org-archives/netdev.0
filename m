From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [net-next 2/8] net/mlx5: Configure cache line size for start and
 end padding
Date: Sun, 5 Feb 2017 13:23:41 +0200
Message-ID: <CALzJLG_v7kZrioA_VrHT78iatiEOSCp9uWUJFNv1XP6+sMvFzQ@mail.gmail.com>
References: <20170131205843.23235-1-saeedm@mellanox.com> <20170131205843.23235-3-saeedm@mellanox.com>
 <063D6719AE5E284EB5DD2968C1650D6DB0277BC4@AcuExch.aculab.com> <VI1PR0501MB2429398983643A6387BE91D0C44C0@VI1PR0501MB2429.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Laight <David.Laight@aculab.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Daniel Jurgens <danielj@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:33845 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751442AbdBELYR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 5 Feb 2017 06:24:17 -0500
Received: by mail-qt0-f196.google.com with SMTP id w20so11360182qtb.1
        for <netdev@vger.kernel.org>; Sun, 05 Feb 2017 03:24:02 -0800 (PST)
In-Reply-To: <VI1PR0501MB2429398983643A6387BE91D0C44C0@VI1PR0501MB2429.eurprd05.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 2, 2017 at 4:47 PM, Daniel Jurgens <danielj@mellanox.com> wrote:
> On 2/1/2017 5:12 AM, David Laight wrote:
>> From: Saeed Mahameed
>>> Sent: 31 January 2017 20:59
>>> From: Daniel Jurgens <danielj@mellanox.com>
>>>
>>> There is a hardware feature that will pad the start or end of a DMA to
>>> be cache line aligned to avoid RMWs on the last cache line. The default
>>> cache line size setting for this feature is 64B. This change configures
>>> the hardware to use 128B alignment on systems with 128B cache lines.
>> What guarantees that the extra bytes are actually inside the receive skb's
>> head and tail room?
>>
>>       David
>>
>>
> The hardware won't over write the length of the posted buffer.  This feature is already enabled and defaults to 64B stride, this patch just configures it properly for 128B cache line sizes.
>
Right, and next patch will make sure RX stride is aligned to 128B in
case 128B cacheline size configured into the HW.

> Thanks for reviewing it.
>
> Dan
>
