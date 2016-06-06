From: <Mario_Limonciello@Dell.com>
Subject: RE: [EXT] [PATCH v4] r8152: Add support for setting pass through MAC
 address on RTL8153-AD
Date: Mon, 6 Jun 2016 17:48:56 +0000
Message-ID: <2260b0a15ba2427fa83dcf2a0c211b3f@ausx13mpc124.AMER.DELL.COM>
References: <1465233569-13585-1-git-send-email-mario_limonciello@dell.com>
 <BLUPR0701MB157202FD9A92FF62F52382CF915C0@BLUPR0701MB1572.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, <pali.rohar@gmail.com>,
	<anthony.wong@canonical.com>, <gregkh@linuxfoundation.org>
To: <Konstantin.Shkolnyy@silabs.com>, <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BLUPR0701MB157202FD9A92FF62F52382CF915C0@BLUPR0701MB1572.namprd07.prod.outlook.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Konstantin Shkolnyy [mailto:Konstantin.Shkolnyy@silabs.com]
> Sent: Monday, June 6, 2016 12:43 PM
> To: Limonciello, Mario <Mario_Limonciello@Dell.com>;
> hayeswang@realtek.com
> Cc: LKML <linux-kernel@vger.kernel.org>; Netdev
> <netdev@vger.kernel.org>; Linux USB <linux-usb@vger.kernel.org>;
> pali.rohar@gmail.com; anthony.wong@canonical.com; Greg KH
> <gregkh@linuxfoundation.org>
> Subject: RE: [EXT] [PATCH v4] r8152: Add support for setting pass through
> MAC address on RTL8153-AD
> 
> > -----Original Message-----
> > From: linux-usb-owner@vger.kernel.org [mailto:linux-usb-
> > owner@vger.kernel.org] On Behalf Of Mario Limonciello
> > Sent: Monday, June 06, 2016 12:19
> > To: hayeswang@realtek.com
> > Cc: LKML; Netdev; Linux USB; pali.rohar@gmail.com;
> > anthony.wong@canonical.com; Greg KH; Mario Limonciello
> > Subject: [EXT] [PATCH v4] r8152: Add support for setting pass through MAC
> > address on RTL8153-AD
> >
> > The RTL8153-AD supports a persistent system specific MAC address.
> > This means a device plugged into two different systems with host side
> > support will show different (but persistent) MAC addresses.
> >
> > This information for the system's persistent MAC address is burned in
> when
> > the system HW is built and available under _SB\AMAC in the DSDT at
> > runtime.
> >
> > This technology is currently implemented in the Dell TB15 and WD15 Type-C
> > docks.  More information is available here:
> > http://www.dell.com/support/article/us/en/04/SLN301147
> 
> What is going to happen if I connect multiple dongles? Will they all get the
> same address?

If you connect a dongle without a RTL8153-AD or without that bit they'll
get the MAC that was burned into the dongle.

If you connect multiple docks that have this Realtek chip with this bit set,
yes they'll all get the same address.
I confirmed that's what happens on Windows too.
