From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH|RFC] IPv6: have a proxy discard link-local traffic
Date: Wed, 28 Jan 2004 08:54:14 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040128.085414.32889499.yoshfuji@linux-ipv6.org>
References: <Pine.LNX.4.44.0401170906160.9907-100000@netcore.fi>
	<Pine.LNX.4.58.0401272259160.28384@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, pekkas@netcore.fi, usagi-core@linux-ipv6.org,
        netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: vnuorval@tcs.hut.fi
In-Reply-To: <Pine.LNX.4.58.0401272259160.28384@rhea.tcs.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <Pine.LNX.4.58.0401272259160.28384@rhea.tcs.hut.fi> (at Tue, 27 Jan 2004 23:11:20 +0200 (EET)), Ville Nuorvala <vnuorval@tcs.hut.fi> says:

> Dave, since even Pekka is now convinced this patch doesn't break anything,
:

> +	/* The proxying router can't forward traffic sent to a link-local
> +	   address, so signal the sender and discard the packet. This
> +	   behavior is required by the MIPv6 specification. */

Would you please clarify the word "can't" and its reasons?
won't? don't? or whatever?

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
