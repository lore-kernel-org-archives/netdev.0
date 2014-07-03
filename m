From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v4 0/2] bridge: fdb dumping takes a filter
 device
Date: Wed, 02 Jul 2014 17:41:14 -0700 (PDT)
Message-ID: <20140702.174114.1070001183436341599.davem@davemloft.net>
References: <1403952456-16020-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	vyasevic@redhat.com, sfeldma@cumulusnetworks.com,
	john.r.fastabend@intel.com, roopa@cumulusnetworks.com,
	eric.dumazet@gmail.com
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42409 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753933AbaGCAlQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 20:41:16 -0400
In-Reply-To: <1403952456-16020-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>
Date: Sat, 28 Jun 2014 06:47:34 -0400

> Changes:
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

Series applied, thanks Jamal.

 
