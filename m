From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] netfilter6: Skip extension headers when matching
 icmp6-type
Date: Thu, 30 Sep 2004 21:29:01 +0900 (JST)
Sender: netfilter-devel-bounces@lists.netfilter.org
Message-ID: <20040930.212901.81655011.yoshfuji@linux-ipv6.org>
References: <20040930121620.GH19083@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com,
	netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: okir@suse.de
In-Reply-To: <20040930121620.GH19083@suse.de>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

In article <20040930121620.GH19083@suse.de> (at Thu, 30 Sep 2004 14:16:20 +0200), Olaf Kirch <okir@suse.de> says:

> +
> +	if (skb_copy_bits(skb, hdroff, &icmph, sizeof(icmph)) < 0) {
>  		/* We've been asked to examine this packet, and we
>  		   can't.  Hence, no choice but to drop. */
>  		duprintf("Dropping evil ICMP tinygram.\n");

Please use skb_header_pointer(). Thank you.

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
