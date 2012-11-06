From: "devendra.aaru" <devendra.aaru@gmail.com>
Subject: Re: how to disable automatic route addition for an ipv6 address
Date: Tue, 6 Nov 2012 06:07:05 -0500
Message-ID: <CAHdPZaMFTS=-82qh7HNha09j1OJnvc43OWmzhXatqe-e2F4_sQ@mail.gmail.com>
References: <CAHdPZaPt-ybmZiS5uzdos6OYC2q8BBmFfSgSQ0RnOe4AnPpcdA@mail.gmail.com>
	<alpine.DEB.2.00.1211060755510.13802@uplift.swm.pp.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Mikael Abrahamsson <swmike@swm.pp.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:43948 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750706Ab2KFLHF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Nov 2012 06:07:05 -0500
Received: by mail-pa0-f46.google.com with SMTP id hz1so254698pad.19
        for <netdev@vger.kernel.org>; Tue, 06 Nov 2012 03:07:05 -0800 (PST)
In-Reply-To: <alpine.DEB.2.00.1211060755510.13802@uplift.swm.pp.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 6, 2012 at 2:01 AM, Mikael Abrahamsson <swmike@swm.pp.se> wrote:
> On Mon, 5 Nov 2012, devendra.aaru wrote:
>
>> while adding the ipv6 address to interface ,
>>
>> ifconfig eth0 add 2001:8800:10fb:4444::ae/64
>>
>> i am seeing the route addition automatically
>>
>> route -n -A inet6 shows that one of the route from the above added
>> address.
>
>
> You mean you get a /64 route to the interface? I'd say that's normal, as
> you're adding a /64.
>
> If you do not want this, add it as a /128 instead.
>
> "ip -6 a a dev eth0 2000:db8::1/128" will add just that /128 to eth0
> interface without an encompassing network route.
>
> "ip -6 r l" to verify (you will see just the IPv6 address to the device, ie
> an implicit /128).
>
Thanks a lot Mikael, i will give a try :-)
> --
> Mikael Abrahamsson    email: swmike@swm.pp.se
