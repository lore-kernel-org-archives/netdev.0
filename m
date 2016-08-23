From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] tun: fix transmit timestamp support
Date: Tue, 23 Aug 2016 16:15:02 -0700
Message-ID: <1471994102.14381.60.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1471990953-6793-1-git-send-email-soheil.kdev@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        Soheil Hassas Yeganeh <soheil@google.com>
To: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:34629 "EHLO
        mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753177AbcHWXPE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 19:15:04 -0400
Received: by mail-pa0-f67.google.com with SMTP id hh10so10652004pac.1
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2016 16:15:04 -0700 (PDT)
In-Reply-To: <1471990953-6793-1-git-send-email-soheil.kdev@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-08-23 at 18:22 -0400, Soheil Hassas Yeganeh wrote:
> From: Soheil Hassas Yeganeh <soheil@google.com>
> 
> Instead of using sock_tx_timestamp, use skb_tx_timestamp to record
> software transmit timestamp of a packet.
> 
> sock_tx_timestamp resets and overrides the tx_flags of the skb.
> The function is intended to be called from within the protocol
> layer when creating the skb, not from a device driver. This is
> inconsistent with other drivers and will cause issues for TCP.
> 

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks !
