From: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH v7 3/3] Bluetooth: btusb: Configure Marvell to use one of
 the pins for oob wakeup
Date: Thu, 16 Feb 2017 17:22:42 +0100
Message-ID: <B13DDD1D-479B-4B13-BB6B-ED103A59158A@holtmann.org>
References: <20170201222410.145612-1-rajatja@google.com>
 <20170201222410.145612-3-rajatja@google.com>
Mime-Version: 1.0 (Mac OS X Mail 10.2 \(3259\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        "Gustavo F. Padovan" <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>,
        Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Amitkumar Karwar <akarwar-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
        Wei-Ning Huang <wnhuang-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
        Xinming Hu <huxm-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Brian Norris <briannorris-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rajatxjain-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: Rajat Jain <rajatja-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170201222410.145612-3-rajatja-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

> The Marvell devices may have many gpio pins, and hence for wakeup
> on these out-of-band pins, the chip needs to be told which pin is
> to be used for wakeup, using an hci command.
> 
> Thus, we read the pin number etc from the device tree node and send
> a command to the chip.
> 
> Signed-off-by: Rajat Jain <rajatja-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> Reviewed-by: Brian Norris <briannorris-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
> Acked-by: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> ---
> v7: Same as v6
> v6: same as v5
> v5: same as v5
> v4: same as v3
> v3: * remove the Marvell specific id table and check
>    * Add reference to marvell-bt-8xxx.txt in btusb.txt
>    * Add "Reviewed-by" and "Acked-by"    
> v2: Fix the binding document to specify to use "wakeup" interrupt-name
> 
> Documentation/devicetree/bindings/net/btusb.txt    |  3 ++
> .../{marvell-bt-sd8xxx.txt => marvell-bt-8xxx.txt} | 46 +++++++++++++++----
> drivers/bluetooth/btusb.c                          | 51 ++++++++++++++++++++++
> 3 files changed, 92 insertions(+), 8 deletions(-)
> rename Documentation/devicetree/bindings/net/{marvell-bt-sd8xxx.txt => marvell-bt-8xxx.txt} (50%)

all 3 patches have been applied to bluetooth-next tree.

Regards

Marcel

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
