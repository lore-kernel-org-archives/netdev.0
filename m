From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPV6_V6ONLY Support, v2 (is Re: [PATCH] IPv6: Allow
 Both IPv6 and IPv4 Sockets on the Same Port)
Date: Wed, 23 Oct 2002 03:12:24 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021023.031224.102206819.davem@redhat.com>
References: <20021023.190131.67057125.yoshfuji@linux-ipv6.org>
	<Pine.LNX.4.44.0210231312070.28208-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com,
   usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: pekkas@netcore.fi
In-Reply-To: <Pine.LNX.4.44.0210231312070.28208-100000@netcore.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Pekka Savola <pekkas@netcore.fi>
   Date: Wed, 23 Oct 2002 13:15:26 +0300 (EEST)
   
   Will this work too?
   
It should work as a side effect of the USAGI patch.

Because when bind9 does ipv6only bind on wildcarded ipv6,
the ipv4 specific IP binds will then be allowed.
