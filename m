From: Bryan O'Sullivan <bos@pathscale.com>
Subject: Re: [PATCH 38 of 39] IB/ipath - More changes to support InfiniPath
	on PowerPC 970 systems
Date: Thu, 06 Jul 2006 16:34:27 -0700
Message-ID: <1152228867.24748.3.camel@localhost.localdomain>
References: <c22b6c244d5db77f7b1d.1151617289@eng-12.pathscale.com>
	 <1152225421.9862.12.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, rdreier@cisco.com, mst@mellanox.co.il,
	openib-general@openib.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.pathscale.com ([64.160.42.68]:11962 "EHLO mx.pathscale.com")
	by vger.kernel.org with ESMTP id S1751049AbWGFXe2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jul 2006 19:34:28 -0400
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <1152225421.9862.12.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-07-07 at 08:37 +1000, Benjamin Herrenschmidt wrote:

> > +int ipath_unordered_wc(void)
> > +{
> > +	return 1;
> > +}
> 
> How is the above providing any kind of serialisation ?

It's not intended to; it tells the *caller* whether to do it.

	<b

