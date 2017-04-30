From: Adam Ford <aford173-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 0/4] TI Bluetooth serdev support
Date: Sun, 30 Apr 2017 10:14:20 -0500
Message-ID: <CAHCN7xJUxZm1qKAxT0kaK6qoDg+HWOJK7sTH-q9za4HJuUwe8Q@mail.gmail.com>
References: <20170405183005.20570-1-robh@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
        linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Gustavo Padovan <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>,
        Satish Patel <satish.patel-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        Wei Xu <xuwei5-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>, Eyal Reizer <eyalr-l0cyMroinI0@public.gmane.org>,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170405183005.20570-1-robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 5, 2017 at 1:30 PM, Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
> This series adds serdev support to the HCI LL protocol used on TI BT
> modules and enables support on HiKey board with with the WL1835 module.
> With this the custom TI UIM daemon and btattach are no longer needed.

Without UIM daemon, what instruction do you use to load the BT firmware?

I was thinking 'hciattach' but I was having trouble.  I was hoping you
might have some insight.

 hciattach -t 30 -s 115200 /dev/ttymxc1 texas 3000000 flow  Just
returns a timeout.

I modified my i.MX6 device tree per the binding documentation and
setup the regulators and enable GPIO pins.

adam
>
> The series is available on this git branch[1]. Patch 2 is just clean-up
> and can be applied independently. Patch 3 is dependent on the series
> "Nokia H4+ support". I'd suggest both series are merged thru the BT tree.
>
> Rob
>
> [1] git://git.kernel.org/pub/scm/linux/kernel/git/robh/linux.git ti-bluetooth
>
> Rob Herring (4):
>   dt-bindings: net: Add TI WiLink shared transport binding
>   bluetooth: hci_uart: remove unused hci_uart_init_tty
>   bluetooth: hci_uart: add LL protocol serdev driver support
>   arm64: dts: hikey: add WL1835 Bluetooth device node
>
>  .../devicetree/bindings/net/ti,wilink-st.txt       |  35 +++
>  arch/arm64/boot/dts/hisilicon/hi6220-hikey.dts     |   5 +
>  drivers/bluetooth/hci_ldisc.c                      |  19 --
>  drivers/bluetooth/hci_ll.c                         | 261 ++++++++++++++++++++-
>  drivers/bluetooth/hci_uart.h                       |   1 -
>  5 files changed, 300 insertions(+), 21 deletions(-)
>  create mode 100644 Documentation/devicetree/bindings/net/ti,wilink-st.txt
>
> --
> 2.10.1
>
>
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
