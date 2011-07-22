From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH net-2.6] jme: Fix unmap error (Causing system freeze)
Date: Fri, 22 Jul 2011 09:45:42 +0200
Message-ID: <CAHXqBF+1aJ0O9WxrZTKfYMm57emysfPUnA-=M9DZN5kUGnhW8g@mail.gmail.com>
References: <1311217056-9073-1-git-send-email-cooldavid@cooldavid.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	linux-netdev <netdev@vger.kernel.org>,
	Aries Lee <arieslee@jmicron.com>,
	Devinchiu <devinchiu@jmicron.com>,
	Jason Lamb <jason@lambhome.org>,
	Marcus Becker <marcus.disi@gmail.com>,
	Marc Schiffbauer <mschiff@gentoo.org>,
	Jason Long <jason@octgsoftware.com>, stable@kernel.org
To: cooldavid@cooldavid.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:52620 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752163Ab1GVHqD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jul 2011 03:46:03 -0400
Received: by qyk9 with SMTP id 9so1149559qyk.19
        for <netdev@vger.kernel.org>; Fri, 22 Jul 2011 00:46:02 -0700 (PDT)
In-Reply-To: <1311217056-9073-1-git-send-email-cooldavid@cooldavid.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/7/21  <cooldavid@cooldavid.org>:
> From: Guo-Fu Tseng <cooldavid@cooldavid.org>
>
> This patch add the missing dma_unmap().
> Which solved the critical issue of system freeze on heavy load.
>
> Michal Miroslaw's rejected patch:
> [PATCH v2 10/46] net: jme: convert to generic DMA API
> Pointed out the issue also, thank you Michal.
> But the fix was incorrect. It would unmap needed address
> when low memory.

My patch also fixed another issue - from correctness point of view,
you should not use virt_to_page+dma_map_page here, but dma_map_single.

Best Regards,
Micha=C5=82 Miros=C5=82aw
