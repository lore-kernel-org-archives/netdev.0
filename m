From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH 2/2] net_sched: optimize tcf_match_indev()
Date: Mon, 23 Dec 2013 10:36:49 -0800
Message-ID: <CAM_iQpUzt9Vo2DaUgVt=naMEPf6zuurbj-o2EcLNbQt7BBUU4g@mail.gmail.com>
References: <1387503292-20078-1-git-send-email-xiyou.wangcong@gmail.com>
	<1387503292-20078-2-git-send-email-xiyou.wangcong@gmail.com>
	<CAM_iQpXgRzPLp=qyD2pYC=J-=xRqDqVRAxm=grZJDF2ZuCsSfw@mail.gmail.com>
	<52B60384.6000002@mojatatu.com>
	<52B712D3.9050605@mojatatu.com>
	<CAM_iQpXXD0rHiYxGvXiN7G8BtVdTQV6Xixma6BENoZ5SZ2XjZg@mail.gmail.com>
	<52B83632.2090602@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f54.google.com ([209.85.219.54]:37107 "EHLO
	mail-oa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757635Ab3LWSgu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Dec 2013 13:36:50 -0500
Received: by mail-oa0-f54.google.com with SMTP id h16so6007243oag.41
        for <netdev@vger.kernel.org>; Mon, 23 Dec 2013 10:36:49 -0800 (PST)
In-Reply-To: <52B83632.2090602@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 23, 2013 at 5:10 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>
> For completion: I cant find any issues with whats already in net-next.

Oh, you can't?! I found several:

1) ematch could replace indev
2) indev is not friendly to device renaming, so is ematch
3) device removal too

At very least my patch fixes 2) for indev. :)
