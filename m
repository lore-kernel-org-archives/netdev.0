From: "Randy.Dunlap" <rdunlap@xenotime.net>
Subject: Re: Runtime power management for network interfaces
Date: Sun, 30 Jul 2006 20:06:31 -0700
Message-ID: <20060730200631.836bdd23.rdunlap@xenotime.net>
References: <Pine.LNX.4.44L0.0607251147040.6498-100000@iolanthe.rowland.org>
	<44C644B6.20208@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: stern@rowland.harvard.edu, netdev@vger.kernel.org,
	david-b@pacbell.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenotime.net ([66.160.160.81]:49356 "HELO xenotime.net")
	by vger.kernel.org with SMTP id S932344AbWGaDDr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Jul 2006 23:03:47 -0400
Received: from midway.site ([71.117.253.75]) by xenotime.net for <netdev@vger.kernel.org>; Sun, 30 Jul 2006 20:03:47 -0700
To: Auke Kok <auke-jan.h.kok@intel.com>
In-Reply-To: <44C644B6.20208@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 25 Jul 2006 09:20:06 -0700 Auke Kok wrote:

> Alan Stern wrote:
> > During a Power Management session at the Ottawa Linux Symposium, it was
> > generally agreed that network interface drivers ought to automatically
> > suspend their devices (if possible) whenever:
> > 
> >     (1) The interface is ifconfig'ed down, or
> > 
> >     (2) No link is available.
> > 
> > Presumably (1) should be easy enough to implement.  (2) might or might not
> > be feasible, depending on how much WOL support is available.  (It might
> > not be feasible at all for wireless networking.)  Still, there can be no
> > question that it would be a Good Thing for laptops to power-down their
> > ethernet controllers when the network cable is unplugged.
> > 
> > Has any progress been made in this direction?  If not, a natural approach 
> > would be to start with a reference implementation in one driver which 
> > could then be copied to other drivers.
> 
> 
> Intel's newer e1000's (ich7 onboard e1000 and newer versions for instance) 
> already support this feature partially - the MAC stays on but the PHY can be 
> powered off when no link is present.
> 
> In order to enable this feature you will need to turn it on explicitly at load 
> time:
> 
> modprobe e1000 SmartPowerDownEnable=1

Please add that to Documentation/networking/e1000.txt.


> Allthough not the entire NIC is powered off, it still saves a significant part 
> of the power consumed by the NIC. All bits help. The power automatically 
> restores once a cable is plugged in.


---
~Randy
