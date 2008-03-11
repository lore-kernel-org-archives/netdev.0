From: Kieran Mansley <kmansley@solarflare.com>
Subject: Re: LRO/GSO interaction when packets are forwarded
Date: Tue, 11 Mar 2008 16:50:18 +0000
Message-ID: <1205254218.21379.21.camel@moonstone.uk.level5networks.com>
References: <1204898997.4220.41.camel@moonstone.uk.level5networks.com>
	 <20080307082538.1a674ae1@extreme>
	 <1204909575.4220.71.camel@moonstone.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 216-237-3-220.orange.nextweb.net ([216.237.3.220]:57099 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751521AbYCKQuW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2008 12:50:22 -0400
In-Reply-To: <1204909575.4220.71.camel@moonstone.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-03-07 at 17:06 +0000, Kieran Mansley wrote:
> Given that there seem to be a small number of places where this is
> currently causing problems (LRO through a bridge to a stack is fine,
> it's only if the packet is forwarded that things go wrong), and that an
> LRO packet should in most cases be very easy to segment (it's already in
> network-sized fragments) I wonder if making it work would be
> easier/better than preventing it from happening.

I hope to get some time to work on this in the not-too-distant future.  

Kieran

