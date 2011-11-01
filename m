From: RongQing Li <roy.qing.li@gmail.com>
Subject: Re: [PATCH next-net] ipv6: Use hlist_for_each_entry_rcu_bh() in ipv6_chk_same_addr()
Date: Tue, 1 Nov 2011 17:05:19 +0800
Message-ID: <CAJFZqHwBwnNPBnPYqyUR8NU2LnagJtBEnvkzRL9TqrdQEqfhXA@mail.gmail.com>
References: <1320125455-25222-1-git-send-email-roy.qing.li@gmail.com>
	<20111101.035323.458528114788135444.davem@davemloft.net>
	<CAJFZqHxTh4kxaqiKWNGuu7vV_VvMx8jH-qXBr+dj7YNOitDrpQ@mail.gmail.com>
	<20111101.043938.1065811675133329291.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:37363 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752231Ab1KAJFW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2011 05:05:22 -0400
Received: by gyb13 with SMTP id 13so6818778gyb.19
        for <netdev@vger.kernel.org>; Tue, 01 Nov 2011 02:05:21 -0700 (PDT)
In-Reply-To: <20111101.043938.1065811675133329291.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/11/1 David Miller <davem@davemloft.net>:
> From: RongQing Li <roy.qing.li@gmail.com>
> Date: Tue, 1 Nov 2011 16:33:49 +0800
>
>> Yes, But I think the code readable is not good,
>
> It is wasteful to add multiple BH disables and RCU memory
> barriers in code paths where it is not necessary.
>
> Your patch fixes no real bug, and adds a regression.
>

hlist_for_each_entry_rcu_bh() does not disable BH,
it only check If BH is disabled.

These codes is different from normal RCU convention.
