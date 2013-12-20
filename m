From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH 2/2] net_sched: optimize tcf_match_indev()
Date: Fri, 20 Dec 2013 15:49:16 -0800
Message-ID: <CAM_iQpXgRzPLp=qyD2pYC=J-=xRqDqVRAxm=grZJDF2ZuCsSfw@mail.gmail.com>
References: <1387503292-20078-1-git-send-email-xiyou.wangcong@gmail.com>
	<1387503292-20078-2-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f179.google.com ([209.85.214.179]:62667 "EHLO
	mail-ob0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751771Ab3LTXtQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 18:49:16 -0500
Received: by mail-ob0-f179.google.com with SMTP id wm4so3395310obc.24
        for <netdev@vger.kernel.org>; Fri, 20 Dec 2013 15:49:16 -0800 (PST)
In-Reply-To: <1387503292-20078-2-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 19, 2013 at 5:34 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> tcf_match_indev() is called in fast path, it is not wise to
> search for a netdev by ifindex and then compare by its name,
> just compare the ifindex.
>
> This will also save some bytes from the core struct of u32.
>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>


Jamal, any comments on this patch itself?
