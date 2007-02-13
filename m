From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.20-git8 fails compile -- net/built-in.o __ipv6_addr_type
Date: Mon, 12 Feb 2007 18:12:16 -0800
Message-ID: <20070212181216.c55ca788.akpm@linux-foundation.org>
References: <200702130110.l1D1ADai012897@clem.clem-digital.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Pete Clements <clem@clem.clem-digital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:51128 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933020AbXBMCM2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Feb 2007 21:12:28 -0500
In-Reply-To: <200702130110.l1D1ADai012897@clem.clem-digital.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> On Mon, 12 Feb 2007 20:10:13 -0500 (EST) Pete Clements <clem@clem.clem-digital.net> wrote:
> 2.6.20-git8 fails compile:
> 
>   CHK     include/linux/compile.h
>   UPD     include/linux/compile.h
>   CC      init/version.o
>   LD      init/built-in.o
>   LD      .tmp_vmlinux1
> net/built-in.o: In function `svc_udp_recvfrom':
> svcsock.c:(.text+0x61be4): undefined reference to `__ipv6_addr_type'
> make: *** [.tmp_vmlinux1] Error 1
> 

Please send the .config.
