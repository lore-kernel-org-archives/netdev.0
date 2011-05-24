From: =?UTF-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong@gmail.com>
Subject: Re: [RFC Patch] bonding: move to net/ directory
Date: Tue, 24 May 2011 22:00:23 +0800
Message-ID: <BANLkTikT2HJyGb_4BOF+Ds1AAcJV+HVQ-w@mail.gmail.com>
References: <BANLkTimkxi0BofJYv_tRj8Et+OZFu+VfBw@mail.gmail.com>
	<20110523151336.GF21309@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jay Vosburgh <fubar@us.ibm.com>
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:41994 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756327Ab1EXOAY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2011 10:00:24 -0400
Received: by iyb14 with SMTP id 14so5269295iyb.19
        for <netdev@vger.kernel.org>; Tue, 24 May 2011 07:00:23 -0700 (PDT)
In-Reply-To: <20110523151336.GF21309@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 23, 2011 at 11:13 PM, Andy Gospodarek <andy@greyhouse.net> =
wrote:
> On Mon, May 23, 2011 at 08:45:14PM +0800, Am=C3=A9rico Wang wrote:
>> Hello, Jay, Andy,
>>
>> Is there any peculiar reason that bonding code has to stay
>> in drivers/net/ directory?
>>
>> Since bonding and bridge are somewhat similar, both of
>> which are used to "bond" two or more devices into one,
>> and bridge code is already in net/bridge/, so I think it also
>> makes sense to move bonding code into net/bonding/ too.
>>
>> This could also help to grep the source more easily. :)
>>
>> What do you think about the patch below?
>> (Note, this patch is against net-next-2.6.)
>>
>
> I would rather keep the code for bonding in drivers/net since it is
> really a pure device (though not directly tied to any specific
> hardware) rather than a device + forwarding or management code.

Is this a reason strong enough to leave it to drivers/net/ ?
I think it is generic enough to be moved to net/ directory... :-/

>
> It has bothered me for a long time that the code just to manage the V=
LAN
> and bridge devices sits outside of drivers/net, but I've never propos=
ed
> a patch to move the files as I suspect the maintainers of that code
> would like to keep it all together. =C2=A0Maybe it is time to do that=
=2E
>

You mean move net/8021q/ to drivers/net/8021q/ ?

Thanks!
