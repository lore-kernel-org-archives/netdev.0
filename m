From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: (usagi-users 03610) Re: IPv6 setsockopt software MTU patch
Date: Sun, 19 Feb 2006 23:13:44 +0900 (JST)
Message-ID: <20060219.231344.11160682.yoshfuji@linux-ipv6.org>
References: <43F5A7B2.90803@6wind.com>
	<20060217.215101.09874309.yoshfuji@linux-ipv6.org>
	<20060219134709.GC16304@clarinet.u-strasbg.fr>
Reply-To: usagi-users@linux-ipv6.org
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: usagi-users@linux-ipv6.org, davem@davemloft.net, netdev@vger.kernel.org,
        olivier.matz@6wind.com, yoshfuji@linux-ipv6.org
Return-path: <usagi-users-admin@linux-ipv6.org>
To: hoerdt@clarinet.u-strasbg.fr
In-Reply-To: <20060219134709.GC16304@clarinet.u-strasbg.fr>
List-Software: fml [fml 4.0.3 release (20011202/4.0.3)]
List-Post: <mailto:usagi-users@linux-ipv6.org>
List-Owner: <mailto:usagi-users-admin@linux-ipv6.org>
List-Help: <mailto:usagi-users-ctl@linux-ipv6.org?body=help>
List-Unsubscribe: <mailto:usagi-users-ctl@linux-ipv6.org?body=unsubscribe>
List-Id: netdev.vger.kernel.org

In article <20060219134709.GC16304@clarinet.u-strasbg.fr> (at Sun, 19 Feb 2006 14:47:09 +0100), hoerdt@clarinet.u-strasbg.fr says:

> The fix is very simple, it only grab the value of frag_size and
> use it in ip6_fragment file, could you please review the patch which
> fix that problem at :
> 
> http://clarinet.u-strasbg.fr/~hoerdt/ip6_output.c.softfrag.patch

Thanks for the patch.
I think even we have np->frag_size, we should consider dst_mtu(&rt->u.dst)
as well. No?

--yoshfuji
