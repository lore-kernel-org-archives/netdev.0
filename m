From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v3 net-next] pktgen: introduce 'rx' mode
Date: Tue, 05 May 2015 11:30:06 -0700
Message-ID: <55490C2E.5000702@plumgrid.com>
References: <1430457130-16003-1-git-send-email-ast@plumgrid.com>	<20150502104621.4fede885@redhat.com>	<5544F4D7.50202@plumgrid.com>	<20150502184625.25426091@redhat.com>	<55450464.8060109@plumgrid.com> <20150505201546.0f998668@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	Robert Olsson <robert@herjulf.net>,
	Ben Greear <greearb@candelatech.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:35255 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752842AbbEESaJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 14:30:09 -0400
Received: by ieczm2 with SMTP id zm2so9906591iec.2
        for <netdev@vger.kernel.org>; Tue, 05 May 2015 11:30:08 -0700 (PDT)
In-Reply-To: <20150505201546.0f998668@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/5/15 11:15 AM, Jesper Dangaard Brouer wrote:
>
> On Sat, 02 May 2015 10:07:48 -0700 Alexei Starovoitov <ast@plumgrid.com> wrote:
>> On 5/2/15 9:46 AM, Jesper Dangaard Brouer wrote:
> [...]
>>
>> all makes sense.
>> btw, I'm off the grid till Monday and it sounds like you see concrete
>> spots in the code to hack this stuff in, so if you want to take over,
>> please go ahead :)
>
> Okay, I'll address my own concerns and post a patch in your name("From:")

lol :) I seriously don't care about commit count.
Thank you for taking over.
I'm swamped with tracing stuff at the moment.

> As I would like to see this feature in pktgen, as it provides a really
> easy and quick way to measure/profile changes in the ingress path...

same here. my motivation for this patch is to have a common tool
to measure ingress speed, so we can have concrete numbers to talk about.
Also, as you mentioned, there is always a danger of 'zooming in'.
Any type of benchmarking shouldn't be blindly followed. At the same time
all numbers are useful. They are different datapoints that make
a complete picture.
