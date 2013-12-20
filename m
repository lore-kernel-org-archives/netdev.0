From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] net_sched: optimize tcf_match_indev()
Date: Thu, 19 Dec 2013 22:54:19 -0800
Message-ID: <1387522459.19078.427.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1387503292-20078-1-git-send-email-xiyou.wangcong@gmail.com>
	 <1387503292-20078-2-git-send-email-xiyou.wangcong@gmail.com>
	 <1387520573.19078.424.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAM_iQpWA2qjjEV97SFajg0Y_0WnWAY2qPY9_7vSuFVuYq5tH6Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:39738 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754102Ab3LTGyW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 01:54:22 -0500
Received: by mail-pb0-f52.google.com with SMTP id uo5so2215244pbc.39
        for <netdev@vger.kernel.org>; Thu, 19 Dec 2013 22:54:21 -0800 (PST)
In-Reply-To: <CAM_iQpWA2qjjEV97SFajg0Y_0WnWAY2qPY9_7vSuFVuYq5tH6Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-12-19 at 22:36 -0800, Cong Wang wrote:

> Hmm, off-by-one error, stupid me.

There is something else.

Its late here, I'll let you find and fix the problems.
