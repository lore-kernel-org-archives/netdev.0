From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next 09/20] net: sched: convert actions array into rcu
 list
Date: Sun, 30 Jul 2017 16:17:24 -0400
Message-ID: <e4e5c83c-d016-ee72-4e68-0966ccf9aaad@mojatatu.com>
References: <20170728144042.6380-1-jiri@resnulli.us>
 <20170728144042.6380-10-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, xiyou.wangcong@gmail.com,
        daniel@iogearbox.net, mlxsw@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:36504 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754239AbdG3UR2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Jul 2017 16:17:28 -0400
Received: by mail-io0-f194.google.com with SMTP id j32so12284529iod.3
        for <netdev@vger.kernel.org>; Sun, 30 Jul 2017 13:17:28 -0700 (PDT)
In-Reply-To: <20170728144042.6380-10-jiri@resnulli.us>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-07-28 10:40 AM, Jiri Pirko wrote:
> From: Jiri Pirko <jiri@mellanox.com>
> 
> Currently the actions are stored in array with array size. To traverse
> this array in fastpath, tcf_tree_lock is taken to protect it. Convert
> the array into a singly linked list, similar to the filter chains style
> and allow traversal protected by rcu.
> 

Looks sane. But lets have Cong provide an opinion (since he said he was
trying to rcu the actions).

cheers,
jamal
