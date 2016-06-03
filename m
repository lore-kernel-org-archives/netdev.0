From: <Mario_Limonciello@Dell.com>
Subject: RE: [PATCH v2] r8152: Add support for setting MAC to system's
 Auxiliary MAC address
Date: Fri, 3 Jun 2016 15:10:32 +0000
Message-ID: <b6171d35838941e792d846802007ad88@ausx13mpc124.AMER.DELL.COM>
References: <1464886687-16284-1-git-send-email-mario_limonciello@dell.com>
 <1464886687-16284-2-git-send-email-mario_limonciello@dell.com>
 <20160602174808.GA32131@kroah.com>
 <2d81e70165b8447d92b873eafeaeded7@ausx13mpc124.AMER.DELL.COM>
 <20160603020139.GA3668@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <hayeswang@realtek.com>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, <linux-usb@vger.kernel.org>,
	<pali.rohar@gmail.com>, <anthony.wong@canonical.com>
To: <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160603020139.GA3668@kroah.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Greg KH [mailto:gregkh@linuxfoundation.org]
> Sent: Thursday, June 2, 2016 9:02 PM
> To: Limonciello, Mario <Mario_Limonciello@Dell.com>
> Cc: hayeswang@realtek.com; linux-kernel@vger.kernel.org;
> netdev@vger.kernel.org; linux-usb@vger.kernel.org; pali.rohar@gmail.com;
> anthony.wong@canonical.com
> Subject: Re: [PATCH v2] r8152: Add support for setting MAC to system's
> Auxiliary MAC address
> 
> On Thu, Jun 02, 2016 at 06:32:42PM +0000, Mario_Limonciello@Dell.com
> wrote:
> > > And you want to check this for all Dell devices?  Please be model
> > > specific, I doubt a bunch of Dell servers wants to run this code...
> > >
> >
> > Tracking model specific is really going to turn into a giant list never ending
> list.
> > To drill down more specifically, I can match on chassis too.
> 
> Yes, as this is a vendor/platform-specific "quirk", you will have to
> update it for each and every individual device you want it enabled as it
> is so different from what all other drivers do.
> 
> thanks,
> 
> greg k-h

After finding out that there is a characteristic specific to Realtek chip in this USB
device, I think it would be best to only run the \\_SB.AMAC lookup when this 
specific USB device is connected.  

Realtek is not maintaining a whitelist of systems in their driver for the other OS,
they approach it from the other end and only lookup auxiliary MAC if the right
device is plugged in.
