From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 08/15] ipv4: Kill routes during PMTU/redirect updates.
Date: Wed, 18 Jul 2012 12:51:49 -0700
Message-ID: <1342641109.2013.23.camel@joe2Laptop>
References: <20120718.112356.1409220904008377845.davem@davemloft.net>
	 <1342638944.2013.10.camel@joe2Laptop>
	 <20120718.123015.476222169838022819.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:44451 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753331Ab2GRTvu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jul 2012 15:51:50 -0400
In-Reply-To: <20120718.123015.476222169838022819.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-07-18 at 12:30 -0700, David Miller wrote:
> From: Joe Perches <joe@perches.com>
> > Perhaps struct dst_entry.obsolete could be a char instead of
> > a short and a pad byte could added for some future use.
> 
> First thing, char is not signed by default on all systems :-)

yeah, yeah. I'm sure you'll dtrt :)
