From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH v4 0/10] bql: Byte Queue Limits
Date: Tue, 29 Nov 2011 10:31:03 -0800
Message-ID: <CA+mtBx_-_4zzweT61vYKe-c8ngMO9jF5PoYa4gC1aNKREjbwgQ@mail.gmail.com>
References: <alpine.DEB.2.00.1111281825200.25622@pokey.mtv.corp.google.com>
	<1322585184.2465.36.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<20111129.124715.163094087536706067.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:48610 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756086Ab1K2SbE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 13:31:04 -0500
Received: by iage36 with SMTP id e36so10972432iag.19
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2011 10:31:04 -0800 (PST)
In-Reply-To: <20111129.124715.163094087536706067.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 29, 2011 at 9:47 AM, David Miller <davem@davemloft.net> wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 29 Nov 2011 17:46:24 +0100
>
>> I did sucessful tests with tg3 (I'll provide the patch for bnx2 shortly)
>>
>> Some details probably can be polished, but I believe your v4 is ready
>> for inclusion.
>>
>> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
>
> Agreed, all applied to net-next, thanks!
>
> Tom, please keep an eye out for regression or suggestion reports.
>

Will do.  I am well aware of how invasive this is in the data path ;-)
 I'll add a doc describing BQL also.

By the way, the way to disable BQL at runtime is the 'echo max >
/sys/class/net/eth<n>/queues/tx-<m>/byte_queue_limits/limit_min

> Thanks again.
>

Thanks Dave, Eric, Dave Taht, and everyone for reviewing this.

Tom
