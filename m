From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3]: Further reduction of direct access to skb->data
Date: Sat, 24 Mar 2007 20:20:18 -0700 (PDT)
Message-ID: <20070324.202018.41636403.davem@davemloft.net>
References: <20070324210706.GV17811@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: acme@ghostprotocols.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47455
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932195AbXCYDUT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Mar 2007 23:20:19 -0400
In-Reply-To: <20070324210706.GV17811@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Sat, 24 Mar 2007 18:07:06 -0300

> Hi David,
> 
> 	Please take a look, at first I thought about adding a skb_copy_{from,to}_data,
> that would do just the memcpy, but then skb_{copy,store}_bits seems to be fit for this
> purpose, but its more costly in some cases, comments?
> 
> 	Available at:
> 
> master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.22
> 

I think you should make the named alias for direct memcpy()
instead, call it skb_copy_{from,to}_linear_data() so that the
assumed invariant is well documented.
