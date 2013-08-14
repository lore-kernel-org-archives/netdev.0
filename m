From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net] skge: dma_sync the whole receive buffer
Date: Tue, 13 Aug 2013 18:00:36 -0700
Message-ID: <20130813180036.3e639789@nehalam.linuxnetplumber.net>
References: <20130810104100.0ae20aa6@nehalam.linuxnetplumber.net>
	<20130810.132935.1257046025460198490.davem@davemloft.net>
	<20130810150207.37432299@nehalam.linuxnetplumber.net>
	<20130813.150955.1471100759610399160.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: pomidorabelisima@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:57697 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757856Ab3HNBAk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 21:00:40 -0400
Received: by mail-pb0-f48.google.com with SMTP id ma3so8549854pbc.21
        for <netdev@vger.kernel.org>; Tue, 13 Aug 2013 18:00:40 -0700 (PDT)
In-Reply-To: <20130813.150955.1471100759610399160.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 13 Aug 2013 15:09:55 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <stephen@networkplumber.org>
> Date: Sat, 10 Aug 2013 15:02:07 -0700
> 
> > The DMA sync should sync the whole receive buffer, not just
> > part of it. Fixes log messages dma_sync_check.
> > 
> > Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
> 
> Applied, but I really suspect that your "check DMA mapping errors"
> patch has added a serious regression.  A regression much worse than
> the bug you were trying to fix with that change.

Argh. The problem is deeper than that. Device got broken somewhere between
3.2 and 3.4. My old Dlink card works on 3.2 but gets DMA errors on 3.4.
The config's are different though so checking that as well.
