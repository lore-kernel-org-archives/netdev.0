From: Cong Wang <cwang@twopensource.com>
Subject: Re: route/max_size sysctl in ipv4
Date: Fri, 9 Jan 2015 10:47:37 -0800
Message-ID: <CAHA+R7Ps2_+5NgjE8HNbrTxbjhtt4nJyK9y5HrbHez2PhZEiPQ@mail.gmail.com>
References: <CAOxq_8NdxBScZ182bXs5KmTZLKRMeF3AVt+DJNFUff42gaZG4w@mail.gmail.com>
	<20150105.193614.1827024424476781168.davem@davemloft.net>
	<CAOxq_8OtQ0WD-PKBd4kX0JwZiaStqJ-cQiQRhWnTAK9Q0JquxA@mail.gmail.com>
	<20150105.195128.794605376092864881.davem@davemloft.net>
	<CAOxq_8MoPocarmhdXQOkc=4HfGh1L+5-ozEdwPzn2K8q4Gh55w@mail.gmail.com>
	<CAOxq_8PeZFGGsHoT7Ef0gJezV=UikMQqM0UvQZQcpOywxBOy4w@mail.gmail.com>
	<1420683594.5947.43.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAOxq_8Pp7fwsV3Y+-LNheziQzP8FXqT3ohgMt7SeEs6+nuGxMg@mail.gmail.com>
	<1420695665.5947.44.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAOxq_8OPj4twFg2U93hFNSjeiZ5We5DgeCo-W5hSbXJvQmZfyQ@mail.gmail.com>
	<1420743808.5947.73.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAOxq_8M=Ros56U_VbUVumjS226jHs1DK0A-K9aRksTMu88H_sg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ani Sinha <ani@arista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f173.google.com ([209.85.216.173]:61156 "EHLO
	mail-qc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752338AbbAISrh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2015 13:47:37 -0500
Received: by mail-qc0-f173.google.com with SMTP id i17so10541583qcy.4
        for <netdev@vger.kernel.org>; Fri, 09 Jan 2015 10:47:37 -0800 (PST)
In-Reply-To: <CAOxq_8M=Ros56U_VbUVumjS226jHs1DK0A-K9aRksTMu88H_sg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 8, 2015 at 12:13 PM, Ani Sinha <ani@arista.com> wrote:
> On Thu, Jan 8, 2015 at 11:03 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>>
>> If you want to use network namespaces, you have to adapt your scripts.
>>
>> Nobody claimed network namespaces were totally transparent.
>>
>
> I see. I am going back to an old thread here where Linus says that the
> #1 rule is:
>
> ""We don't regress user space"
>
> https://lkml.org/lkml/2013/7/16/565
>
> Breaking scripts seems to me to fall into the category of regressing
> userspace. Or may be we can treat these sysctls more softly since they
> are not strictly speaking linux ABIs.

As Eric said, it has been like this since day 0, why you still think
we break something? It is you who misunderstands the interface
not us who break your script.
