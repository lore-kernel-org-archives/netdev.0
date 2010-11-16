From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xfrm: update flowi saddr in icmp_send if unset
Date: Tue, 16 Nov 2010 11:46:16 -0800 (PST)
Message-ID: <20101116.114616.35058621.davem@davemloft.net>
References: <20101105113912.GA14694@babylon>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: uweber@astaro.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60159
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754211Ab0KPTpv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Nov 2010 14:45:51 -0500
In-Reply-To: <20101105113912.GA14694@babylon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ulrich Weber <uweber@astaro.com>
Date: Fri, 5 Nov 2010 12:39:12 +0100

> otherwise xfrm_lookup will fail to find correct policy
> 
> Signed-off-by: Ulrich Weber <uweber@astaro.com>

Looks good, applied to net-2.6

Sorry for taking so long but I wanted to validate this change
against how the rest of this code handles source addresses.
