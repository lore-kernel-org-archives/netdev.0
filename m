From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.20-git8 fails compile -- net/built-in.o __ipv6_addr_type
Date: Mon, 12 Feb 2007 20:22:00 -0800 (PST)
Message-ID: <20070212.202200.55506607.davem@davemloft.net>
References: <200702130110.l1D1ADai012897@clem.clem-digital.net>
	<20070212181216.c55ca788.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: clem@clem.clem-digital.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35017
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1030649AbXBMEWB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Feb 2007 23:22:01 -0500
In-Reply-To: <20070212181216.c55ca788.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@linux-foundation.org>
Date: Mon, 12 Feb 2007 18:12:16 -0800

> > On Mon, 12 Feb 2007 20:10:13 -0500 (EST) Pete Clements <clem@clem.clem-digital.net> wrote:
> > 2.6.20-git8 fails compile:
> > 
> >   CHK     include/linux/compile.h
> >   UPD     include/linux/compile.h
> >   CC      init/version.o
> >   LD      init/built-in.o
> >   LD      .tmp_vmlinux1
> > net/built-in.o: In function `svc_udp_recvfrom':
> > svcsock.c:(.text+0x61be4): undefined reference to `__ipv6_addr_type'
> > make: *** [.tmp_vmlinux1] Error 1
> > 
> 
> Please send the .config.

Not necessary, the bug is obvious, see my other reply to
this report.
