From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH 3/3] Bluetooth: btusb: Configure Marvel to use one of the
 pins for oob wakeup
Date: Mon, 19 Dec 2016 16:04:28 -0600
Message-ID: <20161219220428.sn7pspjlss2w2rqb@rob-hp-laptop>
References: <1481742779-15105-1-git-send-email-rajatja@google.com>
 <1481742779-15105-3-git-send-email-rajatja@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mark Rutland <mark.rutland@arm.com>,
        Marcel Holtmann <marcel@holtmann.org>,
        Gustavo Padovan <gustavo@padovan.org>,
        Johan Hedberg <johan.hedberg@gmail.com>,
        Amitkumar Karwar <akarwar@marvell.com>,
        Wei-Ning Huang <wnhuang@chromium.org>,
        Xinming Hu <huxm@marvell.com>, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-bluetooth@vger.kernel.org,
        Brian Norris <briannorris@google.com>, rajatxjain@gmail.com
To: Rajat Jain <rajatja@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:34311 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751764AbcLSWEa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2016 17:04:30 -0500
Content-Disposition: inline
In-Reply-To: <1481742779-15105-3-git-send-email-rajatja@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 14, 2016 at 11:12:59AM -0800, Rajat Jain wrote:
> The Marvell devices may have many gpio pins, and hence for wakeup
> on these out-of-band pins, the chip needs to be told which pin is
> to be used for wakeup, using an hci command.
> 
> Thus, we read the pin number etc from the device tree node and send
> a command to the chip.
> 
> Signed-off-by: Rajat Jain <rajatja@google.com>
> ---
> Note that while I would have liked to name the compatible string as more
> like "marvell, usb8997-bt", the devicetrees/bindings/usb/usb-device.txt
> requires the compatible property to be of the form "usbVID,PID".
> 
>  .../{marvell-bt-sd8xxx.txt => marvell-bt-8xxx.txt} | 25 ++++++++-

Acked-by: Rob Herring <robh@kernel.org>

>  drivers/bluetooth/btusb.c                          | 59 ++++++++++++++++++++++
>  2 files changed, 82 insertions(+), 2 deletions(-)
>  rename Documentation/devicetree/bindings/net/{marvell-bt-sd8xxx.txt => marvell-bt-8xxx.txt} (76%)
