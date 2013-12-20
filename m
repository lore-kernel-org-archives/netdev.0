From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH 2/2] net_sched: optimize tcf_match_indev()
Date: Fri, 20 Dec 2013 00:12:25 -0800
Message-ID: <CAM_iQpX-Ghj8K-3i4ph+ArugbxjoyZiYDkc1jxBEE+YjmYv3eg@mail.gmail.com>
References: <1387503292-20078-1-git-send-email-xiyou.wangcong@gmail.com>
	<1387503292-20078-2-git-send-email-xiyou.wangcong@gmail.com>
	<1387520573.19078.424.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAM_iQpWA2qjjEV97SFajg0Y_0WnWAY2qPY9_7vSuFVuYq5tH6Q@mail.gmail.com>
	<1387522459.19078.427.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:41239 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751825Ab3LTIM0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 03:12:26 -0500
Received: by mail-ob0-f178.google.com with SMTP id uz6so2334863obc.37
        for <netdev@vger.kernel.org>; Fri, 20 Dec 2013 00:12:25 -0800 (PST)
In-Reply-To: <1387522459.19078.427.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 19, 2013 at 10:54 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2013-12-19 at 22:36 -0800, Cong Wang wrote:
>
>> Hmm, off-by-one error, stupid me.
>
> There is something else.
>
> Its late here, I'll let you find and fix the problems.
>

I just sent a fix for the problem I see, not sure it fixes
the bug you reported too.

I will test it as a module tomorrow, if you don't send a fix
before that.

Thanks.
