From: "Satendra..." <satendra.pratap@gmail.com>
Subject: Re: 802.1ad on linux
Date: Fri, 29 Jul 2011 11:24:21 +0530
Message-ID: <CAChS5kPtnG_adb5DMdX5D+QogAQ57_2X+d4Lo3tToHS0wjaiNw@mail.gmail.com>
References: <CAChS5kM+xmWRrF-Ez7W9+=7Se9o3bXrk4sSs6X-z7gU21SaWrA@mail.gmail.com>
	<201107281321.46294.jens@linux.vnet.ibm.com>
	<20110728124830.GA2144046@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jens Osterkamp <jens@linux.vnet.ibm.com>, netdev@vger.kernel.org
To: David Lamparter <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:45915 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753436Ab1G2FyW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jul 2011 01:54:22 -0400
Received: by vxh35 with SMTP id 35so2429071vxh.19
        for <netdev@vger.kernel.org>; Thu, 28 Jul 2011 22:54:21 -0700 (PDT)
In-Reply-To: <20110728124830.GA2144046@jupiter.n2.diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Jens and David.
David, could you give little idea about how you are testing your changes?
I mean is there any test suite used (may be third party) ?

On 28 July 2011 18:18, David Lamparter <equinox@diac24.net> wrote:
> On Thu, Jul 28, 2011 at 01:21:46PM +0200, Jens Osterkamp wrote:
>> On Thursday 28 July 2011, Satendra... wrote:
>> > Hi,
>> >
>> > Does linux kernel has support for 802.1ad ? if yes could u plz mention
>> > the version?
>>
>> No, but David Lamparter has just recently posted patches which implement this.
>>
>> http://marc.info/?l=linux-netdev&m=131093613717022&w=2
>>
>> They work fine for me on top of net-next. I had to add EXPORT_SYMBOL for
>> vlan_untag and vlan_do_receive to be able to build as a module.
>> You will need his patch for iproute2 as well to be able to create 802.1ad
>> VLAN devices.
>
> I will be rebasing them onto current net-next HEAD this weekend. With
> the VLAN cleanup in, some bits changed; I'll also do some reordering to
> fix those symbols.
>
>
> -David
>
>
