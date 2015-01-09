From: Ani Sinha <ani@arista.com>
Subject: Re: route/max_size sysctl in ipv4
Date: Fri, 9 Jan 2015 13:23:59 -0800
Message-ID: <CAOxq_8MWLd1pV1KmgQdokswgO4qTfcDLCnF9jQTo-si6+caZag@mail.gmail.com>
References: <CAOxq_8NdxBScZ182bXs5KmTZLKRMeF3AVt+DJNFUff42gaZG4w@mail.gmail.com>
 <20150105.193614.1827024424476781168.davem@davemloft.net> <CAOxq_8OtQ0WD-PKBd4kX0JwZiaStqJ-cQiQRhWnTAK9Q0JquxA@mail.gmail.com>
 <20150105.195128.794605376092864881.davem@davemloft.net> <CAOxq_8MoPocarmhdXQOkc=4HfGh1L+5-ozEdwPzn2K8q4Gh55w@mail.gmail.com>
 <CAOxq_8PeZFGGsHoT7Ef0gJezV=UikMQqM0UvQZQcpOywxBOy4w@mail.gmail.com>
 <1420683594.5947.43.camel@edumazet-glaptop2.roam.corp.google.com>
 <CAOxq_8Pp7fwsV3Y+-LNheziQzP8FXqT3ohgMt7SeEs6+nuGxMg@mail.gmail.com>
 <1420695665.5947.44.camel@edumazet-glaptop2.roam.corp.google.com>
 <CAOxq_8OPj4twFg2U93hFNSjeiZ5We5DgeCo-W5hSbXJvQmZfyQ@mail.gmail.com>
 <1420743808.5947.73.camel@edumazet-glaptop2.roam.corp.google.com>
 <CAOxq_8M=Ros56U_VbUVumjS226jHs1DK0A-K9aRksTMu88H_sg@mail.gmail.com>
 <CAHA+R7Ps2_+5NgjE8HNbrTxbjhtt4nJyK9y5HrbHez2PhZEiPQ@mail.gmail.com>
 <CAOxq_8Na14ES1souk-jBa8A=9ArHc-ffRtSd36zbvwHvGM+24Q@mail.gmail.com> <CAHA+R7Pi=87b_umrKnd4bsZ+DPkRoTWhNyPwAND5pDzF_3EDaQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:54565 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751217AbbAIVYU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2015 16:24:20 -0500
Received: by mail-ig0-f181.google.com with SMTP id a13so3835210igq.2
        for <netdev@vger.kernel.org>; Fri, 09 Jan 2015 13:24:20 -0800 (PST)
In-Reply-To: <CAHA+R7Pi=87b_umrKnd4bsZ+DPkRoTWhNyPwAND5pDzF_3EDaQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 9, 2015 at 11:37 AM, Cong Wang <cwang@twopensource.com> wrote:
> On Fri, Jan 9, 2015 at 11:08 AM, Ani Sinha <ani@arista.com> wrote:
>>
>> Perhaps. What I am truly confused about is :
>>
>> - We are keeping a sysctl interface that does absolutely nothing in
>> the kernel and is completely useless in case some userland
>> scripts/tools are rendered broken from it's removal.
>
> I am all for getting rid of it, sane script should always check
> the sysctl existence first. I think we did remove some sysctl's
> from kernel before.

I'd be much happier if things break uniformly everywhere - within and
outside namespaces. Besides, keeping a useless sysctl around that does
nothing is confusing and error prone, to say the least.

If we do decide to keep the sysctl around, I beg that we at least
update the documentation to reflect the true fact. I have already sent
a patch for this.
