From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH + RFC] neighbour/ARP cache scalability
Date: Wed, 22 Sep 2004 01:04:28 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040922.010428.104988024.yoshfuji@linux-ipv6.org>
References: <20040922.001448.73843048.yoshfuji@linux-ipv6.org>
	<Pine.LNX.4.44.0409211856260.9906-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: laforge@gnumonks.org, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: pekkas@netcore.fi
In-Reply-To: <Pine.LNX.4.44.0409211856260.9906-100000@netcore.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <Pine.LNX.4.44.0409211856260.9906-100000@netcore.fi> (at Tue, 21 Sep 2004 18:58:05 +0300 (EEST)), Pekka Savola <pekkas@netcore.fi> says:

> This still doesn't take a stance on rate-limiting the ND/ARP packets,
> in case that there still is enough memory, but some kind of attack is
> clearly underway.  Should it still be done?  Consider 100Kpps of
> router-generated ARP/ND probes -- not good!

Right. We need to do this, of course. Probably, per-ingress interface.
(I mean, incoming interface which invokes NS.)

Note: I think similar idea (limiting per interface) was arose during chat 
      with Robert, Halard et. al at OLS.

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
