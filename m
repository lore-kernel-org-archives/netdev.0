From: Aaron Sethman <androsyn@ratbox.org>
Subject: Re: qfe problems on x86
Date: Tue, 23 Apr 2002 08:11:41 -0400 (EDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.44.0204230810430.7811-100000@simon.ratbox.org>
References: <20020423.044301.71627636.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20020423.044301.71627636.davem@redhat.com>
List-Id: netdev.vger.kernel.org

This is actually a single cpu Pentium 150 with 96MB ram, compiled
uniprocessor of course.

Regards,

Aaron

On Tue, 23 Apr 2002, David S. Miller wrote:

>    From: Aaron Sethman <androsyn@ratbox.org>
>    Date: Tue, 23 Apr 2002 08:07:25 -0400 (EDT)
>
>    You are correct, I was still doing this from my experiences with 2.4.18.
>    It came up with 08:00:20:f4:0d:34-7.  I tried it again without setting the
>    macaddr, same thing with it hanging after pinging it from another host.
>
>    What is strange is that I can ping the gateway just fine, and all the
>    sudden it stops right when I ping it from elsewhere.
>
> Can you turn on spin lock debugging for the 2.4.19-preX case?
> I bet that will catch what locks it up.
>
> You said this is an SMP box right?
>

