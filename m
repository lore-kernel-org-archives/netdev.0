From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC RTNETLINK 04/09]: Link creation API
Date: Tue, 05 Jun 2007 23:09:11 +0200
Message-ID: <4665D0F7.5020905@trash.net>
References: <20070605141250.15650.47178.sendpatchset@localhost.localdomain>	<20070605141256.15650.37514.sendpatchset@localhost.localdomain> <20070605.124334.77407503.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, socketcan@hartkopp.net, hadi@cyberus.ca,
	xemul@sw.ru, ebiederm@xmission.com, tgraf@suug.ch
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:37884 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764996AbXFEVJV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 17:09:21 -0400
In-Reply-To: <20070605.124334.77407503.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Tue,  5 Jun 2007 16:12:57 +0200 (MEST)
> 
>>[RTNETLINK]: Link creation API
>>
>>Add rtnetlink API for creating, changing and deleting software devices.
>>
>>Signed-off-by: Patrick McHardy <kaber@trash.net>
> 
> 
> Looks mostly fine, perhaps you can make even more use of 'const'
> for instances of "struct rtnl_link_ops *" at least as function
> arguments deeper in the implementation.


Good suggestion. I initially had rtnl_link_ops const everywhere
(since the lookup was by family I stored it in an array and didn't
need the list_head), then changed it to a list and removed all
consts. I'll add them back where possible.

