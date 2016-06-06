From: <Mario_Limonciello@Dell.com>
Subject: RE: [PATCH v3] r8152: Add support for setting pass through MAC
 address on RTL8153-AD
Date: Mon, 6 Jun 2016 17:24:57 +0000
Message-ID: <e1fd0ce1589743acbd1342ec38ff8071@ausx13mpc124.AMER.DELL.COM>
References: <1465222521-7217-1-git-send-email-mario_limonciello@dell.com>
 <1465222521-7217-2-git-send-email-mario_limonciello@dell.com>
 <20160606143947.GA4758@kroah.com>
 <e0b44bac635f41a9a3f47f909cf16f42@ausx13mpc124.AMER.DELL.COM>
 <20160606161222.GA12114@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <hayeswang@realtek.com>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, <linux-usb@vger.kernel.org>,
	<pali.rohar@gmail.com>, <anthony.wong@canonical.com>
To: <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160606161222.GA12114@kroah.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > Realtek has this in their Windows driver that all OEM's will be taking.
> > Another OEM would just need to burn the right information into the SPI at
> > manufacturing and expose it to the DSDT.
> 
> Where it the match up for the Realtek bit to corrispond with this
> specific ACPI field?  If it's not in the ACPI spec, then vendors _WILL_
> do this in different ways.
> 
> Again, document it, in the code, what is going on here, that's all I'm
> asking.  I'm not asking you to change the logic at all!

I've added additional comments for v4.  I strongly believe that even if
another vendor does do this differently for their implementation of
\\_SB.AMAC this code will be safe to run.

All of the output from the field are tested for exactly what the field
should look like.

That said, I would be highly surprised if Realtek decided to implement
with another OEM differently.  It would increase their code complexity
on Windows as well since this is part of the generic driver.
