From: David Miller <davem@davemloft.net>
Subject: Re: [PATH v3 net-next] net: remove member 'max' of struct
 scm_fp_list
Date: Sat, 11 Feb 2017 02:02:50 -0500 (EST)
Message-ID: <20170211.020250.864578992818171198.davem@davemloft.net>
References: <1486784477-3892-1-git-send-email-cugyly@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Linyu.Yuan@alcatel-sbell.com.cn
To: cugyly@163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56724 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753263AbdBKHK6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 11 Feb 2017 02:10:58 -0500
In-Reply-To: <1486784477-3892-1-git-send-email-cugyly@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: yuan linyu <cugyly@163.com>
Date: Sat, 11 Feb 2017 11:41:17 +0800

> From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
> 
> 'max' only used at three places in scm.c,
> 1. in scm_fp_copy(), fpl->max = SCM_MAX_FD;
> 2. in scm_fp_copy(), if (fpl->count + num > fpl->max)
> 3. in scm_fp_dup(), new_fpl->max = new_fpl->count;
> at place 3, the worst case is new_fpl->count = SCM_MAX_FD,
> so do a full size dup, then 'max' field will always
> SCM_MAX_FD and it can be removed.
> 
> Signed-off-by: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>

Please don't take this the wrong way, but I am ignoring your
patches on this issue.  This is even more broken than your
previous two submissions.

Sorry.
