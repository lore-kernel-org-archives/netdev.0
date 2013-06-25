From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] iproute2: fix build failure on sparc due to -Wformat
 and tv_usec
Date: Tue, 25 Jun 2013 13:37:55 -0700
Message-ID: <20130625133755.5d0b32f6@nehalam.linuxnetplumber.net>
References: <20130518161850.GA16019@amd64.fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andreas Henriksson <andreas@fatal.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f53.google.com ([209.85.160.53]:45935 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753667Ab3FYUh7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jun 2013 16:37:59 -0400
Received: by mail-pb0-f53.google.com with SMTP id xb12so13050458pbc.40
        for <netdev@vger.kernel.org>; Tue, 25 Jun 2013 13:37:59 -0700 (PDT)
In-Reply-To: <20130518161850.GA16019@amd64.fatal.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 18 May 2013 18:18:51 +0200
Andreas Henriksson <andreas@fatal.se> wrote:

> tv_usec is "suseconds_t" which is apparently usually
> a signed long, but sometimes not....
> Change the printf modifier to use signed and
> cast the tv_usec to long in case it's not already long.
> 
> gcc -Wall -Wstrict-prototypes -Werror -Wmissing-prototypes -Wmissing-declarations -Wold-style-definition -O2 -I../include -DRESOLVE_HOSTNAMES -DLIBDIR=\"/usr/lib\" -DCONFDIR=\"/etc/iproute2\" -D_GNU_SOURCE -fPIC   -c -o utils.o utils.c
> utils.c: In function 'print_timestamp':
> utils.c:802:2: error: format '%lu' expects argument of type 'long unsigned int', but argument 4 has type '__suseconds_t' [-Werror=format]
> cc1: all warnings being treated as errors
> 
> Signed-off-by: Andreas Henriksson <andreas@fatal.se>

Sure applied.
