From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH] pkt_sched: act_xt support new Xtables interface
Date: Wed, 19 Dec 2012 18:05:23 -0500
Message-ID: <50D24833.8040803@mojatatu.com>
References: <50C4821D.5090206@gmail.com> <50C9B4BB.9060609@mojatatu.com> <50CCE961.5050204@mojatatu.com> <alpine.LNX.2.01.1212160002330.4901@nerf07.vanv.qr> <CAASe=fQT2pVOK0uctdaKL+aOrF8nYeTMfoF15kmd-rC02+7Vnw@mail.gmail.com> <50CDFB6A.3090806@mojatatu.com> <50CE1A04.1000405@mojatatu.com> <alpine.LNX.2.01.1212162003340.27614@nerf07.vanv.qr> <50CE3203.9080007@mojatatu.com> <50CF1071.1050405@mojatatu.com> <CAASe=fRuJdtisEvp7uo=PHwN3nKHqsYDW4Om1gk2MK-vyNvBrA@mail.gmail.com> <50D06177.2090905@mojatatu.com> <CAASe=fR6Hm2dxp=1wDchtrzqnaH6qacHpg2wrsqLfmGpPbQ9Fg@mail.gmail.com> <50D1A8A7.1090002@mojatatu.com> <50D1AB7E.5060000@mojatatu.com> <alpine.LNX.2.01.1212191648490.13317@nerf07.vanv.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hasan Chowdhury <shemonc@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Yury Stankevich <urykhy@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	pablo@netfilter.org, netfilter-devel@vger.kernel.org
To: Jan Engelhardt <jengelh@inai.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:48006 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751911Ab2LSXFZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2012 18:05:25 -0500
Received: by mail-ie0-f179.google.com with SMTP id k14so3776201iea.10
        for <netdev@vger.kernel.org>; Wed, 19 Dec 2012 15:05:25 -0800 (PST)
In-Reply-To: <alpine.LNX.2.01.1212191648490.13317@nerf07.vanv.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12-12-19 10:52 AM, Jan Engelhardt wrote:
>
>
> Humm... that's a huge patch for what seems to be equal to act_ipt.c
> Let's do a cross-diff:
>

I was thinking of our little discussion when doing that.
The one reason i separated the two is so when the time is right you
can patch on top of only act_xt.c and eventually act_ipt.c will die..
Does changes on top of act_xt.c sound palatable to you?
Otherwise, you are right - it is overkill

cheers,
jamal
