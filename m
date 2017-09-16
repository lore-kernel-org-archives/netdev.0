From: Julian Anastasov <ja@ssi.bg>
Subject: Re: Use after free in __dst_destroy_metrics_generic
Date: Sat, 16 Sep 2017 15:40:08 +0300 (EEST)
Message-ID: <alpine.LFD.2.20.1709161422010.2651@ja.home.ssi.bg>
References: <1234e09b75197d43ed84bdb1b154b4b6@codeaurora.org> <CAM_iQpXKfUkbyuuZEZXyPrVVCoPaxnCmCARz=Jf0VtU1m9NsZg@mail.gmail.com> <1505509219.16139.6.camel@edumazet-glaptop3.roam.corp.google.com> <alpine.LFD.2.20.1709160103190.1770@ja.home.ssi.bg>
 <0b4e9dbc852c4df7401dc770f357ae6a@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Lorenzo Colitti <lorenzo@google.com>
To: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:45556 "EHLO ja.ssi.bg"
        rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751322AbdIPMkV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 16 Sep 2017 08:40:21 -0400
In-Reply-To: <0b4e9dbc852c4df7401dc770f357ae6a@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Fri, 15 Sep 2017, Subash Abhinov Kasiviswanathan wrote:

> > 	May be I'm missing some posting but I don't see if
> > the patch was tested successfully.
> > 
> Hi Julian
> 
> I've had this patch being tested for the last 3-4 days in our regression rack
> and I haven't seen the same issue being reproduced or even a related crash
> or leak in dst.

	For now I see only its bug-hiding side effects, i.e.
it does not call kfree. Now if there is no double-free
there should be a leak, not for dst but for metrics.

> The original issue was reported only once to us from the regression rack only
> so the exact steps to reproduce is unknown.

	OK, lets see, may be others can explain what happens.

Regards
