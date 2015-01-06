From: Ani Sinha <ani@arista.com>
Subject: Re: route/max_size sysctl in ipv4
Date: Mon, 5 Jan 2015 16:56:18 -0800
Message-ID: <CAOxq_8OysjN8OrvhM13t3YUuyh5O=KM_mptR=NHieq146mqZ8g@mail.gmail.com>
References: <CAOxq_8NdxBScZ182bXs5KmTZLKRMeF3AVt+DJNFUff42gaZG4w@mail.gmail.com>
 <20150105.193614.1827024424476781168.davem@davemloft.net> <CAOxq_8OtQ0WD-PKBd4kX0JwZiaStqJ-cQiQRhWnTAK9Q0JquxA@mail.gmail.com>
 <20150105.195128.794605376092864881.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:34396 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753325AbbAFA4j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2015 19:56:39 -0500
Received: by mail-ig0-f181.google.com with SMTP id a13so302038igq.14
        for <netdev@vger.kernel.org>; Mon, 05 Jan 2015 16:56:38 -0800 (PST)
In-Reply-To: <20150105.195128.794605376092864881.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 5, 2015 at 4:51 PM, David Miller <davem@davemloft.net> wrote:
> From: Ani Sinha <ani@arista.com>
> Date: Mon, 5 Jan 2015 16:43:30 -0800
>
>> On Mon, Jan 5, 2015 at 4:36 PM, David Miller <davem@davemloft.net> wrote:
>>> From: Ani Sinha <ani@arista.com>
>>> Date: Mon, 5 Jan 2015 15:48:11 -0800
>>>
>>>> I am looking at the code and it looks like since the route cache for
>>>> ipv4 was removed from the kernel, this sysctl parameter no longer
>>>> serves the same purpose. It does not look like it is even used in the
>>>> ipv4/route.c module. Is there an equivalent sysctl parameter limiting
>>>> the number of route entries in the kernel? Or is there now no
>>>> mechanism to limit the number of route entries?
>>>
>>> There is nothing to limit, since the cache was removed.
>>
>> Shouldn't the documentation be updated to reflect that? Also what's
>> the point of having a dummy variable that does nothing? Should we not
>> simply remove it?
>
> There is nothing to update, the behavior is completely transparent.
> Absolutely no cache entries exist, therefore the limit cannot be
> reached.

I disagree. You are advertising a feature in an official documentation
that simply does not exist for ipv4. This is very confusing. If I did
not dig into the code, I wouldn't know that this particular knob is a
noop since the time the route cache was removed.


>
> The sysctl is kept so that scripts reading it don't suddenly stop
> working.  We can't just remove sysctl values.
>
