From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [net-next 2/8] net/mlx5: Configure cache line size for start and
 end padding
Date: Mon, 6 Feb 2017 16:26:10 +0200
Message-ID: <CALzJLG_=oqH_makhbC8NO6WkeDyW-CUDmh+q8tJJkSL+G4Hp6w@mail.gmail.com>
References: <20170131205843.23235-1-saeedm@mellanox.com> <20170131205843.23235-3-saeedm@mellanox.com>
 <063D6719AE5E284EB5DD2968C1650D6DB0277BC4@AcuExch.aculab.com>
 <VI1PR0501MB2429398983643A6387BE91D0C44C0@VI1PR0501MB2429.eurprd05.prod.outlook.com>
 <CALzJLG_v7kZrioA_VrHT78iatiEOSCp9uWUJFNv1XP6+sMvFzQ@mail.gmail.com> <063D6719AE5E284EB5DD2968C1650D6DB027C806@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daniel Jurgens <danielj@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:35193 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752359AbdBFO0c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 09:26:32 -0500
Received: by mail-qt0-f195.google.com with SMTP id s58so15016903qtc.2
        for <netdev@vger.kernel.org>; Mon, 06 Feb 2017 06:26:31 -0800 (PST)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB027C806@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 6, 2017 at 3:50 PM, David Laight <David.Laight@aculab.com> wrote:
> From: Saeed Mahameed
>> Sent: 05 February 2017 11:24
>> On Thu, Feb 2, 2017 at 4:47 PM, Daniel Jurgens <danielj@mellanox.com> wrote:
>> > On 2/1/2017 5:12 AM, David Laight wrote:
>> >> From: Saeed Mahameed
>> >>> Sent: 31 January 2017 20:59
>> >>> From: Daniel Jurgens <danielj@mellanox.com>
>> >>>
>> >>> There is a hardware feature that will pad the start or end of a DMA to
>> >>> be cache line aligned to avoid RMWs on the last cache line. The default
>> >>> cache line size setting for this feature is 64B. This change configures
>> >>> the hardware to use 128B alignment on systems with 128B cache lines.
>> >> What guarantees that the extra bytes are actually inside the receive skb's
>> >> head and tail room?
>> >>
>> >>       David
>> >>
>> >>
>> > The hardware won't over write the length of the posted buffer.  This feature is already enabled and
>> defaults to 64B stride, this patch just configures it properly for 128B cache line sizes.
>> >
>> Right, and next patch will make sure RX stride is aligned to 128B in
>> case 128B cacheline size configured into the HW.
>
> Doesn't that mean these patches are in the wrong order?
>

Right, will fix that

>> > Thanks for reviewing it.
>
> Don't assume I've done anything other than look for obvious fubars/
>
>         David
>
