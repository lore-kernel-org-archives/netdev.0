From: Ani Sinha <ani@arista.com>
Subject: Re: route/max_size sysctl in ipv4
Date: Thu, 8 Jan 2015 10:39:37 -0800
Message-ID: <CAOxq_8OPj4twFg2U93hFNSjeiZ5We5DgeCo-W5hSbXJvQmZfyQ@mail.gmail.com>
References: <CAOxq_8NdxBScZ182bXs5KmTZLKRMeF3AVt+DJNFUff42gaZG4w@mail.gmail.com>
 <20150105.193614.1827024424476781168.davem@davemloft.net> <CAOxq_8OtQ0WD-PKBd4kX0JwZiaStqJ-cQiQRhWnTAK9Q0JquxA@mail.gmail.com>
 <20150105.195128.794605376092864881.davem@davemloft.net> <CAOxq_8MoPocarmhdXQOkc=4HfGh1L+5-ozEdwPzn2K8q4Gh55w@mail.gmail.com>
 <CAOxq_8PeZFGGsHoT7Ef0gJezV=UikMQqM0UvQZQcpOywxBOy4w@mail.gmail.com>
 <1420683594.5947.43.camel@edumazet-glaptop2.roam.corp.google.com>
 <CAOxq_8Pp7fwsV3Y+-LNheziQzP8FXqT3ohgMt7SeEs6+nuGxMg@mail.gmail.com> <1420695665.5947.44.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:51235 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755295AbbAHSj6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2015 13:39:58 -0500
Received: by mail-ig0-f171.google.com with SMTP id z20so4217114igj.4
        for <netdev@vger.kernel.org>; Thu, 08 Jan 2015 10:39:58 -0800 (PST)
In-Reply-To: <1420695665.5947.44.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 7, 2015 at 9:41 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2015-01-07 at 19:40 -0800, Ani Sinha wrote:
>
>> true but at least those scripts which does only read the values will
>> continue to function in a child namespace. In our case, our script
>> only reads the max_size sysctl but since it operates from within a
>> child namespace, it doesn't find it.
>>
>> thoughts?
>
> Fix your script,

But the whole point of keeping this sysctl still around is not to
break the userland scripts! If we are trying to achieve that, I think
we should go one step further and make sure that the sysctl is still
available for reading even in child namespaces (as it used to be the
case).
