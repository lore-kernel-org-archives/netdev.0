From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: /proc/net/* read drops data
Date: Thu, 28 Aug 2003 09:34:20 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030828.093420.37091433.yoshfuji@linux-ipv6.org>
References: <Pine.GSO.4.33.0308271658370.7750-100000@sweetums.bluetronic.net>
	<Pine.GSO.4.33.0308271935550.7750-100000@sweetums.bluetronic.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jfbeam@bluetronic.net
In-Reply-To: <Pine.GSO.4.33.0308271935550.7750-100000@sweetums.bluetronic.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <Pine.GSO.4.33.0308271935550.7750-100000@sweetums.bluetronic.net> (at Wed, 27 Aug 2003 19:58:17 -0400 (EDT)), Ricky Beam <jfbeam@bluetronic.net> says:

> On Wed, 27 Aug 2003, Ricky Beam wrote:
> >This smells like a simple "off by one" bug, but I've been too busy to go
> >look at the code.
> 
> Ah hah!  it's a block size problem... netstat reads 1024 at a time.
> 
> Using dd...
> 
> [root:pts/5{9}]gir:~/[7:55pm]:dd if=/proc/net/udp bs=1024 | wc
> 2+1 records in
> 2+1 records out
>      18     216    2304

Good idea. I'll chase this bug.

--yoshfuji
