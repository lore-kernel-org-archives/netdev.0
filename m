From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] net_sched: optimize tcf_match_indev()
Date: Fri, 20 Dec 2013 15:59:27 -0800
Message-ID: <1387583967.19078.476.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1387503292-20078-1-git-send-email-xiyou.wangcong@gmail.com>
	 <1387503292-20078-2-git-send-email-xiyou.wangcong@gmail.com>
	 <CAM_iQpXgRzPLp=qyD2pYC=J-=xRqDqVRAxm=grZJDF2ZuCsSfw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f172.google.com ([209.85.161.172]:64831 "EHLO
	mail-gg0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752882Ab3LTX7a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 18:59:30 -0500
Received: by mail-gg0-f172.google.com with SMTP id q6so711048ggc.31
        for <netdev@vger.kernel.org>; Fri, 20 Dec 2013 15:59:30 -0800 (PST)
In-Reply-To: <CAM_iQpXgRzPLp=qyD2pYC=J-=xRqDqVRAxm=grZJDF2ZuCsSfw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-12-20 at 15:49 -0800, Cong Wang wrote:
> On Thu, Dec 19, 2013 at 5:34 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> > tcf_match_indev() is called in fast path, it is not wise to
> > search for a netdev by ifindex and then compare by its name,
> > just compare the ifindex.
> >
> > This will also save some bytes from the core struct of u32.
> >
> > Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> > Cc: David S. Miller <davem@davemloft.net>
> > Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> 
> 
> Jamal, any comments on this patch itself?

How device renaming (dev_change_name()) is handled ?
