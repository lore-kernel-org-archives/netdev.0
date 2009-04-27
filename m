From: Steve.Glendinning@smsc.com
Subject: Re: [PATCH] smsc911x: add fifo byteswap support
Date: Mon, 27 Apr 2009 08:40:49 +0100
Message-ID: <OF7ABB7A00.E22FC2BA-ON802575A2.005A9008-802575A5.002A2FDC@smsc.com>
References: <aec7e5c30904231815x79d6f4e8g2e53de1fdeb7a73b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: davem@davemloft.net, Ian.Saturley@smsc.com, iwamatsu@nigauri.org,
	lethal@linux-sh.org, netdev@vger.kernel.org
To: Magnus Damm <magnus.damm@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.smsc.com ([170.129.50.11]:2525 "EHLO smsc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751897AbZD0HlG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Apr 2009 03:41:06 -0400
In-Reply-To: <aec7e5c30904231815x79d6f4e8g2e53de1fdeb7a73b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Magnus,

Slight correction: the newer devices *can* handle this in hardware, there 
are registers to control this swapping but the driver doesn't currently 
use them.  If I see a suitably broken design with a newer device I'll 
submit a patch to add this.

Looks great otherwise, thanks for adding the "health warning" :-)

Regards,
--
Steve Glendinning
SMSC GmbH
m: +44 777 933 9124
e: steve.glendinning@smsc.com



Magnus Damm <magnus.damm@gmail.com> wrote on 24/04/2009 02:15:03:

> On Thu, Apr 23, 2009 at 12:21 AM,  <Steve.Glendinning@smsc.com> wrote:
> > Magnus Damm <magnus.damm@gmail.com> wrote on 22/04/2009 15:55:53:
> >> This patch adds fifo byteswap support to the smsc911x driver.
> 
> > Performance will be suboptimal with this software byteswapping,
> > so I think we should also add a comment to stress that this is
> > a "last resort" workaround for broken hardware.
> 
> Good idea. How about adding the following to the header file right
> before the SMSC911X_SWAP_FIFO definition:
> 
> /*
>  * SMSC911X_SWAP_FIFO:
>  * Enables software byte swap for fifo data. Should only be used as a
>  * "last resort" in the case of big endian mode on boards with 
incorrectly
>  * routed data bus to older devices such as LAN9118. Newer devices such 
as
>  * LAN9221 handle this in hardware.
>  */
> 
> Let me know if you want to improve the comment somehow, otherwise I'll
> just update the patch and repost a V2.
> 
> Cheers,
> 
> / magnus

