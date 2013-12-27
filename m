From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/3] net_sched: act: Dont increment refcnt on
 replace
Date: Fri, 27 Dec 2013 12:50:18 -0500 (EST)
Message-ID: <20131227.125018.829521862249543338.davem@davemloft.net>
References: <1387803733-19709-1-git-send-email-jhs@mojatatu.com>
	<1387803733-19709-2-git-send-email-jhs@mojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
	eric.dumazet@gmail.com
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59903 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754481Ab3L0RuU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Dec 2013 12:50:20 -0500
In-Reply-To: <1387803733-19709-2-git-send-email-jhs@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>
Date: Mon, 23 Dec 2013 08:02:11 -0500

>  This is a bug fix. The existing code tries to kill many
>  birds with one stone: Handling binding of actions to
>  filters, new actions and replacing of action
>  attributes. A simple test case to illustrate:
> 
> XXXX
>  moja@fe1:~$ sudo tc actions add action drop index 12
>  moja@fe1:~$ actions get action gact index 12        
>  action order 1: gact action drop
>   random type none pass val 0 
>   index 12 ref 1 bind 0
>  moja@fe1:~$ sudo tc actions replace action ok index 12
>  moja@fe1:~$ actions get action gact index 12        
>  action order 1: gact action drop
>   random type none pass val 0 
>   index 12 ref 2 bind 0
> XXXX
> 
> The above shows the refcounf being wrongly incremented on replace.
> There are more complex scenarios with binding of actions to filters
> that i am leaving out that didnt work as well...
> 
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

Applied to 'net', thanks.
