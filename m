From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net-next v2 1/5] net_sched: act: hide struct tcf_common
 from API
Date: Mon, 27 Jan 2014 07:11:47 -0500
Message-ID: <52E64D03.7000506@mojatatu.com>
References: <1390516525-8556-1-git-send-email-xiyou.wangcong@gmail.com> <1390516525-8556-2-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:65157 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751425AbaA0MMA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jan 2014 07:12:00 -0500
Received: by mail-ie0-f169.google.com with SMTP id to1so681125ieb.0
        for <netdev@vger.kernel.org>; Mon, 27 Jan 2014 04:12:00 -0800 (PST)
In-Reply-To: <1390516525-8556-2-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/23/14 17:35, Cong Wang wrote:
> Now we can totally hide it from modules. tcf_hash_*() API's
> will operate on struct tc_action, modules don't need to care about
> the details.
>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---

Cong, this patch does not compile by itself. I did not try the rest.
For git bisect to work:
Every patch should be compilable standalone and all tests should
pass with every single patch (the later part is my view, the first
is common practise)

Since Dave already closed the door - no rush, when you get the
cycles please fix this up. I am hoping to do a quick test run
when you are done.

cheers,
jamal
