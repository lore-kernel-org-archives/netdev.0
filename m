From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/4 net-next] tg3: provide frags as skb head
Date: Fri, 27 Apr 2012 18:42:44 +0200
Message-ID: <1335544964.2775.250.camel@edumazet-glaptop>
References: <1335522889.2775.231.camel@edumazet-glaptop>
	 <1335544386.2618.50.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Tom Herbert <therbert@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Matt Carlson <mcarlson@broadcom.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Michael Chan <mchan@broadcom.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:44545 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760366Ab2D0Qmu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Apr 2012 12:42:50 -0400
Received: by bkuw12 with SMTP id w12so662891bku.19
        for <netdev@vger.kernel.org>; Fri, 27 Apr 2012 09:42:49 -0700 (PDT)
In-Reply-To: <1335544386.2618.50.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-04-27 at 17:33 +0100, Ben Hutchings wrote:

> page_address() may return NULL if CONFIG_HIGHMEM is enabled.  And that's
> going to be a general problem with this scheme on 32-bit machines.

kmalloc(2048, GFP_ATOMIC) and alloc_page(GFP_ATOMIC) uses the same pool
of LOWMEM pages, so there is no difference here. page_address() is
guaranteed to work.

Thanks
