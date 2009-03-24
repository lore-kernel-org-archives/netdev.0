From: Bill Nottingham <notting@redhat.com>
Subject: Re: Network Device Naming mechanism and policy
Date: Tue, 24 Mar 2009 14:12:03 -0400
Message-ID: <20090324181202.GE5925@nostromo.devel.redhat.com>
References: <20090324154617.GA16332@auslistsprd01.us.dell.com> <1237914139.22009.18.camel@quest> <20090324175203.GB22700@auslistsprd01.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Scott James Remnant <scott@ubuntu.com>, netdev@vger.kernel.org,
	linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org
To: Matt Domsch <Matt_Domsch@dell.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090324175203.GB22700@auslistsprd01.us.dell.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Matt Domsch (Matt_Domsch@dell.com) said: 
> > Now consider USB.  Would the device name change depending on which USB
> > port you plugged it into?  Or is USB just a single slot, in which case
> > what happens when you have two USB ethernet devices?
> > 
> > The Apple USB Ethernet device in my iPhone is not the USB Wireless
> > adapter I own, both have very different networking configurations.
> 
> we would obviously need a solution.  eth_usb_{something} perhaps.

Right, but having biosdevname chase each new bus that comes along
sounds iffy. I'd prefer /dev/net/by-name symlinks, if at all
possible. But that's a lot of code that I'm not prepared to write.

Bill
