From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: TX vs RX pause frame question
Date: Mon, 27 Mar 2017 08:08:26 +1100
Message-ID: <1490562506.3177.59.camel@kernel.crashing.org>
References: <1490523071.3177.56.camel@kernel.crashing.org>
         <58D80092.9020902@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: John Fastabend <john.fastabend@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:38002 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751570AbdCZVIo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 26 Mar 2017 17:08:44 -0400
In-Reply-To: <58D80092.9020902@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2017-03-26 at 10:55 -0700, John Fastabend wrote:
> On 17-03-26 03:11 AM, Benjamin Herrenschmidt wrote:
> > Hi !
> > 
> > It's not 100% clear to me looking at various drivers what is
> > considered "rx_pause" and what is "tx_pause" (from the ethtool
> > terminology).
> > 
> > Is "rx_pause" about receiving pause frame to throttle the transmitter
> > or is it about sending pause frames when the receiver gets full ?
> > 
> > Thanks,
> > Ben.
> > 
> 
> The common implementation, at least on the Intel devices, is rx_pause
> should be enabled so the device will respond to receiving a pause frame, e.g.
> stop sending packets. And tx_pause is for enabling/disabling sending of
> pause frames.

Thanks, I'll have my driver match that.

Cheers,
Ben.
