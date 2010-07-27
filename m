From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] drivers/net/vxge: Use pr_<level>, fix logging
 macros
Date: Tue, 27 Jul 2010 14:43:35 -0700
Message-ID: <1280267015.24054.42.camel@Joe-Laptop.home>
References: <1280263388.24054.27.camel@Joe-Laptop.home>
	 <20100727213819.GC25556@exar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ramkrishna Vepa <Ramkrishna.Vepa@exar.com>,
	Sreenivasa Honnur <Sreenivasa.Honnur@exar.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Jon Mason <jon.mason@exar.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:2134 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752715Ab0G0Vnh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jul 2010 17:43:37 -0400
In-Reply-To: <20100727213819.GC25556@exar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-07-27 at 16:38 -0500, Jon Mason wrote:
> On Tue, Jul 27, 2010 at 01:43:08PM -0700, Joe Perches wrote:
> > Use direct printing of logging messages to save text.
> I have a similar patch queued internally (pending testing).

Great.

[]

> Why not make the entire vxge_debug part of vxge_debug_ll?  If
> disabled, that code can be removed completely as it is unnecessary.
> Also, why not call printk directly from vxge_debug?  This code had too
> many levels of indirection before, remove all of them (as that is way
> I did in the internal patch).

'cause I don't really want to figure out the nesting,
I just want it to be smaller and easier to understand.

> I did not have any of these changes in my patch.  If you want to push
> this seperately, I ack it.

I'll resend separately.

cheers, Joe

