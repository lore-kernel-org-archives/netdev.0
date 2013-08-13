From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net] skge: dma_sync the whole receive buffer
Date: Tue, 13 Aug 2013 15:20:33 -0700
Message-ID: <20130813152033.602db707@nehalam.linuxnetplumber.net>
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
Received: from mail-pd0-f177.google.com ([209.85.192.177]:64453 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759290Ab3HMWUh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 18:20:37 -0400
Received: by mail-pd0-f177.google.com with SMTP id y10so5527887pdj.22
        for <netdev@vger.kernel.org>; Tue, 13 Aug 2013 15:20:36 -0700 (PDT)
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

I am retesting with hardware, will have answer tonight.
