From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH v7 0/2] bridge: fdb dumping takes a filter
 device
Date: Thu, 10 Jul 2014 12:45:48 -0700 (PDT)
Message-ID: <20140710.124548.169173515227751190.davem@davemloft.net>
References: <1404990119-16968-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	vyasevic@redhat.com, sfeldma@cumulusnetworks.com,
	john.r.fastabend@intel.com, roopa@cumulusnetworks.com,
	eric.dumazet@gmail.com
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42912 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751717AbaGJTpu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2014 15:45:50 -0400
In-Reply-To: <1404990119-16968-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>
Date: Thu, 10 Jul 2014 07:01:57 -0400

> From: Jamal Hadi Salim <jhs@mojatatu.com>
> 
> v7:
> Vxlan driver was not updated with new API. Found by DaveM
> 
> v6:
> Missed checkpatch > 80 chars lines found by Varka Bhadram 
> 
> v5:
>  Embarassing qlnic compile failure found by DaveM
> 
> v4:
>  Request from DaveM to use proper comment tagging and remove if-stmnt braces
> 
> V3:
>  Suggestion from Eric D. to use for_each_netdev
>  Suggestion from Stephen H. to reduce level of indentation
> 
> V2:
> Suggestions from Vlad
>  Get rid of rcu read lock since rtnl_lock is being held
>  simplify for readability

Applied, thanks.
