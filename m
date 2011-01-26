From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] fix validate_link_af in rtnetlink core
Date: Wed, 26 Jan 2011 16:36:44 +0100
Message-ID: <4D403F8C.2090703@trash.net>
References: <20110126145523.GA3171@e-circ.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Kurt Van Dijck <kurt.van.dijck@eia.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:46002 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753336Ab1AZPgv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jan 2011 10:36:51 -0500
In-Reply-To: <20110126145523.GA3171@e-circ.dyndns.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26.01.2011 15:55, Kurt Van Dijck wrote:
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

There's code in libnl using this, your patch looks fine to me.
