From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH][IPv6] separation xfrm_lookup from ip6_dst_lookup
Date: Tue, 03 Aug 2004 01:19:12 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040803.011912.128392049.yoshfuji@linux-ipv6.org>
References: <20040730171205.114f22ba.kazunori@miyazawa.org>
	<20040802074147.GA16381@gondor.apana.org.au>
	<20040802190914.303ccfbe.davem@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, kazunori@miyazawa.org, netdev@oss.sgi.com,
        usagi-core@linux-ipv6.org, kuznet@ms2.inr.ac.ru,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: <20040802190914.303ccfbe.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20040802190914.303ccfbe.davem@redhat.com> (at Mon, 2 Aug 2004 19:09:14 -0700), "David S. Miller" <davem@redhat.com> says:

> An intesting solution would be to use stacked destinations, which
> do no actual encapsulation (or perhaps do the routing header work)
> and merely represent the hop-by-hop path.  Then the PMTU propagation
> machinery can be used, and route lookups will go through a slower path
> to find these special stacked hop-by-hop routes.

Well, I think it would probably be another rt6_info{} member 
rt6i_srcrt (or something like that).

--yoshfuji
