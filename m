From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v2] r8152: Add support for setting MAC to system's
 Auxiliary MAC address
Date: Thu, 2 Jun 2016 19:01:39 -0700
Message-ID: <20160603020139.GA3668@kroah.com>
References: <1464886687-16284-1-git-send-email-mario_limonciello@dell.com>
 <1464886687-16284-2-git-send-email-mario_limonciello@dell.com>
 <20160602174808.GA32131@kroah.com>
 <2d81e70165b8447d92b873eafeaeded7@ausx13mpc124.AMER.DELL.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hayeswang@realtek.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	pali.rohar@gmail.com, anthony.wong@canonical.com
To: Mario_Limonciello@Dell.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <2d81e70165b8447d92b873eafeaeded7@ausx13mpc124.AMER.DELL.COM>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 02, 2016 at 06:32:42PM +0000, Mario_Limonciello@Dell.com wrote:
> > And you want to check this for all Dell devices?  Please be model
> > specific, I doubt a bunch of Dell servers wants to run this code...
> > 
> 
> Tracking model specific is really going to turn into a giant list never ending list.
> To drill down more specifically, I can match on chassis too.

Yes, as this is a vendor/platform-specific "quirk", you will have to
update it for each and every individual device you want it enabled as it
is so different from what all other drivers do.

thanks,

greg k-h
