From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: linux-2.4.21 and IPv6
Date: Sun, 17 Aug 2003 23:34:38 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030817.233438.07191138.yoshfuji@linux-ipv6.org>
References: <20030817020925.A875@keun>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: szukw000@students.uni-mainz.de
In-Reply-To: <20030817020925.A875@keun>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20030817020925.A875@keun> (at Sun, 17 Aug 2003 02:09:25 GMT), "w.szukalski" <szukw000@students.uni-mainz.de> says:

> 	read6.sin6_scope_id = 0;
:
> //	ALTERNATIVE 2:
> 	inet_pton(AF_INET6, host, &read6.sin6_addr);
> 
> //	ALTERNATIVE 3:	
> 	read6.sin6_addr = mreq6.ipv6mr_multiaddr;

What is host?


>     bind(reader, (struct sockaddr *)&read6, sizeof(read6) );
> 
> bind() fails for alternative 3 with 'Invalid argument'.

bind(2) should fail with ALT.2 for some "host."
Anyway, the reason seems that you forgot to set scope-id for
link-local scope addresses.

--yoshfuji
