From: <Mario_Limonciello@Dell.com>
Subject: RE: [PATCH v3] r8152: Add support for setting pass through MAC
 address on RTL8153-AD
Date: Mon, 6 Jun 2016 14:43:37 +0000
Message-ID: <fa640d6998d8477b8ed43b70ddf6c0a8@ausx13mpc124.AMER.DELL.COM>
References: <1465222521-7217-1-git-send-email-mario_limonciello@dell.com>
 <20160606144009.GB4758@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <hayeswang@realtek.com>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, <linux-usb@vger.kernel.org>,
	<pali.rohar@gmail.com>, <anthony.wong@canonical.com>
To: <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160606144009.GB4758@kroah.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Greg KH [mailto:gregkh@linuxfoundation.org]
> Sent: Monday, June 6, 2016 9:40 AM
> To: Limonciello, Mario <Mario_Limonciello@Dell.com>
> Cc: hayeswang@realtek.com; LKML <linux-kernel@vger.kernel.org>; Netdev
> <netdev@vger.kernel.org>; Linux USB <linux-usb@vger.kernel.org>;
> pali.rohar@gmail.com; anthony.wong@canonical.com
> Subject: Re: [PATCH v3] r8152: Add support for setting pass through MAC
> address on RTL8153-AD
> 
> On Mon, Jun 06, 2016 at 09:15:20AM -0500, Mario Limonciello wrote:
> > Since this is a Realtek feature, I feel this shouldn't be moved into a platform
> > MAC address lookup.  The code should only be run when the correct
> Realtek device
> > is plugged in.
> >
> > Changes from v2:
> >  * Only apply to RTL8153-AD w/ eFuse pass through mac address pass thru
> >    bit set.
> >  * Drop matching DMI information on Dell.  Although this is implemented
> on
> >    Dell, this is a Realtek feature that may may be implemented on other
> >    OEMs as well.
> >  * Test that pass through MAC address is valid, fall back to HW address if
> >    invalid.
> >  * Don't track status of which device has MAC pass through activated.
> >  - Expected experience is that if two docks (RTL8153-AD's w/ mac pass thru
> >    bit set) were plugged in both should have MAC pass through activated.
> 
> cover letters for single-patch submissions is overkill and confusing,
> please don't.

I was trying to convey differences between versions of this patch, I'll avoid
that in the future and let the audience find them themselves.
