From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH RESEND] iproute2: GRE over IPv6 tunnel support.
Date: Sat, 28 Sep 2013 23:27:52 +0200
Message-ID: <20130928212752.GE23654@order.stressinduktion.org>
References: <20130928113251.75738a49@comp1>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "Templin, Fred L" <Fred.L.Templin@boeing.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org
To: Dmitry Kozlov <xeb@mail.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:57576 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754733Ab3I1V1x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Sep 2013 17:27:53 -0400
Content-Disposition: inline
In-Reply-To: <20130928113251.75738a49@comp1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 28, 2013 at 11:32:51AM +0400, Dmitry Kozlov wrote:
> GRE over IPv6 tunnel support.
> 
> Signed-off-by: Dmitry Kozlov <xeb@mail.ru>

Dmitry, thanks a lot for resending!

One small nit:

lib/ll_types.c would need a new entry in ll_type_n2a for ARPHDR_IP6GRE
so ip link ls can pretty print the link type.
