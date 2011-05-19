From: Dennis Aberilla <dennis.aberilla@mimomax.com>
Subject: Re: [PATCH] drivers/net: ks8842 Fix crash on received packet when
	in PIO mode.
Date: Fri, 20 May 2011 11:30:16 +1200
Message-ID: <20110519233014.GA7329@dens-work>
References: <20110518225945.GB6416@dens-work> <20110519.161228.1163475688237712245.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: info@mocean-labs.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog112.obsmtp.com ([74.125.149.207]:49709 "HELO
	na3sys009aog112.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932238Ab1ESXaW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2011 19:30:22 -0400
Received: by mail-pw0-f42.google.com with SMTP id 3so1683583pwj.29
        for <netdev@vger.kernel.org>; Thu, 19 May 2011 16:30:21 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20110519.161228.1163475688237712245.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 19, 2011 at 04:12:28PM -0400, David Miller wrote:
> From: Dennis Aberilla <dennis.aberilla@mimomax.com>
> Date: Thu, 19 May 2011 10:59:47 +1200
> 
> > This patch fixes a kernel crash during packet reception due to not
> > enough allocated bytes for the skb. This applies to the driver when
> > running in PIO mode in an ISA bus setup.
> > 
> > Signed-off-by: Dennis Aberilla <denzzzhome@yahoo.com>
> 
> If you're trying to accomodate the fact that the loops iterate
> always by 2 or 4 bytes at a time, then you will need to allocate
> up to "3" bytes of slack space, not just "2".
> 
> You need to describe exactly what the precise problem is in your
> commit message, or else people might find it difficult to figure
> out exactly what the problem is.

Ah right, it should actually be 3. Yes, it accounts for the fact that the
loops are reading the Rx buffer 4 bytes at a time. Sorry it wasn't too
clear previously.

|Dennis
=======================================================================
This email, including any attachments, is only for the intended
addressee.  It is subject to copyright, is confidential and may be
the subject of legal or other privilege, none of which is waived or
lost by reason of this transmission.
If the receiver is not the intended addressee, please accept our
apologies, notify us by return, delete all copies and perform no
other act on the email.
Unfortunately, we cannot warrant that the email has not been
altered or corrupted during transmission.
=======================================================================

