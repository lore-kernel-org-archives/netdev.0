From: Edward Cree <ecree@solarflare.com>
Subject: Re: [PATCH net 1/2] sfc: handle nonlinear SKBs in efx_filter_rfs()
Date: Thu, 26 May 2016 18:11:59 +0100
Message-ID: <57472E5F.7020608@solarflare.com>
References: <57471D92.2000708@solarflare.com>
 <57471DF5.8010901@solarflare.com>
 <1464281796.5939.96.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-net-drivers@solarflare.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:29632 "EHLO
	nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752175AbcEZRML (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2016 13:12:11 -0400
In-Reply-To: <1464281796.5939.96.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26/05/16 17:56, Eric Dumazet wrote:
> Lot of magic here. Yet another flow dissection.
>
> Seems to be a good place to use net/core/flow_dissector.c helpers.
Fair point, but that doesn't really feel like 'net' material.
I'll look into flow_dissector and see if I can get something ready for when net-next opens back up.  But in the meantime I think this fix is still needed.
