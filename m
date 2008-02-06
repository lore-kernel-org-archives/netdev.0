From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH] Add IPv6 support to TCP SYN cookies
Date: Wed, 6 Feb 2008 12:13:53 +0300
Message-ID: <20080206091353.GA12927@2ka.mipt.ru>
References: <20080205220510.09258826@core> <47a91136.24528c0a.1f6d.ffffa476@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Glenn Griffin <ggriffin.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:34139 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760270AbYBFJQb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Feb 2008 04:16:31 -0500
Content-Disposition: inline
In-Reply-To: <47a91136.24528c0a.1f6d.ffffa476@mx.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 05, 2008 at 05:52:31PM -0800, Glenn Griffin (ggriffin.kernel@gmail.com) wrote:
> +static u32 cookie_hash(struct in6_addr *saddr, struct in6_addr *daddr,
> +		       __be16 sport, __be16 dport, u32 count, int c)
> +{
> +	__u32 tmp[16 + 5 + SHA_WORKSPACE_WORDS];

This huge buffer should not be allocated on stack.


-- 
	Evgeniy Polyakov
