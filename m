From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] drivers/net/skfp/pmf.c: Use offsetof() macro
Date: Thu, 31 Jul 2008 23:56:14 +0100
Message-ID: <20080731235614.7e9e4fa7@lxorguk.ukuu.org.uk>
References: <s5hsktqj8np.wl%tiwai@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Takashi Iwai <tiwai@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:35699 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752163AbYGaXNy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2008 19:13:54 -0400
In-Reply-To: <s5hsktqj8np.wl%tiwai@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 31 Jul 2008 18:55:06 +0200
Takashi Iwai <tiwai@suse.de> wrote:

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

Acked-by: Alan Cox <alan@redhat.com>

(And this is better than the patch I sent to netdev so Ack in definite
preference to the one I posted)
