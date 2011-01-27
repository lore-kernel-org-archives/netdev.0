From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fix validate_link_af in rtnetlink core
Date: Thu, 27 Jan 2011 14:33:48 -0800 (PST)
Message-ID: <20110127.143348.260087438.davem@davemloft.net>
References: <20110126145523.GA3171@e-circ.dyndns.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kurt.van.dijck@eia.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51482
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751373Ab1A0WdN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jan 2011 17:33:13 -0500
In-Reply-To: <20110126145523.GA3171@e-circ.dyndns.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kurt Van Dijck <kurt.van.dijck@eia.be>
Date: Wed, 26 Jan 2011 15:55:24 +0100

> Hi,
> 
> I'm not sure about this patch.
> 
> I'm testing an API that uses IFLA_AF_SPEC attribute.
> In the rtnetlink core , the set_link_af() member
> of the rtnl_af_ops struct receives the nested attribute
> (as I expected), but the validate_link_af() member
> receives the parent attribute.
> IMO, this patch fixes this.
> 
> Since I didn't find any code in iproute2 that makes use
> of this attribute, I wasn't able to verify this on the userspace
> end.
> 
> Signed-off-by: Kurt Van Dijck <kurt.van.dijck@eia.be>

Applied, thanks.
