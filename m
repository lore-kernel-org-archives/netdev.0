From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Socket filter ancilliary data access for skb->dev->type
Date: Thu, 22 Apr 2010 15:13:44 +0200
Message-ID: <4BD04B88.4000007@trash.net>
References: <20100422121253.GR19334@cel.leo> <4BD040FE.3000809@trash.net> <20100422131105.GS19334@cel.leo>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Paul LeoNerd Evans <leonerd@leonerd.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33385 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754008Ab0DVNNq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 09:13:46 -0400
In-Reply-To: <20100422131105.GS19334@cel.leo>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul LeoNerd Evans wrote:
> On Thu, Apr 22, 2010 at 02:28:46PM +0200, Patrick McHardy wrote:
>> I think we should be adding a check whether skb->dev is non-NULL here
>> since filters can also be attached to netlink sockets. The same applies
>> to SKF_AD_IFINDEX.
> 
> What should the appropriate behaviour be here? Set A to some rogue value
> - 0 or -1 seem appropriate? Or, abort the filter entirely (such as in
> e.g. divide-by-zero, or invalid memory buffer access)?
> 
> Either way that sounds simple enough, I can hack that in and resubmit.

I'd say we should abort execution.
