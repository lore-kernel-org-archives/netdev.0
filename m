From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH Resend] net: asix: add missing flag to struct
 driver_info
Date: Fri, 14 Feb 2014 15:48:53 -0500 (EST)
Message-ID: <20140214.154853.1291869116525546930.davem@davemloft.net>
References: <1392316239-17335-1-git-send-email-emilgoode@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ming.lei@canonical.com, broonie@linaro.org,
	jeffrey.t.kirsher@intel.com, gdt@gdt.id.au,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: emilgoode@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1392316239-17335-1-git-send-email-emilgoode@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Emil Goode <emilgoode@gmail.com>
Date: Thu, 13 Feb 2014 19:30:39 +0100

> The struct driver_info ax88178_info is assigned the function
> asix_rx_fixup_common as it's rx_fixup callback. This means that
> FLAG_MULTI_PACKET must be set as this function is cloning the
> data and calling usbnet_skb_return. Not setting this flag leads
> to usbnet_skb_return beeing called a second time from within
> the rx_process function in the usbnet module.
>=20
> Signed-off-by: Emil Goode <emilgoode@gmail.com>
> Reported-by: Bj=F8rn Mork <bjorn@mork.no>

Applied and queued up for -stable.

It would be great if there were some way to validate these
callback flags requirements and catch such errors.
