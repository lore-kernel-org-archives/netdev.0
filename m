From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Subject: Re: [PATCH] net: sh_eth: Add support of device tree probe
Date: Thu, 7 Feb 2013 09:58:58 +0900
Message-ID: <CABMQnVLr9WqMWC6z3BuYyBvNSXM491VwrZ+DcKd3qGu0UN-G3Q@mail.gmail.com>
References: <1360116019-8870-1-git-send-email-horms+renesas@verge.net.au> <87pq0dg7ot.wl%kuninori.morimoto.gx@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Simon Horman <horms+renesas@verge.net.au>, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	Magnus Damm <magnus.damm@gmail.com>
To: Kuninori Morimoto <kuninori.morimoto.gx@renesas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:53300 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752219Ab3BGA7a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2013 19:59:30 -0500
Received: by mail-wg0-f49.google.com with SMTP id 15so1567769wgd.4
        for <netdev@vger.kernel.org>; Wed, 06 Feb 2013 16:59:29 -0800 (PST)
In-Reply-To: <87pq0dg7ot.wl%kuninori.morimoto.gx@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Wed, Feb 6, 2013 at 5:36 PM, Kuninori Morimoto
<kuninori.morimoto.gx@renesas.com> wrote:
>
> Hi Simon, Iwamatsu-san
>
>> +Required properties:
>> +- compatible:                   "renesas,sh-eth";
>> +- interrupt-parent:             The phandle for the interrupt controller that
>> +                                services interrupts for this device.
>> +- reg:                          Offset and length of the register set for the
>> +                                device.
>> +- interrupts:                   Interrupt mapping for the sh_eth interrupt
>> +                                sources (vector id).
>> +- phy-mode:              String, operation mode of the PHY interface.
>> +- sh-eth,edmac-endian:          String, endian of sh_eth dmac.
>
> I believe endian is only little/big.
> It can be "bool" settings, not "string" ?
>

If we use bool , we may use this as "sh-eth,edmac-endian-big" or
sh-eth,edmac-endian-little.
Or we define big-endian, and when using big-endian, we specify this.
Either way is okay.

>> +- sh-eth,endian:                String, endian of sh_eth dmac.
>
> Is this really used it in this driver ?
>

Yes. In many cases, this uses little-endian, but user may specify
big-endian, I think.

Best regards,
  Nobuhiro

-- 
Nobuhiro Iwamatsu
