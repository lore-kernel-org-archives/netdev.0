From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch iproute2] u32: add terminal parameter
Date: Tue, 15 Apr 2014 09:00:18 -0400
Message-ID: <534D2D62.5080109@mojatatu.com>
References: <1396631826-15188-1-git-send-email-xiyou.wangcong@gmail.com>	<20140411140446.6412e9dc@nehalam.linuxnetplumber.net>	<CAM_iQpVpNOJ1xiK45qXGRXgBZ2QcmwoPc7p=SOHCo=1kTwPfFQ@mail.gmail.com>	<20140411175800.08e9ffe3@nehalam.linuxnetplumber.net>	<CAM_iQpU7Ntn-yo-ez0vP2BhKe+-Vaq1w_+MQhFPHM-bbQZx2gg@mail.gmail.com>	<534926F7.10505@mojatatu.com>	<CAM_iQpXJnOOUbpS0WwrB7C50LGxcLhMEQPrDB84Zm-SLKVHh6w@mail.gmail.com>	<534C6BDE.8020600@mojatatu.com> <CAM_iQpV8GeEQr+GFFy2Etct_51YhvXEBKydyH9q4NP5QbsDOnA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:62207 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751304AbaDONAj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2014 09:00:39 -0400
Received: by mail-ie0-f170.google.com with SMTP id rd18so9311650iec.1
        for <netdev@vger.kernel.org>; Tue, 15 Apr 2014 06:00:38 -0700 (PDT)
In-Reply-To: <CAM_iQpV8GeEQr+GFFy2Etct_51YhvXEBKydyH9q4NP5QbsDOnA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/14/14 21:57, Cong Wang wrote:

> So essentially why u32 filters can't just do matching without bothering

u32 is a special animal. You can actually have intermediate nodes
which are _not_ terminal. i.e you can build a tree of hashes which
interconnect other hashes eventually leading to terminal nodes.

> classid especially when they are attached to an ingress qdisc? I still
> fail to see a reason why I have to care about classid here.

It is more of a historical artifact with "benefits".
Historical in that egress qdiscs with classes existed before ingress;
so it makes sense to keep the syntax people are already familiar with.
Benefits because infact with the right approach the flowid even at
ingress can be used as input(look at the route classifier for example
and association with route accounting of the source).


cheers,
jamal
