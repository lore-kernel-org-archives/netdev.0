From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [Patch net-next v2 1/5] net_sched: act: hide struct tcf_common
 from API
Date: Thu, 23 Jan 2014 16:02:58 -0800
Message-ID: <20140123160258.7d9ecc95@nehalam.linuxnetplumber.net>
References: <1390516525-8556-1-git-send-email-xiyou.wangcong@gmail.com>
	<1390516525-8556-2-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:54179 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751957AbaAXADB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 19:03:01 -0500
Received: by mail-pa0-f51.google.com with SMTP id ld10so2515356pab.24
        for <netdev@vger.kernel.org>; Thu, 23 Jan 2014 16:03:00 -0800 (PST)
In-Reply-To: <1390516525-8556-2-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 23 Jan 2014 14:35:21 -0800
Cong Wang <xiyou.wangcong@gmail.com> wrote:

> +#define to_tcf_csum(a) \
> +	container_of(a->priv,struct tcf_csum,common

please use space after comma in arguments
