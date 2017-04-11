From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next RFC] Generic XDP
Date: Tue, 11 Apr 2017 09:28:08 -0700
Message-ID: <1491928088.10587.63.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170409.133528.660876505013192371.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xdp-newbies@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:36476 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750732AbdDKQ2L (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 12:28:11 -0400
In-Reply-To: <20170409.133528.660876505013192371.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2017-04-09 at 13:35 -0700, David Miller wrote:
> This provides a generic non-optimized XDP implementation when the
> device driver does not provide an optimized one.
> 
> It is arguable that perhaps I should have required something like
> this as part of the initial XDP feature merge.
> 
> I believe this is critical for two reasons:
> 
> 1) Accessibility.  More people can play with XDP with less
>    dependencies.  Yes I know we have XDP support in virtio_net, but
>    that just creates another depedency for learning how to use this
>    facility.
> 
>    I wrote this to make life easier for the XDP newbies.
> 
> 2) As a model for what the expected semantics are.  If there is a pure
>    generic core implementation, it serves as a semantic example for
>    driver folks adding XDP support.
> 

Nice !

It seems that this implementation is not vlan aware ?

It seems that some native XDP implementations are not vlan aware as
well.

Probably need to disable VLAN acceleration when/if XDP is used.
