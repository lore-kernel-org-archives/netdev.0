From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch for 2.6.27? 1/6] drivers/net/skfp/pmf.c: Use offsetof()
 macro
Date: Sat, 13 Sep 2008 15:13:13 -0400
Message-ID: <48CC10C9.1090705@garzik.org>
References: <200809052104.m85L44gQ020346@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tiwai@suse.de, alan@redhat.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59938 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753356AbYIMTNS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Sep 2008 15:13:18 -0400
In-Reply-To: <200809052104.m85L44gQ020346@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

akpm@linux-foundation.org wrote:
> From: Takashi Iwai <tiwai@suse.de>
> 
> Self-baked macros cause bunch of compile warnings like below:
> 
>   CC [M]  drivers/net/skfp/pmf.o
>   CC      net/ipv4/fib_semantics.o
> drivers/net/skfp/pmf.c:86: warning: cast from pointer to integer of different size
> drivers/net/skfp/pmf.c:87: warning: cast from pointer to integer of different size
> ...
> 
> Use the standard offsetof() macro instead.
> 
> Signed-off-by: Takashi Iwai <tiwai@suse.de>
> Acked-by: Alan Cox <alan@redhat.com>
> Cc: Jeff Garzik <jeff@garzik.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/skfp/pmf.c |   29 +++++++++++------------------
>  1 file changed, 11 insertions(+), 18 deletions(-)

applied


