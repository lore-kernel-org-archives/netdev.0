From: Oliver Neukum <oneukum@suse.com>
Subject: Re: [PATCH] usbnet: prevent device rpm suspend in usbnet_probe
 function
Date: Thu, 10 Nov 2016 12:22:37 +0100
Message-ID: <1478776957.2428.15.camel@suse.com>
References: <Pine.LNX.4.44L0.1611081339060.1499-100000@iolanthe.rowland.org>
         <1478692735.2428.10.camel@suse.com> <8760nwj0l3.fsf@miraculix.mork.no>
         <CAAd53p5W4xpSYsFZ00deQDh-gZBijn_ApreE9NmC=_B_MAQaug@mail.gmail.com>
         <87a8d7h9q1.fsf@miraculix.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Kai-Heng Feng <kai.heng.feng@canonical.com>,
        Alan Stern <stern@rowland.harvard.edu>,
        linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
        netdev@vger.kernel.org,
        Mathias Nyman <mathias.nyman@linux.intel.com>
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87a8d7h9q1.fsf@miraculix.mork.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2016-11-10 at 12:09 +0100, Bjørn Mork wrote:
> Kai-Heng Feng <kai.heng.feng@canonical.com> writes:
> > On Wed, Nov 9, 2016 at 8:32 PM, Bjørn Mork <bjorn@mork.no> wrote:
> >> Oliver Neukum <oneukum@suse.com> writes:
> >>
> >>> On Tue, 2016-11-08 at 13:44 -0500, Alan Stern wrote:
> >>>
> >>>> These problems could very well be caused by running at SuperSpeed
> >>>> (USB-3) instead of high speed (USB-2).
> >
> > Yes, it's running at SuperSpeed, on a Kabylake laptop.
> >
> > It does not have this issue on a Broadwell laptop, also running at SuperSpeed.
> 
> Then I must join Oliver, being very surprised by where in the stack you
> attempt to fix the issue.  What you write above indicates a problem in
> pci bridge or usb host controller, doesn't it?

Indeed. And this means we need an XHCI specialist.
Mathias, we have a failure specific to one implementation of XHCI.

	Regards
		Oliver
