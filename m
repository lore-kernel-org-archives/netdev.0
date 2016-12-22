From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net] net, sched: fix soft lockup in tc_classify
Date: Thu, 22 Dec 2016 09:50:54 -0800
Message-ID: <585C127E.7040509@gmail.com>
References: <585ADFEB.3030206@iogearbox.net>
 <CAM_iQpUEUmJpjQYV7HV+4NVtGe6D-yZs6=YizcDtf7dogkNR0Q@mail.gmail.com>
 <585AEF24.4070800@iogearbox.net>
 <20161222.115326.376675148706578174.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, shahark@mellanox.com,
        gerlitz.or@gmail.com, roid@mellanox.com, jiri@mellanox.com,
        netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:34501 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1765581AbcLVRvL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Dec 2016 12:51:11 -0500
Received: by mail-pg0-f67.google.com with SMTP id b1so20792896pgc.1
        for <netdev@vger.kernel.org>; Thu, 22 Dec 2016 09:51:11 -0800 (PST)
In-Reply-To: <20161222.115326.376675148706578174.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-12-22 08:53 AM, David Miller wrote:
> From: Daniel Borkmann <daniel@iogearbox.net>
> Date: Wed, 21 Dec 2016 22:07:48 +0100
> 
>> Ok, you mean for net. In that case I prefer the smaller sized fix to
>> be honest. It also covers everything from the point where we fetch
>> the chain via cops->tcf_chain() to the end of the function, which is
>> where most of the complexity resides, and only the two mentioned
>> commits do the relock, so as a fix I think it's fine as-is. As
>> mentioned, if there's need to refactor tc_ctl_tfilter() net-next
>> would be better, imho.
> 
> Please, can you two work towards an agreement as to what fix should
> go in at this time?
> 
> Thanks.
> 

Thanks for fixing this!

I have a slight preference to push this patch into net as its been
tested already by Shahar and is not particularly invasive. Then for
net-next do a larger cleanup to get rid of some of the complexity per
Cong's suggestion.

.John
