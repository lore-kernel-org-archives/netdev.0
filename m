From: Samuel Ortiz <sameo@linux.intel.com>
Subject: Re: [PATCH v2 0/8] NFC: fix device allocation and nfcmrvl crashes
Date: Wed, 19 Apr 2017 01:24:31 +0200
Message-ID: <20170418232431.GB13724@zurbaran.ger.intel.com>
References: <20170330101542.15384-1-johan@kernel.org>
 <20170418100916.GB2823@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Johan Hovold <johan@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170418100916.GB2823@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Johan,

On Tue, Apr 18, 2017 at 12:09:16PM +0200, Johan Hovold wrote:
> On Thu, Mar 30, 2017 at 12:15:34PM +0200, Johan Hovold wrote:
> > This started out with the observation that the nfcmrvl_uart driver
> > unconditionally dereferenced the tty class device despite the fact that
> > not every tty has an associated struct device (Unix98 ptys). Some
> > further changes were needed in the common nfcmrvl code to fully address
> > this, some of which also incidentally fixed a few related bugs (e.g.
> > resource leaks in error paths).
> > 
> > While fixing this I stumbled over a regression in NFC core that lead to
> > broken registration error paths and misnamed workqueues.
> > 
> > Note that this has only been tested by configuring the n_hci line
> > discipline for different ttys without any actual NFC hardware connected.
> 
> > Johan Hovold (8):
> >   NFC: fix broken device allocation
> >   NFC: nfcmrvl_uart: add missing tty-device sanity check
> >   NFC: nfcmrvl: do not use device-managed resources
> >   NFC: nfcmrvl: use nfc-device for firmware download
> >   NFC: nfcmrvl: fix firmware-management initialisation
> >   NFC: nfcmrvl_uart: fix device-node leak during probe
> >   NFC: nfcmrvl_usb: use interface as phy device
> >   NFC: nfcmrvl: allow gpio 0 for reset signalling
> 
> Any chance of getting these into 4.12, Samuel?
I have yours and Mark Greer patchset pending. I'll push them to nfc-next
and see if I can send another pull request to Dave by the end of this
week.

Cheers,
Samuel.
