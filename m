From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [Patch net-next 1/2] net_sched: fix errno in tcindex_set_parms()
Date: Thu, 25 Sep 2014 15:57:29 -0700
Message-ID: <54249DD9.5060403@gmail.com>
References: <1411671965-18887-1-git-send-email-xiyou.wangcong@gmail.com> <5424842A.60802@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org,
	davem@davemloft.net
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f180.google.com ([209.85.214.180]:61547 "EHLO
	mail-ob0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752520AbaIYW67 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2014 18:58:59 -0400
Received: by mail-ob0-f180.google.com with SMTP id wn1so8688146obc.39
        for <netdev@vger.kernel.org>; Thu, 25 Sep 2014 15:58:58 -0700 (PDT)
In-Reply-To: <5424842A.60802@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/25/2014 02:07 PM, John Fastabend wrote:
> On 09/25/2014 12:06 PM, Cong Wang wrote:
>> When kmemdup() fails, we should return -ENOMEM.
>>
>> Cc: John Fastabend <john.fastabend@gmail.com>
>> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>> ---
>
> Acked-by: John Fastabend <john.r.fastabend@intel.com>
>
> Thanks Cong.
>

Related to this we should probably push error messages
from the dump routines correctly. If you see u32_dump()
returns a -EINVAL even though it was due to a memory
allocation failure. This is not necessarily due to my
patches though I think the error returning from dump
has always been a simple -1 value.

I'll take a look at it, unless you beat me to it, after
I finish up the percpu stats which I'm doing now.

.John

-- 
John Fastabend         Intel Corporation
