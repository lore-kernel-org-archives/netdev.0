From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: PROBLEM: nd_tbl not a public symbol in net/ipv6/ndisc.c
Date: Mon, 31 Jan 2005 19:01:57 +0900 (JST)
Message-ID: <20050131.190157.42878368.yoshfuji@linux-ipv6.org>
References: <Pine.OSF.4.58.0501310903220.211@igor.urz.unibas.ch>
	<20050131.172022.93845025.yoshfuji@linux-ipv6.org>
	<Pine.OSF.4.58.0501310922130.2054@igor.urz.unibas.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Christian.Tschudin@unibas.ch
In-Reply-To: <Pine.OSF.4.58.0501310922130.2054@igor.urz.unibas.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <Pine.OSF.4.58.0501310922130.2054@igor.urz.unibas.ch> (at Mon, 31 Jan 2005 10:16:29 +0100 (MET)), Christian Tschudin <Christian.Tschudin@unibas.ch> says:

> We have implemented an underlay network layer protocol.
> This means that we present to the IP stack a subnet illusion
> while doing wireless multihop forwarding underneath.
> To this end we need to set and unset entries in the neighbor
> table, because we are actively managing neighbors.

Ok, but basically, we do not export it unless it is really used.
We may do if it is necessary when you merge it.

BTW, for your purpose, we may export
 ndisc_lookup()
or something instead of nd_tbl itself.

Anyway, I'd like to know the usage (code).

--yoshfuji
