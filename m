From: Matt Domsch <Matt_Domsch@Dell.com>
Subject: Re: [PATCH] Add firmware label support to iproute2
Date: Thu, 26 Aug 2010 11:38:55 -0500
Message-ID: <20100826163855.GA6774@auslistsprd01.us.dell.com>
References: <20100812173537.GA29784@auslistsprd01.us.dell.com> <20100812141240.417949e2@s6510> <EDA0A4495861324DA2618B4C45DCB3EE612E34@blrx3m08.blr.amer.dell.com> <20100818144124.33a72453@nehalam> <20100819213314.GA26135@auslistsprd01.us.dell.com> <20100819145308.0fa08522@nehalam> <20100825220323.GA12671@auslistsprd01.us.dell.com> <20100825171646.3d40b721@nehalam> <20100826150116.GB21770@auslistsprd01.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Narendra_K@Dell.com, netdev@vger.kernel.org, Charles_Rose@Dell.com,
	Jordan_Hargrave@Dell.com, linux-pci@vger.kernel.org,
	linux-hotplug@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100826150116.GB21770@auslistsprd01.us.dell.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 26, 2010 at 10:01:16AM -0500, Matt Domsch wrote:
> On Wed, Aug 25, 2010 at 05:16:46PM -0700, Stephen Hemminger wrote:
> > On Wed, 25 Aug 2010 17:03:23 -0500
> On Wed, Aug 25, 2010 at 05:16:46PM -0700, Stephen Hemminger wrote:
> > Is it really a good idea to have to change every utility that could
> > alter network devices?  There is iproute2, iputils, tcpdump, wireshark,
> > quagga, snmp, ...  Many of the utilities come from a BSD world,
> > and will be less likely to accept some Linux specific wart.
> 
> I agree, I don't want to have to change all those userspace apps
> either.  We've started creating patches and are willing to do so if it
> will yield the result we want though.
>  
> > I have lost faith in this library wrapper support everywhere method.
> > Let's just keep the firmware stuff in udev. If the user wants to
> > have a policy that renames device from eth0 to "Embedded BIOS LAN1" then
> > do it in udev. Or if you want to keep the ethX naming convention
> > and stuff the firmware label into ifAlias or other sysfs field
> > so it can be displayed that will be not a big issue.
> 
> 1) we remain constrained to IFNAMSIZ named arguments.  There is no
>    such constraint on BIOS-provided names.  Dell BIOS presently uses
>    'Embedded NIC 1' which (fortunately) is 14 chars. We're cutting it
>    awfully close already.  I can't dictate to non-Dell BIOS vendors
>    what to use as their strings, or how long to make them.

vlan usage requires 5 characters from IFNAMSIZ (eth0.4095).  So my
example with 'Embedded NIC 1' plus a vlan doesn't fit.

-- 
Matt Domsch
Technology Strategist
Dell | Office of the CTO
