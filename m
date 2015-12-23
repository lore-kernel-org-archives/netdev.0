From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH net] geneve: initialize needed_headroom
Date: Wed, 23 Dec 2015 10:27:23 -0500
Message-ID: <20151223152722.GD20729@tuxdriver.com>
References: <c891d011ef98267cd72157a5b01c78347ada8d8e.1450883640.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Pravin B Shelar <pshelar@nicira.com>,
	Jiri Benc <jbenc@redhat.com>, Jesse Gross <jesse@nicira.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:44270 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751518AbbLWPaa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2015 10:30:30 -0500
Content-Disposition: inline
In-Reply-To: <c891d011ef98267cd72157a5b01c78347ada8d8e.1450883640.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 23, 2015 at 04:21:48PM +0100, Paolo Abeni wrote:
> Currently the needed_headroom field for the geneve device is left
> to the default value.
> 
> This patch set it to space required for basic geneve encapsulation,
> so that we can avoid the skb head re-allocation on xmit.
> 
> This give a 6% speedup for unsegment traffic on geneve tunnel.
> 
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Acked-by: John W. Linville <linville@tuxdriver.com>

-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
