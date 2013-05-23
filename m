From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] bridge: netfilter: using strlcpy() instead of strncpy()
Date: Thu, 23 May 2013 12:56:00 +0200
Message-ID: <20130523105600.GA22553@localhost>
References: <5195E53A.4060406@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bart.de.schuymer@pandora.be, kaber@trash.net,
	stephen@networkplumber.org, David Miller <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, bridge@lists.linux-foundation.org,
	netdev <netdev@vger.kernel.org>
To: Chen Gang <gang.chen@asianux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:48105 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758125Ab3EWK4J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 May 2013 06:56:09 -0400
Content-Disposition: inline
In-Reply-To: <5195E53A.4060406@asianux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 17, 2013 at 04:07:22PM +0800, Chen Gang wrote:
> 
> 'name' has already set all zero when it is defined, so not need let
> strncpy() to pad it again.
> 
> 'name' is a string, better always let is NUL terminated, so use
> strlcpy() instead of strncpy().

Applied, thanks.
