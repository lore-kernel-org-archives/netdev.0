From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPv6: Fix Prefix Length of Link-local Addresses
Date: Wed, 09 Oct 2002 16:45:04 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021009.164504.28085695.davem@redhat.com>
References: <20021010002902.A3803@edi-view1.cisco.com>
	<20021009.162438.82081593.davem@redhat.com>
	<uu1jv9o3j.wl@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dfawcus@cisco.com, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
   usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: sekiya@sfc.wide.ad.jp
In-Reply-To: <uu1jv9o3j.wl@sfc.wide.ad.jp>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Yuji Sekiya <sekiya@sfc.wide.ad.jp>
   Date: Thu, 10 Oct 2002 08:41:52 +0900
   
   The reason we change the prefix length  from /10 to /64 is
   following spec and adapting other imprementations.

I think Derek's explanation shows that the specification
allows the /10 behavior.

Also, I suspect that since Derek works for Cisco, some "other
implementations" behave how he describes. :-)
