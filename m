From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Patch for tbench regression.
Date: Mon, 29 Sep 2008 09:36:06 +0400
Message-ID: <20080929053605.GA21663@2ka.mipt.ru>
References: <20080928211530.GA9341@2ka.mipt.ru> <20080929031244.GA22619@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Christoph Lameter <cl@linux-foundation.org>,
	Mel Gorman <mel@csn.ul.ie>, David Miller <davem@davemloft.net>,
	Lennert Buytenhek <buytenh@marvell.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:39027 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751167AbYI2Fhe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Sep 2008 01:37:34 -0400
Content-Disposition: inline
In-Reply-To: <20080929031244.GA22619@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 29, 2008 at 11:12:44AM +0800, Herbert Xu (herbert@gondor.apana.org.au) wrote:
> Can you see if reverting the patch but using ethtool gives you the
> same results?

Yes, I disabled gso and tso on vanilla 2.6.27-rc7 via ethtools and
got the same results:

$ sudo ethtool -k lo
Offload parameters for lo:
rx-checksumming: on
tx-checksumming: on
scatter-gather: on
tcp segmentation offload: off
udp fragmentation offload: off
generic segmentation offload: off

1 proc: 195 mb
4 proc: 195 mb

$ sudo ethtool -k lo
Offload parameters for lo:
rx-checksumming: on
tx-checksumming: on
scatter-gather: on
tcp segmentation offload: on
udp fragmentation offload: off
generic segmentation offload: on

1 proc: 190 mb
4 proc: 189 mb

-- 
	Evgeniy Polyakov
