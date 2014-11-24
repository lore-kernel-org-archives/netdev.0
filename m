From: Josh Clark <jcinma@gmail.com>
Subject: Re: qstats update in packet scheduling
Date: Mon, 24 Nov 2014 13:17:01 -0500
Message-ID: <CAHmvzZRwsd7S+T4cdAVzWGORcbkq+WWMtFAV6Ss3UrA+Ogeujg@mail.gmail.com>
References: <CAHmvzZQnBJbx3hfdvpXg0TZM-UooKxjM+-1HO6nSSpx4qJLcaw@mail.gmail.com>
 <1416850289.17888.67.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:35177 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753430AbaKXSRn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2014 13:17:43 -0500
Received: by mail-wi0-f182.google.com with SMTP id h11so6710977wiw.15
        for <netdev@vger.kernel.org>; Mon, 24 Nov 2014 10:17:42 -0800 (PST)
In-Reply-To: <1416850289.17888.67.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 24, 2014 at 12:31 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Mon, 2014-11-24 at 12:06 -0500, Josh Clark wrote:
>> Hi everyone,
>>
>> I'm working on a research project to add some extra functionality to
>> RED. Right now, I'm tracking qstats to look at the factors that RED
>> uses to calculate marking probability. Using standard RED with printk
>> debug statements, I'm seeing that there are some drops, but no change
>> in qlen or backlog when I send 12Mbps through a 10Mbps link.
>>
>> Does RED use some other means to update qstats and track backlog, or
>> do I need to change how I'm sending the test traffic though?
>
> With steady traffic, there is no reason qlen should vary.
>
> It should reach some equilibrium as well.
>
But I'm seeing no change at all in qlen. qlen and backlog are both
zero, which results in zero qavg, meaning I can't test the RED
functionality at all.
