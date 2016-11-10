From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: [PATCH] usbnet: prevent device rpm suspend in usbnet_probe
 function
Date: Thu, 10 Nov 2016 10:36:18 -0500 (EST)
Message-ID: <Pine.LNX.4.44L0.1611101035140.1667-100000@iolanthe.rowland.org>
References: <CAAd53p5W4xpSYsFZ00deQDh-gZBijn_ApreE9NmC=_B_MAQaug@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: =?UTF-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>,
        Oliver Neukum <oneukum@suse.com>,
        <linux-kernel@vger.kernel.org>, <linux-usb@vger.kernel.org>,
        <netdev@vger.kernel.org>
To: Kai-Heng Feng <kai.heng.feng@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from iolanthe.rowland.org ([192.131.102.54]:55404 "HELO
        iolanthe.rowland.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with SMTP id S933690AbcKJPgU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 10 Nov 2016 10:36:20 -0500
In-Reply-To: <CAAd53p5W4xpSYsFZ00deQDh-gZBijn_ApreE9NmC=_B_MAQaug@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 10 Nov 2016, Kai-Heng Feng wrote:

> Hi,
> 
> On Wed, Nov 9, 2016 at 8:32 PM, Bjørn Mork <bjorn@mork.no> wrote:
> > Oliver Neukum <oneukum@suse.com> writes:
> >
> >> On Tue, 2016-11-08 at 13:44 -0500, Alan Stern wrote:
> >>
> >>> These problems could very well be caused by running at SuperSpeed
> >>> (USB-3) instead of high speed (USB-2).
> 
> Yes, it's running at SuperSpeed, on a Kabylake laptop.
> 
> It does not have this issue on a Broadwell laptop, also running at SuperSpeed.
> 
> >>>
> >>> Is there any way to test what happens when the device is attached to
> >>> the computer by a USB-2 cable?  That would prevent it from operating at
> >>> SuperSpeed.
> 
> I recall old Intel PCH can change the USB host from XHCI to EHCI,
> newer PCH does not have this option.
> 
> Is there a way to force XHCI run at HighSpeed?

Yes, like I said above: Use a USB-2 cable instead of a USB-3 cable.

Alan Stern
