From: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH v3 0/4] TI Bluetooth serdev support
Date: Thu, 13 Apr 2017 19:24:30 +0200
Message-ID: <A73F0F81-63B4-4555-9865-F35469902338@holtmann.org>
References: <20170413150353.7389-1-robh@kernel.org>
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Linux Bluetooth <linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        linux-arm-kernel <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
        "Gustavo F. Padovan" <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>,
        Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Wei Xu <xuwei5-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>, Eyal Reizer <eyalr-l0cyMroinI0@public.gmane.org>,
        Satish Patel <satish.patel-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170413150353.7389-1-robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Rob,

> This series adds serdev support to the HCI LL protocol used on TI BT
> modules and enables support on HiKey board with with the WL1835 module.
> With this the custom TI UIM daemon and btattach are no longer needed.
> 
> The series is available on this git branch[1]. This version is rebased on 
> bluetooth-next tree containing its dependencies.
> 
> Rob
> 
> [1] git://git.kernel.org/pub/scm/linux/kernel/git/robh/linux.git ti-bluetooth
> 
> Rob Herring (4):
>  dt-bindings: net: Add TI WiLink shared transport binding
>  bluetooth: hci_uart: remove unused hci_uart_init_tty
>  bluetooth: hci_uart: add LL protocol serdev driver support
>  arm64: dts: hikey: add WL1835 Bluetooth device node
> 
> .../devicetree/bindings/net/ti,wilink-st.txt       |  35 +++
> arch/arm64/boot/dts/hisilicon/hi6220-hikey.dts     |   5 +
> drivers/bluetooth/hci_ldisc.c                      |  19 --
> drivers/bluetooth/hci_ll.c                         | 262 ++++++++++++++++++++-
> drivers/bluetooth/hci_uart.h                       |   1 -
> 5 files changed, 301 insertions(+), 21 deletions(-)
> create mode 100644 Documentation/devicetree/bindings/net/ti,wilink-st.txt

all 4 patches have been applied to bluetooth-next tree.

Regards

Marcel
