From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: socket(PF_INET6, SOCK_RAW, IPPROTO_ICMPV6)
Date: Thu, 13 Mar 2003 00:33:41 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030313.003341.49620358.yoshfuji@linux-ipv6.org>
References: <20030312.213903.04850857.yoshfuji@linux-ipv6.org>
	<Pine.GSO.4.44.0303121348470.23508-100000@rose.man.poznan.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: maxiu@man.poznan.pl
In-Reply-To: <Pine.GSO.4.44.0303121348470.23508-100000@rose.man.poznan.pl>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <Pine.GSO.4.44.0303121348470.23508-100000@rose.man.poznan.pl> (at Wed, 12 Mar 2003 13:51:53 +0100 (CET)), Marcin Kaminski <maxiu@man.poznan.pl> says:

> Is there simplier method of obtaining source and destaination address of
> icmp packet (the only informations I need from ipv6 header) than setting
> IPV6_PKTINFO and receiving them with recvmsg?

No; recvmsg() and IPV6_PKTINFO socket options is the SIMPLE way for 
obtaining source and destination address.

--yoshfuji
