From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPv6: Functions Clean-up
Date: Sun, 23 Feb 2003 22:54:26 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030223.225426.28829614.davem@redhat.com>
References: <20021103.115427.104445233.yoshfuji@linux-ipv6.org>
	<20030223.011816.108201183.davem@redhat.com>
	<20030224.125702.13403857.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
   netfilter-devel@lists.netfilter.org, kuznet@ms2.inr.ac.ru,
   usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20030224.125702.13403857.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
   Date: Mon, 24 Feb 2003 12:57:02 +0900 (JST)

   Here's the patch for linux-2.5.62.
   
Hideaki-san, do you try to compile the patches you send
to me?  :-)

   -static void ipv6_wash_prefix(struct in6_addr *pfx, int plen)
   +static void ipv6_addr_prefix(struct in6_addr *pfx,
   +			     const struct in6_addr *addr, int plen)
    {
    	int b = plen&0x7;
   -	int o = (plen + 7)>>3;
   +	int o = plen>>3;
    
   +	memcpy(prefix, addr, o);

Where is the variable 'prefix' declared?  You probably mean
'pfx->s6_addr' and that is the change I will make in my tree.

Thanks.
