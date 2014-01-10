From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC Patch net-next 1/4] net_sched: switch filter list to
 list_head
Date: Thu, 09 Jan 2014 16:17:15 -0800
Message-ID: <1389313035.31367.71.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1389291593-2494-1-git-send-email-xiyou.wangcong@gmail.com>
	 <1389291593-2494-2-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, John Fastabend <john.fastabend@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f48.google.com ([209.85.213.48]:41508 "EHLO
	mail-yh0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751583AbaAJARS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 19:17:18 -0500
Received: by mail-yh0-f48.google.com with SMTP id f73so1123330yha.7
        for <netdev@vger.kernel.org>; Thu, 09 Jan 2014 16:17:18 -0800 (PST)
In-Reply-To: <1389291593-2494-2-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-01-09 at 10:19 -0800, Cong Wang wrote:
> So that it could be potentially traversed with RCU.

This never made sense to me.

RCU doesn't need list_head at all.

list_head is convenient (not only for RCU), but not a need.
