From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 01/10] net: introduce time stamping wrapper for
 netif_rx.
Date: Sun, 12 Jun 2011 14:04:07 +0200
Message-ID: <20110612120407.GA3174@riccoc20.at.omicron.at>
References: <20110610082056.5ab6b981@nehalam.ftrdhcpuser.net>
 <20110610172747.GA2925@riccoc20.at.omicron.at>
 <20110610111924.54fede19@nehalam.ftrdhcpuser.net>
 <20110611.161025.317157517912316585.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:45542 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753233Ab1FLMEL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jun 2011 08:04:11 -0400
Received: by bwz15 with SMTP id 15so3121074bwz.19
        for <netdev@vger.kernel.org>; Sun, 12 Jun 2011 05:04:10 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20110611.161025.317157517912316585.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 11, 2011 at 04:10:25PM -0700, David Miller wrote:
> 
> Also, it makes no sense to add this for obsolete RX processing such
> that netif_rx() is.
> 
> If drivers want to add fancy features like this timestamping stuff,
> they better move on to NAPI, GRO, etc. first.  Putting support for
> new features into deprecating things like netif_rx() makes no
> sense at all.

Okay, I see your point. I won't bother trying to improve the "academy
of ancient drivers," and I'll repost without the netif_rx wrapper.

However, I do want to support the coldfire fec driver, since Freescale
is selling two coldfire development boards with the dp83640 phy. But I
don't think it makes sense to try and upgrade the fec driver to napi,
when a simple "if !skb_defer_rx_timestamp" will do there.

Thanks,
Richard
