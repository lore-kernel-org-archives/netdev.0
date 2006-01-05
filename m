From: Jesse Brandeburg <jesse.brandeburg@gmail.com>
Subject: Re: PCI DEVICE ID PROBLEM and Intel Intergrated eth card - a bios bug (?)
Date: Wed, 4 Jan 2006 18:56:29 -0800
Message-ID: <4807377b0601041856n3a9f53e8uf03dc330190432ea@mail.gmail.com>
References: <1755038059.20060105013532@dione.ids.pl>
	 <4807377b0601041854t4b1410fco5c307db6704e03f6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: mj@ucw.cz, linux-kernel@vger.kernel.org,
	NetDEV list <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751241AbWAEC4c@vger.kernel.org>
To: Krzysztof Baranowski <kgb@dione.ids.pl>
In-Reply-To: <4807377b0601041854t4b1410fco5c307db6704e03f6@mail.gmail.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/4/06, Krzysztof Baranowski <kgb@dione.ids.pl> wrote:
<snip>
> After the upgrade my network card disappeared from both Linux and Win.
>
> After short investigation I noticed one strange incosistency. Under
> the new BIOS the PCI device is reported as PCI VENDOR ID 1459 (
> which is gigabyte) DEV_ID 1019. However Windows driver for this
> card (the lates from both intel and gigabyte) is looking for
> VENDOR_ID 8086 (intel).

IMO, gigabyte should not have changed the vendor id.  Effectively
they've said they will be the only ones supporting this hardware (not
intel).  Generally subvendor and subdevice ids should be the only
thing changed by OEMs.  Since it was changed by a bios upgrade i bet
its a bios bug and should be reported to gigabyte.

Until then you can hack your local kernel to get around it, but the
e1000 driver probably shouldn't change to support this device ID.

also, this is LKML and mentioning windows is just flame bait. :-)

jesse
