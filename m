From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [Bugme-new] [Bug 4189] New: IPv6 link local addresses are not
 assigned correctly on multiple-bonding enviromrnts
Date: Fri, 11 Feb 2005 11:17:48 +0900 (JST)
Message-ID: <20050211.111748.15372366.yoshfuji@linux-ipv6.org>
References: <20050210122523.41276d5a.davem@davemloft.net>
	<20050211.092916.50162307.yoshfuji@linux-ipv6.org>
	<420C0D05.6020408@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, davem@davemloft.net, ikebe.takashi@lab.ntt.co.jp,
        akpm@osdl.org, ctindel@users.sourceforge.net, fubar@us.ibm.com,
        bonding-devel@lists.sourceforge.net, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: rick.jones2@hp.com
In-Reply-To: <420C0D05.6020408@hp.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <420C0D05.6020408@hp.com> (at Thu, 10 Feb 2005 17:40:21 -0800), Rick Jones <rick.jones2@hp.com> says:

> At present, for IPv4 if someone changes the MAC address of an interface, 
> existing TCP connections don't really care right?  The ARP caches will be 
> updated with a new IPv4 to MAC translation and happiness and joy ensues.
> 
> So, what would happen to TCP connections over IPv6 using link-local addresses? 
> If the old address is taken away (deprecated), and a new address generated, 
> doesn't that mean that TCP connections (using link-local addresses anyway) will 
> fail on a MAC change?

One thing: we won't delete it but deprecate it.

--yoshfuji
