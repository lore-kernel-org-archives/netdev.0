From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: [PATCH 2.6.23] cxgb3 - Fix dev->priv usage
Date: Thu, 23 Aug 2007 14:25:18 -0500
Message-ID: <46CDDF1E.1010408@opengridcomputing.com>
References: <20070813193303.15321.49171.stgit@speedy5> <20070813.135811.06543390.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: divy@chelsio.com, jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([71.42.183.126]:51548 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755568AbXHWTpr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2007 15:45:47 -0400
In-Reply-To: <20070813.135811.06543390.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch doesn't seem to have gone in yet????

Steve.


David Miller wrote:
> From: Divy Le Ray <divy@chelsio.com>
> Date: Mon, 13 Aug 2007 12:33:04 -0700
> 
>> From: Divy Le Ray <divy@chelsio.com>
>>
>> cxgb3 used netdev_priv() and dev->priv for different purposes.
>> In 2.6.23, netdev_priv() == dev->priv, cxgb3 needs a fix.
>> This patch is a partial backport of Dave Miller's changes in the 
>> net-2.6.24 git branch. 
>>
>> Signed-off-by: Divy Le Ray <divy@chelsio.com>
> 
> Thank you for doing this backport.
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
