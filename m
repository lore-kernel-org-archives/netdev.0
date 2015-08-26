From: Jeremy Linton <jeremy.linton@arm.com>
Subject: Re: [PATCH -next] smsc911x: Fix crash seen if neither ACPI nor OF is
 configured or used
Date: Wed, 26 Aug 2015 12:31:36 -0500
Message-ID: <55DDF7F8.2030304@arm.com>
References: <1439844336-21596-1-git-send-email-linux@roeck-us.net>
 <20150826170410.GP4215@atomide.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252; format=flowed
Content-Transfer-Encoding: 8BIT
Cc: Steve Glendinning <steve.glendinning@shawell.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>
To: Tony Lindgren <tony@atomide.com>,
	Guenter Roeck <linux@roeck-us.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150826170410.GP4215@atomide.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/26/2015 12:04 PM, Tony Lindgren wrote:
> * Guenter Roeck <linux@roeck-us.net> [150817 13:48]:
>> Commit 0b50dc4fc971 ("Convert smsc911x to use ACPI as well as DT") makes
> Looks like this change makes at least omap boards using smsc911x
> fail with -22 for me in Linux next.
>
> Do any of the the device tree configured smsc911x devices actually
> have a phy configured?

Tony,

	Looks like all the ones in the kernel boot/dts directory have a phy 
including the omap3-lilly except for the ste-snowball.dts.

	Do you have smsc,force-internal-phy set instead?

	Thanks,
		
