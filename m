From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPv6 IPComp
Date: Mon, 19 May 2003 23:35:32 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030519.233532.42779243.davem@redhat.com>
References: <873cjebwn1.wl@karaba.org>
	<20030516.140014.59676235.davem@redhat.com>
	<871xyvqr7k.wl@karaba.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: mk@linux-ipv6.org
In-Reply-To: <871xyvqr7k.wl@karaba.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Mitsuru KANDA / 神田 充 <mk@linux-ipv6.org>
   Date: Mon, 19 May 2003 17:24:31 +0900

   I would like to try to configure xfrm4 ipip tunnel for testing.
   What is the suitable tool?, setkey???

Unfortunately setkey is not powerful enough to do this
currently.  Only the netlink based ipsec configuration can
set these things up.

However, all of the testing we did was via tunnel mode IPCOMP.

Note that for xfrm6_tunnel.c you will need to use some kind
of "u32 --> in6_addr" mapping table.  You can do this with
a simple hash table of some kind.  Then you can use
xfrm_state_lookup() just like xfrm4_tunnel.c does.
