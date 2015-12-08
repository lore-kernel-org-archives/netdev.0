From: Edward Cree <ecree@solarflare.com>
Subject: Re: Checksum offload queries
Date: Tue, 8 Dec 2015 17:24:55 +0000
Message-ID: <56671267.9090607@solarflare.com>
References: <5665A848.9010001@solarflare.com>
 <CALx6S37+YVqpVL6XX2KCHZad84DGpqpL+K4LdDZr5H-feiyjow@mail.gmail.com>
 <5666FF46.6030702@solarflare.com>
 <20151208.120911.1930136653560954435.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <tom@herbertland.com>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:41341 "EHLO
	nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751002AbbLHRZE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 12:25:04 -0500
In-Reply-To: <20151208.120911.1930136653560954435.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/12/15 17:09, David Miller wrote:
> From: Edward Cree <ecree@solarflare.com>
> Date: Tue, 8 Dec 2015 16:03:18 +0000
>
>> NETIF_F_HW_CSUM is limited to one checksum per packet.
> This is false.
>
> As we demux encapsulation layers, we re-adjust the provided 1's
> complement sum provided and use that to validate the next layer.
The context here was transmit, not receive; the stack muxes encapsulation layers and then asks the hardware to fill in one checksum, it doesn't have any way to fill in 'adjusted' checksums in other layers.  The following paragraph (which you snipped) was discussing ways to get this kind of adjusted checksumming on transmit, by feeding the adjustments to the hardware.
