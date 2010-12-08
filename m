From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] enic: Bug Fix: Pass napi reference to the
 isr that services receive queue
Date: Wed, 08 Dec 2010 08:52:43 -0800 (PST)
Message-ID: <20101208.085243.112609383.davem@davemloft.net>
References: <20101202070833.4213.8072.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roprabhu@cisco.com, dwang2@cisco.com
To: vkolluri@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56678
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750766Ab0LHQwP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 11:52:15 -0500
In-Reply-To: <20101202070833.4213.8072.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasanthy Kolluri <vkolluri@cisco.com>
Date: Wed, 01 Dec 2010 23:08:33 -0800

> From: Vasanthy Kolluri <vkolluri@cisco.com>
> 
> Pass reference to napi instead of enic device to the isr that services receive queue.
> 
> Signed-off-by: Vasanthy Kolluri <vkolluri@cisco.com>
> Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
> Signed-off-by: David Wang <dwang2@cisco.com>

This is a pretty simple and real bug fix, so I'd rather you resubmit this
targetted for net-2.6 instead of net-next-2.6

It won't apply as-is to net-2.6 because the enic driver version number
is different there.

Thanks.
