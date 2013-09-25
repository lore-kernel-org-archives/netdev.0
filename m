From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH RFC] net: introduce support for lazy initialization of
 secret keys
Date: Thu, 26 Sep 2013 00:14:00 +0200
Message-ID: <20130925221400.GD12025@breakpoint.cc>
References: <20130925213403.GF4904@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:40690 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752428Ab3IYWOC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Sep 2013 18:14:02 -0400
Received: from fw by Chamillionaire.breakpoint.cc with local (Exim 4.80)
	(envelope-from <fw@strlen.de>)
	id 1VOxLM-0005w4-Ek
	for netdev@vger.kernel.org; Thu, 26 Sep 2013 00:14:00 +0200
Content-Disposition: inline
In-Reply-To: <20130925213403.GF4904@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:
> This patch splits the secret key for syncookies between ipv4 and ipv6
> and initializes them with net_get_random_once. This change was the reason
> I did this patch. I think the initialization of the syncookie_secret is
> way to early.

Agreed, thanks for working on this.
