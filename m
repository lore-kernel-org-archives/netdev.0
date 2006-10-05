From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH][RFC] net/ipv6: seperate sit driver to extra module
Date: Fri, 06 Oct 2006 02:26:35 +0900 (JST)
Message-ID: <20061006.022635.85990065.yoshfuji@linux-ipv6.org>
References: <20061005154152.GA2102@zlug.org>
	<Pine.LNX.4.64.0610051148230.23631@d.namei>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joro-lkml@zlug.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, yoshfuji@linux-ipv6.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751711AbWJERYN@vger.kernel.org>
To: jmorris@namei.org
In-Reply-To: <Pine.LNX.4.64.0610051148230.23631@d.namei>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <Pine.LNX.4.64.0610051148230.23631@d.namei> (at Thu, 5 Oct 2006 11:49:38 -0400 (EDT)), James Morris <jmorris@namei.org> says:

> On Thu, 5 Oct 2006, Joerg Roedel wrote:
> 
> > Is there a reason why the tunnel driver for IPv6-in-IPv4 is currently
> > compiled into the ipv6 module? This driver is only needed in gateways
> > between different IPv6 networks. On all other hosts with ipv6 enabled it
> > is not required. To have this driver in a seperate module will save
> > memory on those machines.
> > I appended a small and trival patch to 2.6.18 which does exactly this.
> 
> Looks ok to me, although given that users used to get this by default when 
> selecting IPv6, perhaps the default in Kconfig should be y.

Agreed.  And, we could add #ifdef in addrconf.c.

--yoshfuji
