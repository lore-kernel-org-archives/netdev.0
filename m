From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net v3 5/5] net_sched: convert tcf_exts from list to
 pointer array
Date: Sat, 13 Aug 2016 07:33:55 -0400
Message-ID: <70a062d7-5670-b71a-1ead-045a7b1426f5@mojatatu.com>
References: <1470962503-19682-1-git-send-email-xiyou.wangcong@gmail.com>
 <1470962503-19682-6-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f176.google.com ([209.85.220.176]:35160 "EHLO
	mail-qk0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751566AbcHMLea (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Aug 2016 07:34:30 -0400
Received: by mail-qk0-f176.google.com with SMTP id v123so8807575qkh.2
        for <netdev@vger.kernel.org>; Sat, 13 Aug 2016 04:33:57 -0700 (PDT)
In-Reply-To: <1470962503-19682-6-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Just minor comment below:

On 16-08-11 08:41 PM, Cong Wang wrote:


> +static inline void
> +tcf_exts_to_list(const struct tcf_exts *exts, struct list_head *actions)
> +{

to:
static inline void tcf_exts_to_list(const struct tcf_exts *exts,
                                     struct list_head *actions)

cheers,
jamal
