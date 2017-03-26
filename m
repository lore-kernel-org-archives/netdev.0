From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: TX vs RX pause frame question
Date: Sun, 26 Mar 2017 10:55:30 -0700
Message-ID: <58D80092.9020902@gmail.com>
References: <1490523071.3177.56.camel@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f53.google.com ([74.125.83.53]:36519 "EHLO
        mail-pg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751454AbdCZSDJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 26 Mar 2017 14:03:09 -0400
Received: by mail-pg0-f53.google.com with SMTP id g2so18200227pge.3
        for <netdev@vger.kernel.org>; Sun, 26 Mar 2017 11:03:08 -0700 (PDT)
In-Reply-To: <1490523071.3177.56.camel@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-03-26 03:11 AM, Benjamin Herrenschmidt wrote:
> Hi !
> 
> It's not 100% clear to me looking at various drivers what is
> considered "rx_pause" and what is "tx_pause" (from the ethtool
> terminology).
> 
> Is "rx_pause" about receiving pause frame to throttle the transmitter
> or is it about sending pause frames when the receiver gets full ?
> 
> Thanks,
> Ben.
> 

The common implementation, at least on the Intel devices, is rx_pause
should be enabled so the device will respond to receiving a pause frame, e.g.
stop sending packets. And tx_pause is for enabling/disabling sending of
pause frames.

Thanks,
John
