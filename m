From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next] dp83640: don't hold spinlock while calling
 netif_rx_ni
Date: Thu, 31 Aug 2017 09:25:57 +0200
Message-ID: <20170831072557.i5tnrb64fohlj56p@localhost>
References: <20170830065847.2444-1-stefan.sorensen@spectralink.com>
 <20170830.145031.1158341283102125578.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: stefan.sorensen@spectralink.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:36275 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751291AbdHaH0C (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 03:26:02 -0400
Received: by mail-wr0-f193.google.com with SMTP id 40so5148629wrv.3
        for <netdev@vger.kernel.org>; Thu, 31 Aug 2017 00:26:01 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170830.145031.1158341283102125578.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 30, 2017 at 02:50:31PM -0700, David Miller wrote:
> From: Stefan Sørensen <stefan.sorensen@spectralink.com>
> Date: Wed, 30 Aug 2017 08:58:47 +0200
> 
> > We should not hold a spinlock while pushing the skb into the networking
> > stack, so move the call to netif_rx_ni out of the critical region to where
> > we have dropped the spinlock.
> > 
> > Signed-off-by: Stefan Sørensen <stefan.sorensen@spectralink.com>
> 
> Looks good, applied, thanks.

And thanks, Stefan, for following up on this.  For the record, we
discussed this fix back in April.

    https://patchwork.ozlabs.org/patch/752201/

Cheers,
Richard
