From: Tony Lindgren <tony@atomide.com>
Subject: Re: [PATCH -next] smsc911x: Fix crash seen if neither ACPI nor OF is
 configured or used
Date: Wed, 26 Aug 2015 10:48:36 -0700
Message-ID: <20150826174835.GQ4215@atomide.com>
References: <1439844336-21596-1-git-send-email-linux@roeck-us.net>
 <20150826170410.GP4215@atomide.com>
 <55DDF7F8.2030304@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Guenter Roeck <linux@roeck-us.net>,
	Steve Glendinning <steve.glendinning@shawell.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>
To: Jeremy Linton <jeremy.linton@arm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <55DDF7F8.2030304@arm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Jeremy Linton <jeremy.linton@arm.com> [150826 10:35]:
> On 08/26/2015 12:04 PM, Tony Lindgren wrote:
> >* Guenter Roeck <linux@roeck-us.net> [150817 13:48]:
> >>Commit 0b50dc4fc971 ("Convert smsc911x to use ACPI as well as DT") makes
> >Looks like this change makes at least omap boards using smsc911x
> >fail with -22 for me in Linux next.
> >
> >Do any of the the device tree configured smsc911x devices actually
> >have a phy configured?
> 
> Tony,
> 
> 	Looks like all the ones in the kernel boot/dts directory have a phy
> including the omap3-lilly except for the ste-snowball.dts.
> 
> 	Do you have smsc,force-internal-phy set instead?

Hmm most of them are using omap-gpmc-smsc911x.dtsi and
omap-gpmc-smsc9221.dtsi which are set up the same way as
omap3-lilly. So no phy.

Regards,

Tony
