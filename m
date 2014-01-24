From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [Patch net-next v2 1/5] net_sched: act: hide struct tcf_common
 from API
Date: Thu, 23 Jan 2014 16:04:13 -0800
Message-ID: <20140123160413.37804c6c@nehalam.linuxnetplumber.net>
References: <1390516525-8556-1-git-send-email-xiyou.wangcong@gmail.com>
	<1390516525-8556-2-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:35289 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751001AbaAXAEQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 19:04:16 -0500
Received: by mail-pa0-f41.google.com with SMTP id fa1so2545727pad.0
        for <netdev@vger.kernel.org>; Thu, 23 Jan 2014 16:04:15 -0800 (PST)
In-Reply-To: <1390516525-8556-2-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 23 Jan 2014 14:35:21 -0800
Cong Wang <xiyou.wangcong@gmail.com> wrote:

> +#define to_defact(a) \
> +	container_of(a->priv, struct tcf_defact, common)

also macro args should be in parens.

#define to_defact(a) \
	container_of((a)->priv, struct tcf_defact, common)
