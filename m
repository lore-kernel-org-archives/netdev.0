From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next 1/3] net_sched: act: Dont increment refcnt on replace
Date: Mon, 23 Dec 2013 16:41:14 -0800
Message-ID: <CAM_iQpX2QqJx1eg-P5G5WQq8b-CwwJS0t4Mqb67dbFb_RuZtyA@mail.gmail.com>
References: <1387803733-19709-1-git-send-email-jhs@mojatatu.com>
	<1387803733-19709-2-git-send-email-jhs@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f169.google.com ([209.85.214.169]:43730 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932864Ab3LXAlP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Dec 2013 19:41:15 -0500
Received: by mail-ob0-f169.google.com with SMTP id wm4so6197814obc.0
        for <netdev@vger.kernel.org>; Mon, 23 Dec 2013 16:41:14 -0800 (PST)
In-Reply-To: <1387803733-19709-2-git-send-email-jhs@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 23, 2013 at 5:02 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>  This is a bug fix. The existing code tries to kill many
>  birds with one stone: Handling binding of actions to
>  filters, new actions and replacing of action
>  attributes. A simple test case to illustrate:

Therefore should go to net rather than net-next?
