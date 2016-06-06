From: <Mario_Limonciello@Dell.com>
Subject: RE: [PATCH v3] r8152: Add support for setting pass through MAC
 address on RTL8153-AD
Date: Mon, 6 Jun 2016 14:57:06 +0000
Message-ID: <29950f6ff4a74058bbc5c756d1085cd4@ausx13mpc124.AMER.DELL.COM>
References: <1465222521-7217-1-git-send-email-mario_limonciello@dell.com>
 <1465222521-7217-2-git-send-email-mario_limonciello@dell.com>
 <20160606144036.GA30948@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <hayeswang@realtek.com>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, <linux-usb@vger.kernel.org>,
	<pali.rohar@gmail.com>, <anthony.wong@canonical.com>,
	<gregkh@linuxfoundation.org>
To: <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160606144036.GA30948@lunn.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Andrew Lunn [mailto:andrew@lunn.ch]
> Sent: Monday, June 6, 2016 9:41 AM
> To: Limonciello, Mario <Mario_Limonciello@Dell.com>
> Cc: hayeswang@realtek.com; LKML <linux-kernel@vger.kernel.org>; Netdev
> <netdev@vger.kernel.org>; Linux USB <linux-usb@vger.kernel.org>;
> pali.rohar@gmail.com; anthony.wong@canonical.com; Greg KH
> <gregkh@linuxfoundation.org>
> Subject: Re: [PATCH v3] r8152: Add support for setting pass through MAC
> address on RTL8153-AD
> 
> > +	/* returns _AUXMAC_#AABBCCDDEEFF# */
> > +	status = acpi_evaluate_object(NULL, "\\_SB.AMAC", NULL, &buffer);
> > +	obj = (union acpi_object *)buffer.pointer;
> > +	if (ACPI_SUCCESS(status)) {
> > +		if (obj->type != ACPI_TYPE_BUFFER ||
> > +		    obj->string.length != 0x17) {
> > +			pr_warn("r8152: get_passthru_addr: Invalid buffer");
> 
> Please don't use pr_warn() when you can use the better alternatives
> like dev_warn().
> 
>      Andrew

OK thanks, I'll adjust that to use a different warn.
