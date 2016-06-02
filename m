From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] r8152: Add support for setting MAC to system's Auxiliary
 MAC address
Date: Thu, 2 Jun 2016 17:01:18 +0200
Message-ID: <20160602150118.GB15379@lunn.ch>
References: <1464817844-27206-1-git-send-email-mario_limonciello@dell.com>
 <20160602074656.GM29844@pali>
 <1fdac44606c74fc09bcb95cd0c7f5f87@ausx13mpc124.AMER.DELL.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pali.rohar@gmail.com, hayeswang@realtek.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, anthony.wong@canonical.com
To: Mario_Limonciello@Dell.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1fdac44606c74fc09bcb95cd0c7f5f87@ausx13mpc124.AMER.DELL.COM>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > 
> > > +		pr_info("r8152: Using system auxiliary MAC address");
> > 
> > It would be great to write also mac address into that pr_info

And since there could be multiple r8152 in the system, it would be
good to indicate which of them is having its MAC changed. So
netdev_info() or dev_info().

      Andrew
