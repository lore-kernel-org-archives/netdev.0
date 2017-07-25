From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH v2 2/4] can: fixed-transceiver: Add documentation for CAN
 fixed transceiver bindings
Date: Tue, 25 Jul 2017 18:32:56 +0200
Message-ID: <29df7e04-01c6-a09b-491e-1354dab98cd0@hartkopp.net>
References: <20170724230521.1436-1-fcooper@ti.com>
 <20170724230521.1436-3-fcooper@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Franklin S Cooper Jr <fcooper@ti.com>,
        linux-kernel@vger.kernel.org, devicetree@vger.kernel.org,
        netdev@vger.kernel.org, linux-can@vger.kernel.org,
        wg@grandegger.com, mkl@pengutronix.de, robh+dt@kernel.org,
        quentin.schulz@free-electrons.com, dev.kurt@vandijck-laurijssen.be,
        andrew@lunn.ch, sergei.shtylyov@cogentembedded.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170724230521.1436-3-fcooper@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> + max-data-speed:	a positive non 0 value that determines the max data rate
> +			that can be used in CAN-FD mode. A value of -1 implies
> +			CAN-FD is not supported by the transceiver.
> +
> +Examples:

(..)

> +	fixed-transceiver {
> +		max-data-speed = <(-1)>;

Looks ugly IMHO.

Why didn't you stay on '0' for 'not supported'??

Regards,
Oliver
