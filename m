From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net 2/2] net_sched: always call ->destroy when ->init()
 fails
Date: Fri, 24 Oct 2014 17:42:07 -0700
Message-ID: <1414197727.20845.53.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1414194959-28006-1-git-send-email-xiyou.wangcong@gmail.com>
	 <1414194959-28006-2-git-send-email-xiyou.wangcong@gmail.com>
	 <1414196053.20845.45.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAHA+R7N3jJCgOJjnDUxsTaH7ZCvPydDT60qkcqSPsEyFbp=UQg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Wang Bo <wang.bo116@zte.com.cn>,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Patrick McHardy <kaber@trash.net>, Terry Lam <vtlam@google.com>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:35658 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932111AbaJYAmJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2014 20:42:09 -0400
Received: by mail-pd0-f182.google.com with SMTP id y10so2340356pdj.27
        for <netdev@vger.kernel.org>; Fri, 24 Oct 2014 17:42:08 -0700 (PDT)
In-Reply-To: <CAHA+R7N3jJCgOJjnDUxsTaH7ZCvPydDT60qkcqSPsEyFbp=UQg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-10-24 at 17:36 -0700, Cong Wang wrote:

> You missed what Wang Bo reported, we could double free
> mq qdisc on failure path, one in mq_init() and one in qdisc_create_dflt().

So fix mq/mqprio ?

I am sorry, but sending patches on Friday afternoon should be forbidden,
too much beer lying around ;)
