From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] (6/6) ipvs -- get rid of skb_linearize
Date: Thu, 18 Sep 2003 00:57:59 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0309180029210.1550-100000@u.domain.uli>
References: <20030916142350.1da23a4a.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Wensong Zhang <wensong@linux-vs.org>, <lvs-users@LinuxVirtualServer.org>,
        <netdev@oss.sgi.com>, Rusty Russell <rusty@rustcorp.com.au>,
        "David S. Miller" <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030916142350.1da23a4a.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

On Tue, 16 Sep 2003, Stephen Hemminger wrote:

> Get rid of skb_linearize warnings, by using may_pull to get the
> header where needed.

	We have another solution for this problem, may be it is
better the following stuff to be included now. Rusty, Dave? Is
someone willing to review this before inclusion?

http://www.ssi.bg/~ja/ipvs-2.6.0-test2/nonlinear-1.diff
http://www.ssi.bg/~ja/ipvs-2.6.0-test2/forward-1.diff
http://www.ssi.bg/~ja/ipvs-2.6.0-test2/no_route_proto-1.diff
http://www.ssi.bg/~ja/ipvs-2.6.0-test2/tcpudp_csum-1.diff

notes:
http://www.ssi.bg/~ja/ipvs-2.6.0-test2/readme.txt

Regards

--
Julian Anastasov <ja@ssi.bg>
