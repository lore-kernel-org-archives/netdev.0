From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [2.6 patch] fix drivers/net/atarilance.c compilation
Date: Wed, 05 Mar 2008 07:18:24 -0500
Message-ID: <47CE8F90.7060607@pobox.com>
References: <20080303213413.GN26072@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: geert@linux-m68k.org, zippel@linux-m68k.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-m68k@lists.linux-m68k.org
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:51062 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751746AbYCEMSg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Mar 2008 07:18:36 -0500
In-Reply-To: <20080303213413.GN26072@cs181133002.pp.htv.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adrian Bunk wrote:
> This patch fixes the following build error:
> 
> <--  snip  -->
> 
> ...
>   CC [M]  drivers/net/atarilance.o
> {standard input}: Assembler messages:
> {standard input}:406: Error: symbol `Lberr' is already defined
> {standard input}:460: Error: symbol `Lberr' is already defined
> make[3]: *** [drivers/net/atarilance.o] Error 1
> 
> <--  snip  -->
> 
> Signed-off-by: Adrian Bunk <bunk@kernel.org>

applied


