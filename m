From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][IPv6] Export userland ND options through netlink
 (RDNSS support)
Date: Wed, 10 Oct 2007 21:22:33 -0700 (PDT)
Message-ID: <20071010.212233.59662829.davem@davemloft.net>
References: <20071005060930.GA15305@via.ecp.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: linkfanel@yahoo.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40813
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751959AbXJKEWa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 00:22:30 -0400
In-Reply-To: <20071005060930.GA15305@via.ecp.fr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pierre Ynard <linkfanel@yahoo.fr>
Date: Fri, 5 Oct 2007 08:09:30 +0200

> As discussed before, this patch provides userland with a way to access
> relevant options in Router Advertisements, after they are processed and
> validated by the kernel. Extra options are processed in a generic way;
> this patch only exports RDNSS options described in RFC5006, but support
> to control which options are exported could be easily added.
> 
> A new rtnetlink message type is defined, to transport Neighbor Discovery
> options, along with optional context information. At the moment only
> the address of the router sending an RDNSS option is included, but
> additional attributes may be later defined, if needed by new use cases.
> 
> Signed-off-by: Pierre Ynard <linkfanel@yahoo.fr>

This seems to include the changes Yoshifuji requested in your
first submission, so I have applied this.

Thanks.
