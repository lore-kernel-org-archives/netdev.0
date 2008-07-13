From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: REDIRECT in nat OUTPUT
Date: Sun, 13 Jul 2008 18:09:30 +0400
Message-ID: <20080713140930.GA23238@2ka.mipt.ru>
References: <200807120424.56462.denys@visp.net.lb> <20080712062812.GA7609@2ka.mipt.ru> <200807121655.44547.denys@visp.net.lb> <200807121740.25789.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <dada1@cosmosbay.com>
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <200807121740.25789.denys@visp.net.lb>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jul 12, 2008 at 05:40:25PM +0300, Denys Fedoryshchenko (denys@visp.net.lb) wrote:
> Seems i found something. After issuing ethtool -K lo tso on i got significant performance improvement.
> Why it is not on by default?
> Without it performance is VERY poor.

TSO over loopback turns to be GSO, which allows to aggregate multiple
packets into single frame. If system is not CPU bound, then it is likely
REDIRECT problem. If I understood you corerctly, loopback performance is
always good without REDIRECT, but fails to miserable level when
apprpriate rule is used?

-- 
	Evgeniy Polyakov
