From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [Bugme-new] [Bug 4189] New: IPv6 link local addresses are not
 assigned correctly on multiple-bonding enviromrnts
Date: Fri, 11 Feb 2005 09:29:16 +0900 (JST)
Message-ID: <20050211.092916.50162307.yoshfuji@linux-ipv6.org>
References: <20050210002356.500401f7.akpm@osdl.org>
	<20050210.182225.07335127.yoshfuji@linux-ipv6.org>
	<20050210122523.41276d5a.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, ikebe.takashi@lab.ntt.co.jp, akpm@osdl.org,
        ctindel@users.sourceforge.net, fubar@us.ibm.com,
        bonding-devel@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
In-Reply-To: <20050210122523.41276d5a.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20050210122523.41276d5a.davem@davemloft.net> (at Thu, 10 Feb 2005 12:25:23 -0800), "David S. Miller" <davem@davemloft.net> says:

> I guess this causes problems for ipv6 local addresses, it
> will need to catch some callback to handle these events and
> thus adjust the local address properly.

Okay, I'll try to solve it:
1) catch NETDEV_CHANGEADDR
2) (try to) add new link-local address and deprecate old one.
3) (when DAD finishes) RS will be sent.

--yoshfuji
