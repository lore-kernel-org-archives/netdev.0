From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: REDIRECT in nat OUTPUT
Date: Sun, 13 Jul 2008 17:19:50 +0300
Message-ID: <200807131719.50777.denys@visp.net.lb>
References: <200807120424.56462.denys@visp.net.lb> <200807121740.25789.denys@visp.net.lb> <20080713140930.GA23238@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <dada1@cosmosbay.com>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20080713140930.GA23238@2ka.mipt.ru>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 13 July 2008, Evgeniy Polyakov wrote:
> On Sat, Jul 12, 2008 at 05:40:25PM +0300, Denys Fedoryshchenko (denys@visp.net.lb) wrote:
> > Seems i found something. After issuing ethtool -K lo tso on i got significant performance improvement.
> > Why it is not on by default?
> > Without it performance is VERY poor.
> 
> TSO over loopback turns to be GSO, which allows to aggregate multiple
> packets into single frame. If system is not CPU bound, then it is likely
> REDIRECT problem. If I understood you corerctly, loopback performance is
> always good without REDIRECT, but fails to miserable level when
> apprpriate rule is used?
> 
No, seems it has performance issues without redirect(and conntrack unloaded too) even, iperf results on loopback is very unstable.

Actually i dont understand, how on idle machine with Xeon processor iperf over loopback (tcp) can be ~100Mbps?
I think it is a bug.

-- 
------
Technical Manager
Virtual ISP S.A.L.
Lebanon
