From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next V2 04/10] net/act_skbedit: Utility functions for
 mark action
Date: Thu, 3 Mar 2016 09:48:40 -0800
Message-ID: <CAM_iQpVO9BjUw8ZB0tnmH+a18DkrAVjNdth5R5xuzmS9gPJRuQ@mail.gmail.com>
References: <1457016960-27832-1-git-send-email-amir@vadai.me>
	<1457016960-27832-5-git-send-email-amir@vadai.me>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	John Fastabend <john.r.fastabend@intel.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Rony Efraim <ronye@mellanox.com>
To: Amir Vadai <amir@vadai.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f172.google.com ([209.85.160.172]:34469 "EHLO
	mail-yk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755942AbcCCRsl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 12:48:41 -0500
Received: by mail-yk0-f172.google.com with SMTP id u9so12383724ykd.1
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2016 09:48:41 -0800 (PST)
In-Reply-To: <1457016960-27832-5-git-send-email-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 3, 2016 at 6:55 AM, Amir Vadai <amir@vadai.me> wrote:
> +static inline bool is_tcf_skbedit_mark(const struct tc_action *a)
> +{
> +#ifdef CONFIG_NET_CLS_ACT
> +       if (a->ops && a->ops->type == TCA_ACT_SKBEDIT)
> +               return to_skbedit(a)->flags == SKBEDIT_F_MARK;


You mean to_skbedit(a)->flags & SKBEDIT_F_MARK ?
