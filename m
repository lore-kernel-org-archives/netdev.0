From: Kurt Van Dijck <dev.kurt@vandijck-laurijssen.be>
Subject: Re: [PATCH 1/4] can: dev: Add support for limiting configured bitrate
Date: Wed, 26 Jul 2017 22:04:03 +0200
Message-ID: <20170726200403.GD6873@airbook.vandijck-laurijssen.be>
References: <20170719233654.25908-1-fcooper@ti.com>
 <20170719233654.25908-2-fcooper@ti.com>
 <f45ea1b4-0f46-0002-a89b-b997f2693bb5@hartkopp.net>
 <055c00f5-0775-4e35-309c-0d1c8aa0afdf@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Oliver Hartkopp <socketcan@hartkopp.net>,
        linux-kernel@vger.kernel.org, devicetree@vger.kernel.org,
        netdev@vger.kernel.org, linux-can@vger.kernel.org,
        wg@grandegger.com, mkl@pengutronix.de, robh+dt@kernel.org,
        quentin.schulz@free-electrons.com, andrew@lunn.ch
To: Franklin S Cooper Jr <fcooper@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay-b02.edpnet.be ([212.71.1.222]:51743 "EHLO
        relay-b02.edpnet.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750930AbdGZUF2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2017 16:05:28 -0400
Content-Disposition: inline
In-Reply-To: <055c00f5-0775-4e35-309c-0d1c8aa0afdf@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I know my response is late ...

> Hi Oliver
> On 07/20/2017 02:43 AM, Oliver Hartkopp wrote:
> > Hi Franklin,
> > 
> > On 07/20/2017 01:36 AM, Franklin S Cooper Jr wrote:
> > 
> >> +#ifdef CONFIG_OF
> >> +void of_transceiver_is_fixed(struct net_device *dev)
> >> +{
> > 
> > (..)
> > 
> >> +}
> >> +EXPORT_SYMBOL(of_transceiver_is_fixed);
> >> +#endif
> > 
> > I'm not sure about the naming here.
> > 
> > As this is a CAN transceiver related option it should be named accordingly:

I contest the the name too:
1) the can transceiver isn't fixed at all, it limited to the higher
bitrates.

2) of_can_transceiver_is_fixed suggests to test if a transceiver is
fixed, it does not suggest to load some properties from the device tree.
of_can_load_transceiver looks way more clear to me.

That's my opinion.
The important things, like the contents of the functions, look good.

Kind regards,
Kurt Van Dijck
