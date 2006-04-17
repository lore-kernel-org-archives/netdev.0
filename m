From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: fixing sk_stream_rfree()
Date: Tue, 18 Apr 2006 07:40:54 +1000
Message-ID: <20060417214054.GA30730@gondor.apana.org.au>
References: <20060417.132904.55913090.davem@davemloft.net> <Pine.WNT.4.63.0604171405470.3848@jbrandeb-desk.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from CyborgDefenseSystems.Corporatebeast.com ([64.62.148.172]:774
	"EHLO arnor.apana.org.au") by vger.kernel.org with ESMTP
	id S1751275AbWDQVlA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Apr 2006 17:41:00 -0400
To: Jesse Brandeburg <jesse.brandeburg@intel.com>
Content-Disposition: inline
In-Reply-To: <Pine.WNT.4.63.0604171405470.3848@jbrandeb-desk.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 17, 2006 at 02:09:43PM -0700, Jesse Brandeburg wrote:
> 
> we explicitly enabled TSO before performing the test.
> attached bz2 due to size:

Thanks a lot.  Are those promiscuous mode messages caused by tcpdump?
If so could you try it without doing a tcpdump or any other af_packet
applications?

> Let me know if there is anything else I can do,

Since you can reproduce this at will now, please modify one of those
warning messages to print out the actual value of sk_forward_alloc.
It can gives a clue.  For instance if it happens to be a multiple of
PAGE_SIZE, then we know it may be related to the reclaim stuff.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
