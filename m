From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: RFC EOIP Tunnel
Date: Tue, 21 May 2013 22:20:22 -0700
Message-ID: <CAOaVG14pvJzsiN4u0Ay9e+6nC=OWXmBVP-M5sUVvQyYj8jWi=g@mail.gmail.com>
References: <CAD53P8CY9SFvsrhiZqpxT=P5PtjbqL4LG1tf3O8jpU0yrychUw@mail.gmail.com>
	<20130520230852.GB12098@order.stressinduktion.org>
	<CAD53P8AHEm0Q1gFcaL=WVqc65gKNkc+yEbLSi8qW-iLaNxjWQA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>
To: Boian Bonev <bbonev@ipacct.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f176.google.com ([209.85.128.176]:42950 "EHLO
	mail-ve0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750993Ab3EVFUX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 May 2013 01:20:23 -0400
Received: by mail-ve0-f176.google.com with SMTP id jz10so1123779veb.35
        for <netdev@vger.kernel.org>; Tue, 21 May 2013 22:20:22 -0700 (PDT)
In-Reply-To: <CAD53P8AHEm0Q1gFcaL=WVqc65gKNkc+yEbLSi8qW-iLaNxjWQA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rather than burdening the kernel maintainers with a proprietary
protocol that is non-standard. Why not just clean up the user space
implementation, and use tun like OpenVPN etc.

IMHO Mikrotik is violating GPL by having modules that claim to be GPL
and not releasing source. Plus modifying GRUB to do license
enforcement violates the intent of GPL as well.


On Tue, May 21, 2013 at 5:29 PM, Boian Bonev <bbonev@ipacct.com> wrote:
> Hi,
>
>> Actually, I does get used in BSD land. I have seen several setups some time
>> ago where gif interfaces got added to a bridge interface, which behaves like
>> EtherIP then. Prior to FreeBSD 8 they reversed the bytes of the version field
>> so they still have to provide knobs for backwards compatibility.
>
> In FreeBSD the same thing is implemented as netgraph node...
>
>>> Before going in technical details and submitting patches I want to
>>> know opinions if this work is suitable for merging upstream or is
>>> better to be kept as a side kernel patch project.
>>
>> If the side kernel patch has matured and you are fine with it just propose it
>> to get merged.
>
> It is mature enough for the 3.2 series kernels (but obviously this is
> not ok for submitting). Since then tunnels have got refactored to have
> common code in a single place used by all tunnels and also GRE GSO
> support was added. I am not very confident if I can get the GSO part
> the right way and properly test it...
>
> Thanks for the pointers - will follow your advice and submit a patch.
>
>>> ps. https://github.com/bbonev/eoip contains 3.2.x patches + somehow
>>> working but quite crappy config tool
>>
>> Configuration should be done by iproute.
>
> This is my plan. The config tool is more like a proof of concept thing.
>
> With best regards,
> b.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
