From: "David S. Miller" <davem@redhat.com>
Subject: Re: [RFC/PATCH] ICMPv6 MIB stats per-interface
Date: Wed, 16 Apr 2003 10:46:42 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030416.104642.129988781.davem@redhat.com>
References: <20030414.090610.117741299.davem@redhat.com>
	<20030415.014047.39346510.yoshfuji@linux-ipv6.org>
	<20030415.155938.23711671.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: rddunlap@osdl.org, linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20030415.155938.23711671.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
   Date: Tue, 15 Apr 2003 15:59:38 +0900 (JST)

   BTW, for example, if we do
    # ip link set eth9 name foobar
   if_indextoname() will return foobar. 
   
   we, however, will see /proc/sys/net/ipv6/conf/eth9 instead of 
   /proc/sys/net/ipv6/conf/foobar.  This is not good.
   
   Is this just a bug not having NETDEV_CHANGENAME handler to 
   rename it?

I think this is a bug, yes.
