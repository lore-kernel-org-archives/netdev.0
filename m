From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 1/2] net: Remove casts of void *
Date: Thu, 16 Jun 2011 21:52:00 -0700
Message-ID: <1308286320.12072.25.camel@Joe-Laptop>
References: <cover.1308017857.git.joe@perches.com>
	 <d010144f11f9165670ac0c9e3559bf5e3191ff28.1308017857.git.joe@perches.com>
	 <20110616.232344.2285390268187937319.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:3059 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754235Ab1FQEwC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jun 2011 00:52:02 -0400
In-Reply-To: <20110616.232344.2285390268187937319.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-06-16 at 23:23 -0400, David Miller wrote:
> From: Joe Perches <joe@perches.com>
> Date: Mon, 13 Jun 2011 19:21:26 -0700
> > Unnecessary casts of void * clutter the code.
> > Signed-off-by: Joe Perches <joe@perches.com>
> Applied.

Hey David.

The equivalent drivers/net patch is marked "changes requested".
I think that's not true as I only saw acks.

Geert commented and I'll do a separate pr_<level>/netdev_<level>
neatening pass for a2065, lib8390 and zorro8390 and maybe any
other 8390 driver Geert wants.

As I now have a working m68k cross compiler,
these will be compile tested only.

fyi: this version 
http://www.kernel.org/pub/tools/crosstool/files/bin/i686/4.6.0/i686-gcc-4.6.0-nolibc_m68k-linux.tar.bz2
doesn't cross compile for m68k/amiga successfully,
but the 3.4.5 version does
http://www.kernel.org/pub/tools/crosstool/files/bin/old/m68k-gcc-3.4.5-glibc-2.3.6.tar.bz2

cheers, Joe

