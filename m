From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH 1/4] can: dev: Add support for limiting configured bitrate
Date: Thu, 20 Jul 2017 09:43:18 +0200
Message-ID: <f45ea1b4-0f46-0002-a89b-b997f2693bb5@hartkopp.net>
References: <20170719233654.25908-1-fcooper@ti.com>
 <20170719233654.25908-2-fcooper@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Franklin S Cooper Jr <fcooper@ti.com>,
        linux-kernel@vger.kernel.org, devicetree@vger.kernel.org,
        netdev@vger.kernel.org, linux-can@vger.kernel.org,
        wg@grandegger.com, mkl@pengutronix.de, robh+dt@kernel.org,
        quentin.schulz@free-electrons.com, dev.kurt@vandijck-laurijssen.be,
        andrew@lunn.ch
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170719233654.25908-2-fcooper@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Franklin,

On 07/20/2017 01:36 AM, Franklin S Cooper Jr wrote:

> +#ifdef CONFIG_OF
> +void of_transceiver_is_fixed(struct net_device *dev)
> +{

(..)

> +}
> +EXPORT_SYMBOL(of_transceiver_is_fixed);
> +#endif

I'm not sure about the naming here.

As this is a CAN transceiver related option it should be named accordingly:

E.g.

	can_transceiver_is_fixed
	of_can_transceiver_is_fixed
	...

Especially as it is defined in include/linux/can/dev.h

Regards,
Oliver
