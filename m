From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: 2.6.20-git8 fails compile -- net/built-in.o __ipv6_addr_type
Date: Tue, 13 Feb 2007 11:13:45 +0900 (JST)
Message-ID: <20070213.111345.78160400.yoshfuji@linux-ipv6.org>
References: <200702130110.l1D1ADai012897@clem.clem-digital.net>
	<20070212181216.c55ca788.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: akpm@linux-foundation.org, clem@clem.clem-digital.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:54518 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933051AbXBMCNn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Feb 2007 21:13:43 -0500
In-Reply-To: <20070212181216.c55ca788.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20070212181216.c55ca788.akpm@linux-foundation.org> (at Mon, 12 Feb 2007 18:12:16 -0800), Andrew Morton <akpm@linux-foundation.org> says:

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

and, the gcc version...

--yoshfuji
