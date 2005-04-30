From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH][IPv6][IPsec] stop infinite loop
Date: Sat, 30 Apr 2005 12:07:36 +0900 (JST)
Message-ID: <20050430.120736.45974367.yoshfuji@linux-ipv6.org>
References: <4272EC95.20401@miyazawa.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, herbert@gondor.apana.org.au, netdev@oss.sgi.com,
        usagi-core@linux-ipv6.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: kazunori@miyazawa.org
In-Reply-To: <4272EC95.20401@miyazawa.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <4272EC95.20401@miyazawa.org> (at Sat, 30 Apr 2005 11:25:25 +0900), Kazunori Miyazawa <kazunori@miyazawa.org> says:

> I think dst_check causes it because it exptects the obsolete
> of normal dst (I mean not xfrm) is 0 but ip6_route_add sets it -1.
> This patch changes the default value of the obsolete.
> This patch is for linux-2.6.12-rc3.

No, ipv6 depends on obsolete == -1; ip6_dst_check checks if dst is 
up-to-date or not.

Please fix xfrm side; assumption that obsolete == 0.

Thanks.

--yoshfuji
