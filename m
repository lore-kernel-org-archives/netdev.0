From: Ani Sinha <ani@arista.com>
Subject: Re: route/max_size sysctl in ipv4
Date: Thu, 8 Jan 2015 12:13:11 -0800
Message-ID: <CAOxq_8M=Ros56U_VbUVumjS226jHs1DK0A-K9aRksTMu88H_sg@mail.gmail.com>
References: <CAOxq_8NdxBScZ182bXs5KmTZLKRMeF3AVt+DJNFUff42gaZG4w@mail.gmail.com>
 <20150105.193614.1827024424476781168.davem@davemloft.net> <CAOxq_8OtQ0WD-PKBd4kX0JwZiaStqJ-cQiQRhWnTAK9Q0JquxA@mail.gmail.com>
 <20150105.195128.794605376092864881.davem@davemloft.net> <CAOxq_8MoPocarmhdXQOkc=4HfGh1L+5-ozEdwPzn2K8q4Gh55w@mail.gmail.com>
 <CAOxq_8PeZFGGsHoT7Ef0gJezV=UikMQqM0UvQZQcpOywxBOy4w@mail.gmail.com>
 <1420683594.5947.43.camel@edumazet-glaptop2.roam.corp.google.com>
 <CAOxq_8Pp7fwsV3Y+-LNheziQzP8FXqT3ohgMt7SeEs6+nuGxMg@mail.gmail.com>
 <1420695665.5947.44.camel@edumazet-glaptop2.roam.corp.google.com>
 <CAOxq_8OPj4twFg2U93hFNSjeiZ5We5DgeCo-W5hSbXJvQmZfyQ@mail.gmail.com> <1420743808.5947.73.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:60093 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751828AbbAHUNc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2015 15:13:32 -0500
Received: by mail-ie0-f171.google.com with SMTP id ar1so11503333iec.2
        for <netdev@vger.kernel.org>; Thu, 08 Jan 2015 12:13:32 -0800 (PST)
In-Reply-To: <1420743808.5947.73.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 8, 2015 at 11:03 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:

>
> It is too late to change something now. Nobody but you ever complained.

Well, that is a strange argument! Nobody complained for a long time
that live capturing with vlan tagged packets were broken in tcpdump
because how the kernel started putting the tags in the aux data. But
someone eventually one day did notice that the issue was brought up.

>
> If you want to use network namespaces, you have to adapt your scripts.
>
> Nobody claimed network namespaces were totally transparent.
>

I see. I am going back to an old thread here where Linus says that the
#1 rule is:

""We don't regress user space"

https://lkml.org/lkml/2013/7/16/565

Breaking scripts seems to me to fall into the category of regressing
userspace. Or may be we can treat these sysctls more softly since they
are not strictly speaking linux ABIs.
