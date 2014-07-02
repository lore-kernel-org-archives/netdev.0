From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [Linux-zigbee-devel] [PATCH net-next v3] 6lowpan: mac802154: fix
 coding style issues
Date: Tue, 1 Jul 2014 22:07:15 -0700
Message-ID: <CAGVrzcazu+iBWkT2vyTHGbT9orm-2_N=SaY_tthCkMGY8B5RAA@mail.gmail.com>
References: <1404271869-2316-1-git-send-email-varkab@cdac.in>
 <CAGVrzcYc9u2TAxhb8vPOevLYiZUsOyEcUAbxZ4aLrns3Vt97yw@mail.gmail.com>
 <1404276016.14624.57.camel@joe-AO725> <CAGVrzcb6pYdyvuXOrKssjx2fzJqRV=CsdocVNGSSKkEAuUkeYg@mail.gmail.com>
 <1404277090.14624.62.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Varka Bhadram <varkabhadram@gmail.com>,
	netdev <netdev@vger.kernel.org>, Varka Bhadram <varkab@cdac.in>,
	David Miller <davem@davemloft.net>,
	linux-zigbee-devel@lists.sourceforge.net
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f49.google.com ([209.85.219.49]:47997 "EHLO
	mail-oa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751705AbaGBFH4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 01:07:56 -0400
Received: by mail-oa0-f49.google.com with SMTP id i7so11589972oag.22
        for <netdev@vger.kernel.org>; Tue, 01 Jul 2014 22:07:55 -0700 (PDT)
In-Reply-To: <1404277090.14624.62.camel@joe-AO725>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-07-01 21:58 GMT-07:00 Joe Perches <joe@perches.com>:
> On Tue, 2014-07-01 at 21:49 -0700, Florian Fainelli wrote:
>> 2014-07-01 21:40 GMT-07:00 Joe Perches <joe@perches.com>:
>> > On Tue, 2014-07-01 at 21:20 -0700, Florian Fainelli wrote:
>> >> Hi,
>> >>
>> >> 2014-07-01 20:31 GMT-07:00 Varka Bhadram <varkabhadram@gmail.com>:
>> >> > This patch fixed the coding style issues reported by checkpatch.pl
>> >> >
>> >> > following issues fixed:
>> >> >         CHECK: Alignment should match open parenthesis
>> >>
>> >> It seems to me like checkpatch.pl should have a special case for
>> >> networking code and that specific condition because fixing things to
>> >> make checkpatch.pl happy seems not to agree with the general coding
>> >> style recommended and enforced in the networking code.
>> >
>> > In networking (net/ and drivers/net) alignment of multiline statements
>> > _should_ align to the open parenthesis and checkpatch already has a
>> > specific check for those directories.
>> >
>> >> I just saw that new warning added popping up on a bunch of drivers
>> >> that were properly fixed to match the networking coding style before
>> >> submission.
>> >
>> > Is there anything you want changed in checkpatch?
>> > If so, why?
>>
>> It looks to me like it does some improper flagging when the multi-line
>> statements are aligned to the closest tab after the opening
>> parenthesis, e.g:
>>
>> CHECK: Alignment should match open parenthesis
>> #84: FILE: drivers/net/ethernet/broadcom/bcmsysport.c:84:
>> +       __raw_writel(upper_32_bits(addr) & DESC_ADDR_HI_MASK,
>> +                       d + DESC_ADDR_HI_STATUS_LEN);
>>
>> gmail will probably render this incorrectly and does replace tabs with
>> spaces, but if you run the script manually on that specific file, it
>> will return some (false?) positives matches.
>>
>> this is with checkpath.pl from net-next/master at
>> 763e0ecd72fe90fdd73bb1aa1b72caf8381d2fff ("bonding: allow to add vlans
>> on top of empty bond")
>
> No, it's not a false positive.
>
> The code is currently:
>
>         __raw_writel(upper_32_bits(addr) & DESC_ADDR_HI_MASK,
>                         d + DESC_ADDR_HI_STATUS_LEN);
>
> 1st line has 1 leading tab,
> 2nd line has 3 leading tabs
>
> For networking code style, this should be:
>
>         __raw_writel(upper_32_bits(addr) & DESC_ADDR_HI_MASK,
>                      d + DESC_ADDR_HI_STATUS_LEN);
>
> 1st line has 1 leading tab,
> 2nd line has 2 leading tabs followed by 5 leading spaces
>
> This aligns the 2nd line arguments to the position immediately
> after the open parenthesis.

I see, thanks for clarifying, for some reason, I took David's reply
here [1] as use tabs only to align at or after the opening
parenthesis.

[1]: http://thread.gmane.org/gmane.linux.network/313387
-- 
Florian
