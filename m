From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] NETDEBUG network triggerable messages in IPv6
Date: Sat, 10 Apr 2004 02:18:40 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040410.021840.113165465.yoshfuji@linux-ipv6.org>
References: <20040409174847.2f0b7e77.ak@suse.de>
	<20040410.010051.129465789.yoshfuji@linux-ipv6.org>
	<20040409182125.348fd6cd.ak@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: ak@suse.de
In-Reply-To: <20040409182125.348fd6cd.ak@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20040409182125.348fd6cd.ak@suse.de> (at Fri, 9 Apr 2004 18:21:25 +0200), Andi Kleen <ak@suse.de> says:

> > > This wraps all potentially network triggerable printks in IPv6 with NETDEBUG.
> > 
> > I really do NOT like this. Please, please do not do this.
> 
> If you don't like it just keep NETDEBUG on. But for production systems being able 
> to fill up logs from the network is not acceptable IMHO. Anyways default behaviour
> does not change right now, it just allows to easily disable all this cruft for
> people who want that.

I don't like the style; it is too ugly.
E.g. please do not put "if () ..." into the macro argument.

--yoshfuji
