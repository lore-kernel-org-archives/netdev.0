From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] Ethernet Bridging: Enable Hardware Checksumming
Date: Thu, 19 May 2005 11:51:41 -0700 (PDT)
Message-ID: <20050519.115141.21926463.davem@davemloft.net>
References: <E1DYayB-0005Sk-00@gondolin.me.apana.org.au>
	<428CAC55.4000202@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, jdmason@us.ibm.com, shemminger@osdl.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: niv@us.ibm.com
In-Reply-To: <428CAC55.4000202@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Nivedita Singhvi <niv@us.ibm.com>
Date: Thu, 19 May 2005 08:10:13 -0700

> Fair point - though I would argue that devices that
> support SG are much more common now - so optimizing
> for the more common case might be preferable - since
> people using bridging with devices that support
> checksum offload are taking quite a hit when they
> do bridging - perhaps this could be a conditional?

I disagree.  Many low costs devices are non-SG still,
there is no reason to penalize them explicitly.

I think instead we should look at ways to propagate
the hardware device features to the bridge.  Even if
a bridge is composed of multiple devices, we just
advertise the subset of features actually supported.
