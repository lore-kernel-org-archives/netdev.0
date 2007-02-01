From: James Morris <jmorris@namei.org>
Subject: Re: [RFC][PATCH][XFRM][4/5] extension to XFRM for dynamic endpoint
 update (MIGRATE)
Date: Thu, 1 Feb 2007 09:50:00 -0500 (EST)
Message-ID: <Pine.LNX.4.64.0702010947530.8524@d.namei>
References: <20070201114558.E2C3.SHINTA@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, Francis Dupont <Francis.Dupont@point6.net>,
	Masahide Nakamura <nakam@linux-ipv6.org>,
	usagi-core@linux-ipv6.org
To: Shinta Sugimoto <shinta@sfc.wide.ad.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail6.sea5.speakeasy.net ([69.17.117.8]:52514 "EHLO
	mail6.sea5.speakeasy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422911AbXBAOuD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Feb 2007 09:50:03 -0500
In-Reply-To: <20070201114558.E2C3.SHINTA@sfc.wide.ad.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 1 Feb 2007, Shinta Sugimoto wrote:

> +	/* allow IPSEC_PROTO_ANY to match all protocols */
> +	//sel.proto = pfkey_proto_to_xfrm(sa->sadb_address_proto);
> +	sel.proto = sa->sadb_address_proto;

Which one is correct ? :-)

> +	/* allow IPSEC_PROTO_ANY to match all protocols */
> +	//sel.proto = pfkey_proto_to_xfrm(sa->sadb_address_proto);
> +	sel.proto = sa->sadb_address_proto;

...



- James
-- 
James Morris
<jmorris@namei.org>
