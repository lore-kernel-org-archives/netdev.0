From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH 2/2] net_sched: optimize tcf_match_indev()
Date: Fri, 20 Dec 2013 18:23:53 -0500
Message-ID: <52B4D189.7050404@mojatatu.com>
References: <1387503292-20078-1-git-send-email-xiyou.wangcong@gmail.com>	<1387503292-20078-2-git-send-email-xiyou.wangcong@gmail.com>	<1387520573.19078.424.camel@edumazet-glaptop2.roam.corp.google.com>	<CAM_iQpWA2qjjEV97SFajg0Y_0WnWAY2qPY9_7vSuFVuYq5tH6Q@mail.gmail.com>	<1387522459.19078.427.camel@edumazet-glaptop2.roam.corp.google.com>	<CAM_iQpX-Ghj8K-3i4ph+ArugbxjoyZiYDkc1jxBEE+YjmYv3eg@mail.gmail.com>	<52B434A9.9070408@mojatatu.com>	<CAM_iQpWz0NP_6vtYhHSSDW1p3HdALoiNm7JkwL=1-XErHOZ14w@mail.gmail.com>	<52B4A6C0.605@mojatatu.com>	<CAM_iQpXaDtfTFzgcGih1weWAxLqmcgHMHBP0bU9M5mnYdjPkaw@mail.gmail.com>	<52B4CC21.8030801@mojatatu.com> <CAM_iQpX69N+Gyf7Wz0pBE4SWiQuqCDgnCqeA2OO4BFdCp17gxA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f178.google.com ([209.85.223.178]:61560 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751259Ab3LTXXz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 18:23:55 -0500
Received: by mail-ie0-f178.google.com with SMTP id lx4so3966998iec.9
        for <netdev@vger.kernel.org>; Fri, 20 Dec 2013 15:23:55 -0800 (PST)
In-Reply-To: <CAM_iQpX69N+Gyf7Wz0pBE4SWiQuqCDgnCqeA2OO4BFdCp17gxA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/20/13 18:07, Cong Wang wrote:

>
> I said I never triggered Eric's crash with `tc action ls ...`, nor
> with any of my other test case.
>
> And I also said I added 'tc action ls...' _after_ David merged it,
> so failed to notice the difference.
>

You didnt say that last part. That was the confusing part.

> Clear?
>

Yes, making a lot more sense ;->

cheers,
jamal
