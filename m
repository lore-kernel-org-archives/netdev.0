From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: 2.4.21+ - IPv6 over IPv4 tunneling b0rked
Date: Fri, 11 Jul 2003 20:03:57 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030711.200357.33143193.yoshfuji@linux-ipv6.org>
References: <20030711.195917.89662318.yoshfuji@linux-ipv6.org>
	<Pine.LNX.4.44.0307111358440.27351-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mika.liljeberg@welho.com, andre@tomt.net, linux-kernel@vger.kernel.org,
   netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: pekkas@netcore.fi
In-Reply-To: <Pine.LNX.4.44.0307111358440.27351-100000@netcore.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <Pine.LNX.4.44.0307111358440.27351-100000@netcore.fi> (at Fri, 11 Jul 2003 13:59:14 +0300 (EEST)), Pekka Savola <pekkas@netcore.fi> says:

> > So, you cannot remove subnet router anycast address from
> > kernel via this interface; kernel keeps one reference.
> 
> .. which is why kernel shouldn't keep *any* reference *at all*!

No, it is because REQUIRED and UNREMOVABLE anycast address.
I don't think it is good to change this.

--yoshfuji
