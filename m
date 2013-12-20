From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH 2/2] net_sched: optimize tcf_match_indev()
Date: Fri, 20 Dec 2013 15:07:27 -0800
Message-ID: <CAM_iQpX69N+Gyf7Wz0pBE4SWiQuqCDgnCqeA2OO4BFdCp17gxA@mail.gmail.com>
References: <1387503292-20078-1-git-send-email-xiyou.wangcong@gmail.com>
	<1387503292-20078-2-git-send-email-xiyou.wangcong@gmail.com>
	<1387520573.19078.424.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAM_iQpWA2qjjEV97SFajg0Y_0WnWAY2qPY9_7vSuFVuYq5tH6Q@mail.gmail.com>
	<1387522459.19078.427.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAM_iQpX-Ghj8K-3i4ph+ArugbxjoyZiYDkc1jxBEE+YjmYv3eg@mail.gmail.com>
	<52B434A9.9070408@mojatatu.com>
	<CAM_iQpWz0NP_6vtYhHSSDW1p3HdALoiNm7JkwL=1-XErHOZ14w@mail.gmail.com>
	<52B4A6C0.605@mojatatu.com>
	<CAM_iQpXaDtfTFzgcGih1weWAxLqmcgHMHBP0bU9M5mnYdjPkaw@mail.gmail.com>
	<52B4CC21.8030801@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f42.google.com ([209.85.219.42]:46337 "EHLO
	mail-oa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753107Ab3LTXH2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 18:07:28 -0500
Received: by mail-oa0-f42.google.com with SMTP id i4so3598253oah.1
        for <netdev@vger.kernel.org>; Fri, 20 Dec 2013 15:07:27 -0800 (PST)
In-Reply-To: <52B4CC21.8030801@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 20, 2013 at 3:00 PM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> You lost me.
> You said you were running all those tests and didnt see any
> bugs. I said if infact you ran exactly what you said you test
> did before and after your changes you will see obvious bugs.
>

I said I never triggered Eric's crash with `tc action ls ...`, nor
with any of my other test case.

And I also said I added 'tc action ls...' _after_ David merged it,
so failed to notice the difference.

Clear?
