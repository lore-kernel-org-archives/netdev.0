From: Vincent Li <vincent.mc.li@gmail.com>
Subject: Re: Force ACK each received tcp segment under no condition
Date: Fri, 24 Jan 2014 15:47:59 -0800
Message-ID: <CAK3+h2yCaFDixGk_FDE2x2POyoHYXjJo4h+8-TqM3-0dfAf4-A@mail.gmail.com>
References: <CAK3+h2wd5gEp9oDMZpte-Ed2M3eGSzdkuMJuvk24p=9JcjAzAg@mail.gmail.com>
	<20140124232547.GS7269@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Vincent Li <vincent.mc.li@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:53173 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750872AbaAXXr7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jan 2014 18:47:59 -0500
Received: by mail-ob0-f178.google.com with SMTP id wn1so4306694obc.37
        for <netdev@vger.kernel.org>; Fri, 24 Jan 2014 15:47:59 -0800 (PST)
In-Reply-To: <20140124232547.GS7269@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I tried 'TCP_QUICKACK' with libhttpd.c in thttpd, seems no effect,
that is why I want to go to the extreme route to make it in kernel to
do that always, there is really no good reason for this, I just want
to test the effect of ACK each segment under no condition in my
personal lab for some effect i am looking for.

Vincent

On Fri, Jan 24, 2014 at 3:25 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> On Fri, Jan 24, 2014 at 03:18:19PM -0800, Vincent Li wrote:
>> I know this sounds really silly, but I would like to do such test to
>> meet my curiosity. is that all I need to do?
>
> Isn't quick ack mode what you're looking for (bcefe17cffd "tcp:
> introduce a per-route knob for quick ack"), also settable per setsockopt
> TCP_QUICKACK?
>
> Greetings,
>
>   Hannes
>
