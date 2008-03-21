From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix null dereference in ip_defrag
Date: Fri, 21 Mar 2008 15:00:54 -0700 (PDT)
Message-ID: <20080321.150054.236561375.davem@davemloft.net>
References: <20080321190930.GA12940@linuxace.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kernel@linuxace.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58478
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751290AbYCUWAi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2008 18:00:38 -0400
In-Reply-To: <20080321190930.GA12940@linuxace.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Oester <kernel@linuxace.com>
Date: Fri, 21 Mar 2008 12:09:30 -0700

> Been seeing occasional panics in my testing of 2.6.25-rc in ip_defrag.
> Offending line in ip_defrag is here:
> 
> 	net = skb->dev->nd_net
> 
> where dev is NULL.  Bisected the problem down to commit
> ac18e7509e7df327e30d6e073a787d922eaf211d ([NETNS][FRAGS]: Make the
> inet_frag_queue lookup work in namespaces).  
> 
> Below patch (idea from Patrick McHardy) fixes the problem for me.
> 
> Signed-off-by: Phil Oester <kernel@linuxace.com>
> Acked-by: Patrick McHardy <kaber@trash.net>

Thanks, I had this in my queue and will apply this now.
