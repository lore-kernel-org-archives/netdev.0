From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: 2.4.21+ - IPv6 over IPv4 tunneling b0rked
Date: Fri, 11 Jul 2003 18:04:49 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030711.180449.126456521.yoshfuji@linux-ipv6.org>
References: <20030711.143926.599349332.yoshfuji@linux-ipv6.org>
	<Pine.LNX.4.44.0307111143470.26262-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mika.liljeberg@welho.com, andre@tomt.net, linux-kernel@vger.kernel.org,
   netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: pekkas@netcore.fi
In-Reply-To: <Pine.LNX.4.44.0307111143470.26262-100000@netcore.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <Pine.LNX.4.44.0307111143470.26262-100000@netcore.fi> (at Fri, 11 Jul 2003 11:46:00 +0300 (EEST)), Pekka Savola <pekkas@netcore.fi> says:

> > I don't like this
> > while I would be ok to have configuration option
> > not to support anycast.
> 
> With "not to support anycast" you probably meant "not to support
> subnet-router anycast address [automatically, in the kernel, as now]" ?  
> These are entirely different things.

I meant disabling anycast entirely.

> (Note that if there's a user-level API for setting anycast addresses, one 
> could kick the subnet-router anycast address out of the kernel too.  
> Whether that's desirable is another thing.)

We have but we cannot; it is refcnt'ed.

--yoshfuji
