From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: PROBLEM: 2.6.11-rc2 hangs on bridge shutdown (br0)
Date: Sat, 05 Feb 2005 20:39:00 +0900 (JST)
Message-ID: <20050205.203900.66065862.yoshfuji@linux-ipv6.org>
References: <20050204213813.4bd642ad.davem@davemloft.net>
	<20050205061110.GA18275@gondor.apana.org.au>
	<4204AA7C.9010509@tomt.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, davem@davemloft.net,
        mirko.parthey@informatik.tu-chemnitz.de, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com, shemminger@osdl.org, yoshfuji@linux-ipv6.org
To: andre@tomt.net
In-Reply-To: <4204AA7C.9010509@tomt.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <4204AA7C.9010509@tomt.net> (at Sat, 05 Feb 2005 12:14:04 +0100), Andre Tomt <andre@tomt.net> says:

> This patch fixes my problems with hangs when dot1q VLAN interfaces gets 
> removed when loopback is down, as reported in the thread "2.6.10 
> ipv6/8021q lockup on vconfig on interface removal".

Please tell me, why your lo is down...

Anyway, if we really want to "fix" this,
we should do in other way.

I think "Make loopback idev stick around" patches
(for IPv4 and IPv6) could be start of that.

--yoshfuji
