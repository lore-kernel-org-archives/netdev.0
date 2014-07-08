From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH v5 0/2] bridge: fdb dumping takes a filter
 device
Date: Tue, 08 Jul 2014 14:10:38 -0700 (PDT)
Message-ID: <20140708.141038.712786607116212110.davem@davemloft.net>
References: <1404380290-17040-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	vyasevic@redhat.com, sfeldma@cumulusnetworks.com,
	john.r.fastabend@intel.com, roopa@cumulusnetworks.com,
	eric.dumazet@gmail.com
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54240 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753411AbaGHVKj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2014 17:10:39 -0400
In-Reply-To: <1404380290-17040-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>
Date: Thu,  3 Jul 2014 05:38:08 -0400

> Changes:
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

Series applied, I'll push it out after doing another build test :-)
