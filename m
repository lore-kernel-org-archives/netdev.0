From: <Mario_Limonciello@Dell.com>
Subject: RE: [PATCH] r8152: Add support for setting MAC to system's Auxiliary
 MAC address
Date: Thu, 2 Jun 2016 15:07:55 +0000
Message-ID: <6c1424a9271e46c881b321df0109cbd1@ausx13mpc124.AMER.DELL.COM>
References: <1464817844-27206-1-git-send-email-mario_limonciello@dell.com>
 <20160602074656.GM29844@pali>
 <1fdac44606c74fc09bcb95cd0c7f5f87@ausx13mpc124.AMER.DELL.COM>
 <20160602150118.GB15379@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <pali.rohar@gmail.com>, <hayeswang@realtek.com>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, <anthony.wong@canonical.com>
To: <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160602150118.GB15379@lunn.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Andrew Lunn [mailto:andrew@lunn.ch]
> Sent: Thursday, June 2, 2016 10:01 AM
> To: Limonciello, Mario <Mario_Limonciello@Dell.com>
> Cc: pali.rohar@gmail.com; hayeswang@realtek.com; linux-
> kernel@vger.kernel.org; netdev@vger.kernel.org; linux-
> usb@vger.kernel.org; anthony.wong@canonical.com
> Subject: Re: [PATCH] r8152: Add support for setting MAC to system's
> Auxiliary MAC address
> 
> > >
> > > > +		pr_info("r8152: Using system auxiliary MAC address");
> > >
> > > It would be great to write also mac address into that pr_info
> 
> And since there could be multiple r8152 in the system, it would be good to
> indicate which of them is having its MAC changed. So
> netdev_info() or dev_info().
> 
>       Andrew

Thanks, will do that in next submission too.
