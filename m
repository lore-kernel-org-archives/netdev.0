From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: route/max_size sysctl in ipv4
Date: Thu, 08 Jan 2015 11:03:28 -0800
Message-ID: <1420743808.5947.73.camel@edumazet-glaptop2.roam.corp.google.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ani Sinha <ani@arista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:56930 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752041AbbAHTDb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2015 14:03:31 -0500
Received: by mail-ie0-f172.google.com with SMTP id tr6so11124788ieb.3
        for <netdev@vger.kernel.org>; Thu, 08 Jan 2015 11:03:30 -0800 (PST)
In-Reply-To: <CAOxq_8OPj4twFg2U93hFNSjeiZ5We5DgeCo-W5hSbXJvQmZfyQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-01-08 at 10:39 -0800, Ani Sinha wrote:

> But the whole point of keeping this sysctl still around is not to
> break the userland scripts! If we are trying to achieve that, I think
> we should go one step further and make sure that the sysctl is still
> available for reading even in child namespaces (as it used to be the
> case).


network namespaces make some sysctl disappear.

That is how it is since day 0.
Some scripts might even use this knowledge.

It is too late to change something now. Nobody but you ever complained.

If you want to use network namespaces, you have to adapt your scripts.

Nobody claimed network namespaces were totally transparent.
