From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net-next v2 1/2] net_sched: move tc_action into tcf_common
Date: Tue, 26 Jul 2016 10:00:12 -0400
Message-ID: <a3955281-054c-03e2-15b0-c09f6d2b93d2@mojatatu.com>
References: <1469488182-12296-1-git-send-email-xiyou.wangcong@gmail.com>
 <1469488182-12296-2-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:34617 "EHLO
	mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756652AbcGZOAP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jul 2016 10:00:15 -0400
Received: by mail-io0-f193.google.com with SMTP id g86so1683076ioj.1
        for <netdev@vger.kernel.org>; Tue, 26 Jul 2016 07:00:15 -0700 (PDT)
In-Reply-To: <1469488182-12296-2-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-07-25 07:09 PM, Cong Wang wrote:
> struct tc_action is confusing, currently we use it for two purposes:
> 1) Pass in arguments and carry out results from helper functions
> 2) A generic representation for tc actions
>
> The first one is error-prone, since we need to make sure we don't
> miss anything. This patch aims to get rid of this use, by moving
> tc_action into tcf_common, so that they are allocated together
> in hashtable and can be cast'ed easily.
>
> And together with the following patch, we could really make
> tc_action a generic representation for all tc actions and each
> type of action can inherit from it.
>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>


Cong - i need to stare at this longer than cursory
to give feedback. I apologize,
I am in travel mode but will get back to you.

cheers,
jamal
