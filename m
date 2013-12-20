From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next] net_sched: fix a regression in tc actions
Date: Fri, 20 Dec 2013 10:49:27 -0800
Message-ID: <CAM_iQpU_G5oxNf5XD06rko9+Vc1dHvxw-Qm2BRBp7kxqGcBp-w@mail.gmail.com>
References: <1387526931-21814-1-git-send-email-xiyou.wangcong@gmail.com>
	<52B434FA.8080309@mojatatu.com>
	<1387550222.19078.434.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f42.google.com ([209.85.219.42]:62701 "EHLO
	mail-oa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754589Ab3LTSt2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 13:49:28 -0500
Received: by mail-oa0-f42.google.com with SMTP id i4so3300820oah.1
        for <netdev@vger.kernel.org>; Fri, 20 Dec 2013 10:49:28 -0800 (PST)
In-Reply-To: <1387550222.19078.434.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 20, 2013 at 6:37 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2013-12-20 at 07:15 -0500, Jamal Hadi Salim wrote:
>> On 12/20/13 03:08, Cong Wang wrote:
>> > This patch fixes:
>> > 1) pass mask rather than size to tcf_hashinfo_init()
>> > 2) the cleanup should be in reversed order in mirred_cleanup_module()
>> >
>> > Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
>> > Fixes: 369ba56787d7469c0afd ("net_sched: init struct tcf_hashinfo at register time")
>> > Cc: Eric Dumazet <eric.dumazet@gmail.com>
>> > Cc: David S. Miller <davem@davemloft.net>
>> > Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>> >
>>
>> Please Cc me - my filters will catch it faster.
>>
>> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
>
> This doesn't fix the issue, as I said earlier


When did I say I fixed it? :) Below is what I said:

> I just sent a fix for the problem I see, not sure it fixes
> the bug you reported too.
>
> I will test it as a module tomorrow, if you don't send a fix
> before that.

Thanks.
