From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: v3.12-stable-queue build errors
Date: Mon, 27 Apr 2015 09:17:03 -0700
Message-ID: <20150427161703.GC14248@roeck-us.net>
References: <20150425141609.GA1147@roeck-us.net>
 <553DF71E.7060409@suse.cz>
 <87fv7lk2i0.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Slaby <jslaby@suse.cz>, David Miller <davem@davemloft.net>,
	ML netdev <netdev@vger.kernel.org>, stable@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:41125 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752972AbbD0QRc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2015 12:17:32 -0400
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.85)
	(envelope-from <linux@roeck-us.net>)
	id 1Ymlit-004Gg9-O2
	for netdev@vger.kernel.org; Mon, 27 Apr 2015 16:17:31 +0000
Content-Disposition: inline
In-Reply-To: <87fv7lk2i0.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 27, 2015 at 10:35:51AM -0500, Eric W. Biederman wrote:
> Jiri Slaby <jslaby@suse.cz> writes:
> 
> > On 04/25/2015, 04:16 PM, Guenter Roeck wrote:
> >> Several powerpc build fail with:
> >> 
> >> drivers/net/ethernet/freescale/gianfar.c: In function 'gfar_start_xmit':
> >> drivers/net/ethernet/freescale/gianfar.c:2146:3: error: implicit declaration of
> >> function 'dev_consume_skb_any' [-Werror=implicit-function-declaration]
> >>    dev_consume_skb_any(skb);
> >> 
> >> dev_consume_skb_any() does not exist in 3.12.
> >> 
> >> Introduced by 'gianfar: Carefully free skbs in functions called by netpoll'.
> >
> > Eric, David,
> >
> > what action should I take here?
> >
> > 1) take also:
> > commit e6247027e5173c00efb2084d688d06ff835bc3b0
> > Author: Eric Dumazet <edumazet@google.com>
> > Date:   Thu Dec 5 04:45:08 2013 -0800
> >
> >     net: introduce dev_consume_skb_any()
> >
> >
> > 2) drop 'gianfar: Carefully free skbs in functions called by netpoll'
> > from stable-3.12
> 
> This is probably the most reasonable.   KISS.
> 
Greg dropped the patch from 3.10. 

Guenter
