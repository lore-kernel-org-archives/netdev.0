From: Boian Bonev <bbonev@ipacct.com>
Subject: Re: RFC EOIP Tunnel
Date: Wed, 22 May 2013 03:29:10 +0300
Message-ID: <CAD53P8AHEm0Q1gFcaL=WVqc65gKNkc+yEbLSi8qW-iLaNxjWQA@mail.gmail.com>
References: <CAD53P8CY9SFvsrhiZqpxT=P5PtjbqL4LG1tf3O8jpU0yrychUw@mail.gmail.com>
 <20130520230852.GB12098@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Boian Bonev <bbonev@ipacct.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:57926 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752683Ab3EVA3l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 May 2013 20:29:41 -0400
Received: by mail-ie0-f175.google.com with SMTP id s9so3571541iec.6
        for <netdev@vger.kernel.org>; Tue, 21 May 2013 17:29:40 -0700 (PDT)
In-Reply-To: <20130520230852.GB12098@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

> Actually, I does get used in BSD land. I have seen several setups some time
> ago where gif interfaces got added to a bridge interface, which behaves like
> EtherIP then. Prior to FreeBSD 8 they reversed the bytes of the version field
> so they still have to provide knobs for backwards compatibility.

In FreeBSD the same thing is implemented as netgraph node...

>> Before going in technical details and submitting patches I want to
>> know opinions if this work is suitable for merging upstream or is
>> better to be kept as a side kernel patch project.
>
> If the side kernel patch has matured and you are fine with it just propose it
> to get merged.

It is mature enough for the 3.2 series kernels (but obviously this is
not ok for submitting). Since then tunnels have got refactored to have
common code in a single place used by all tunnels and also GRE GSO
support was added. I am not very confident if I can get the GSO part
the right way and properly test it...

Thanks for the pointers - will follow your advice and submit a patch.

>> ps. https://github.com/bbonev/eoip contains 3.2.x patches + somehow
>> working but quite crappy config tool
>
> Configuration should be done by iproute.

This is my plan. The config tool is more like a proof of concept thing.

With best regards,
b.
