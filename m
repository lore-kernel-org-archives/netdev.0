From: Samuel Ortiz <sameo@linux.intel.com>
Subject: Re: [PATCH v2 0/8] NFC: fix device allocation and nfcmrvl crashes
Date: Thu, 27 Apr 2017 00:42:38 +0200
Message-ID: <20170426224238.GB3717@zurbaran.ger.intel.com>
References: <20170330101542.15384-1-johan@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Johan Hovold <johan@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:29540 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1031877AbdDZWnY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 26 Apr 2017 18:43:24 -0400
Content-Disposition: inline
In-Reply-To: <20170330101542.15384-1-johan@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Johan,

On Thu, Mar 30, 2017 at 12:15:34PM +0200, Johan Hovold wrote:
> This started out with the observation that the nfcmrvl_uart driver
> unconditionally dereferenced the tty class device despite the fact that
> not every tty has an associated struct device (Unix98 ptys). Some
> further changes were needed in the common nfcmrvl code to fully address
> this, some of which also incidentally fixed a few related bugs (e.g.
> resource leaks in error paths).
> 
> While fixing this I stumbled over a regression in NFC core that lead to
> broken registration error paths and misnamed workqueues.
> 
> Note that this has only been tested by configuring the n_hci line
> discipline for different ttys without any actual NFC hardware connected.
> 
> Johan
> 
> 
> Changes in v2
>  - fix typo in commit message (1/8)
>  - release reset gpio in error paths (3/8)
>  - fix description of patch impact (3/8)
>  - allow gpio 0 to be used for reset signalling (8/8, new)
> 
> 
> Johan Hovold (8):
>   NFC: fix broken device allocation
>   NFC: nfcmrvl_uart: add missing tty-device sanity check
>   NFC: nfcmrvl: do not use device-managed resources
>   NFC: nfcmrvl: use nfc-device for firmware download
>   NFC: nfcmrvl: fix firmware-management initialisation
>   NFC: nfcmrvl_uart: fix device-node leak during probe
>   NFC: nfcmrvl_usb: use interface as phy device
>   NFC: nfcmrvl: allow gpio 0 for reset signalling
Applied, thanks.

Cheers,
Samuel.
