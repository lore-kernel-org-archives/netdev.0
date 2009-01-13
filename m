From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH] net: Remove redundant NAPI functions
Date: Tue, 13 Jan 2009 02:35:22 +0100
Message-ID: <m3r638ugx1.fsf@maximus.localdomain>
References: <1231769390.3075.2.camel@achroite>
	<1231771577.3075.5.camel@achroite>
	<m34p04bfd2.fsf@maximus.localdomain>
	<20090112.163021.132623782.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bhutchings@solarflare.com, jarkao2@gmail.com,
	nhorman@tuxdriver.com, shemminger@vyatta.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:51532 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758415AbZAMBfZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Jan 2009 20:35:25 -0500
In-Reply-To: <20090112.163021.132623782.davem@davemloft.net> (David Miller's message of "Mon\, 12 Jan 2009 16\:30\:21 -0800 \(PST\)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

>> >> > > +++ b/drivers/net/wan/ixp4xx_hss.c

> So, as it turns out I think I need to handle this in a few stages:
>
> 1) It doesn't build upstream in Linus's tree because of the
>    dev arg, so I'll fix that upstream in net-2.6
>
> 2) Then I'll rework Ben's napi_*() patch to apply on top of that.
>
> I can do this because I haven't published my net-next-2.6 tree
> yet anywhere, so I can just rebase to fix all of this up.

Thanks.
-- 
Krzysztof Halasa
