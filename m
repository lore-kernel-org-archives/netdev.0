From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: netfilter6: ICMPv6 type 143 doesn't match
Date: Mon, 27 Dec 2004 10:02:05 +0100 (CET)
Message-ID: <20041227.100205.102356251.yoshfuji@linux-ipv6.org>
References: <6050E336B1A0D7D8E70C66F3@t1mobil.muc.aerasec.de>
	<200412270417.iBR4HZRG021429@toshiba.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: usagi-users@linux-ipv6.org, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org,
	netfilter-devel@lists.netfilter.org, laforge@gnumonks.org,
	pb@bieringer.de, kaber@trash.net
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: yasuyuki.kozakai@toshiba.co.jp
In-Reply-To: <200412270417.iBR4HZRG021429@toshiba.co.jp>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

In article <200412270417.iBR4HZRG021429@toshiba.co.jp> (at Mon, 27 Dec 2004 13:17:34 +0900 (JST)), Yasuyuki Kozakai <yasuyuki.kozakai@toshiba.co.jp> says:

>  
> -		ptr = IPV6_HDR_LEN;
> +		ptr = ((u8*)skb->nh.ipv6h - skb->data) + IPV6_HDR_LEN;
>  

IMHO, skb->nh.ipv6h does not points ipv6 header anymore;
it should be skb->nh.raw in this case.

--yoshfuji
