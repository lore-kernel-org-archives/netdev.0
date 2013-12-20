From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net-next] net_sched: fix a regression in tc actions
Date: Fri, 20 Dec 2013 08:07:39 -0800
Message-ID: <1387555659.19078.439.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1387526931-21814-1-git-send-email-xiyou.wangcong@gmail.com>
		 <52B434FA.8080309@mojatatu.com>
	 <1387550222.19078.434.camel@edumazet-glaptop2.roam.corp.google.com>
	 <52B45851.90208@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:52010 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752357Ab3LTQHu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 11:07:50 -0500
Received: by mail-pb0-f49.google.com with SMTP id jt11so2764134pbb.22
        for <netdev@vger.kernel.org>; Fri, 20 Dec 2013 08:07:50 -0800 (PST)
In-Reply-To: <52B45851.90208@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-12-20 at 09:46 -0500, Jamal Hadi Salim wrote:

> That is strange - I have net-next from when these patches made it
> in and no problem booting with statically linked mirred.
> I will try to pull the latest later and rebuild.
> The patch above will fix the issue on the dumping of actions. I am only
> these additional patches I havent paid much attention to.

Please note boot is OK.

Some application plays netlink games, I have no idea which ones.

Not sure I'll have the time to take a deeper look in following days.
