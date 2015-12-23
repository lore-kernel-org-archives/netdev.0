From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH net v2] geneve: initialize needed_headroom
Date: Wed, 23 Dec 2015 11:01:13 -0500
Message-ID: <20151223160111.GF20729@tuxdriver.com>
References: <211eb876be50613e662c0f01c3de6735e23e9b97.1450885903.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Pravin B Shelar <pshelar@nicira.com>,
	Jiri Benc <jbenc@redhat.com>, Jesse Gross <jesse@nicira.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:44742 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932302AbbLWQPf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2015 11:15:35 -0500
Content-Disposition: inline
In-Reply-To: <211eb876be50613e662c0f01c3de6735e23e9b97.1450885903.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 23, 2015 at 04:54:27PM +0100, Paolo Abeni wrote:
> Currently the needed_headroom field for the geneve device is left
> to the default value.
> 
> This patch set it to space required for basic geneve encapsulation,
> so that we can avoid the skb head re-allocation on xmit.
> 
> This give a 6% speedup for unsegment traffic on geneve tunnel.
> 
> v1 -> v2:
>   - add ETH_HLEN for the lower device to the needed headroom
> 
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

This time I really mean it... ;-)

Acked-by: John W. Linville <linville@tuxdriver.com>

-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
