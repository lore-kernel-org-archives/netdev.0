From: Konstantin Shkolnyy <Konstantin.Shkolnyy@silabs.com>
Subject: RE: [EXT] [PATCH v4] r8152: Add support for setting pass through MAC
 address on RTL8153-AD
Date: Mon, 6 Jun 2016 17:42:52 +0000
Message-ID: <BLUPR0701MB157202FD9A92FF62F52382CF915C0@BLUPR0701MB1572.namprd07.prod.outlook.com>
References: <1465233569-13585-1-git-send-email-mario_limonciello@dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	Linux USB <linux-usb@vger.kernel.org>,
	"pali.rohar@gmail.com" <pali.rohar@gmail.com>,
	"anthony.wong@canonical.com" <anthony.wong@canonical.com>,
	Greg KH <gregkh@linuxfoundation.org>
To: Mario Limonciello <mario_limonciello@dell.com>,
	"hayeswang@realtek.com" <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1465233569-13585-1-git-send-email-mario_limonciello@dell.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: linux-usb-owner@vger.kernel.org [mailto:linux-usb-
> owner@vger.kernel.org] On Behalf Of Mario Limonciello
> Sent: Monday, June 06, 2016 12:19
> To: hayeswang@realtek.com
> Cc: LKML; Netdev; Linux USB; pali.rohar@gmail.com;
> anthony.wong@canonical.com; Greg KH; Mario Limonciello
> Subject: [EXT] [PATCH v4] r8152: Add support for setting pass through MAC
> address on RTL8153-AD
> 
> The RTL8153-AD supports a persistent system specific MAC address.
> This means a device plugged into two different systems with host side
> support will show different (but persistent) MAC addresses.
> 
> This information for the system's persistent MAC address is burned in when
> the system HW is built and available under _SB\AMAC in the DSDT at
> runtime.
> 
> This technology is currently implemented in the Dell TB15 and WD15 Type-C
> docks.  More information is available here:
> http://www.dell.com/support/article/us/en/04/SLN301147

What is going to happen if I connect multiple dongles? Will they all get the same address?
