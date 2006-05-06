From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH 2/2] netdev: create attribute_groups with class_device_add
Date: Sat, 6 May 2006 15:59:04 -0700
Message-ID: <20060506225904.GA17704@kroah.com>
References: <20060421125438.50f93a34@localhost.localdomain> <20060505.184158.131584956.davem@davemloft.net> <20060506040839.GA12636@kroah.com> <20060505.230050.56609951.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@osdl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.suse.de ([195.135.220.2]:63167 "EHLO mx1.suse.de")
	by vger.kernel.org with ESMTP id S932089AbWEFXAs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 May 2006 19:00:48 -0400
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060505.230050.56609951.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 05, 2006 at 11:00:50PM -0700, David S. Miller wrote:
> From: Greg KH <greg@kroah.com>
> Date: Fri, 5 May 2006 21:08:39 -0700
> 
> > On Fri, May 05, 2006 at 06:41:58PM -0700, David S. Miller wrote:
> > > From: Stephen Hemminger <shemminger@osdl.org>
> > > Date: Fri, 21 Apr 2006 12:54:38 -0700
> > > 
> > > > Atomically create attributes when class device is added. This avoids the
> > > > race between registering class_device (which generates hotplug event),
> > > > and the creation of attribute groups.
> > > > 
> > > > Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
> > > 
> > > Did the first patch that adds the attribute_group creation
> > > infrastructure go in so that we can get this networking fix in?
> > 
> > It and the netdev patch are setting in my tree which is showing up in
> > -mm.  I'm going to wait until 2.6.17 is out to send the first patch.  I
> > can send the second one then too if you want me to (probably make it
> > easier that way.)
> 
> The networking bit by Stephen is a bug fix.

Good point.  Ok, feel free to send both patches to Linus now if you
want.  You can add my:
	Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>
to the driver core change as I have no problems with it.
Or I can send them on Monday if you wish.  Whatever is easier for you.

thanks,

greg k-h
