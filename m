From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2/2] netdev: create attribute_groups with
 class_device_add
Date: Fri, 05 May 2006 23:00:50 -0700 (PDT)
Message-ID: <20060505.230050.56609951.davem@davemloft.net>
References: <20060421125438.50f93a34@localhost.localdomain>
	<20060505.184158.131584956.davem@davemloft.net>
	<20060506040839.GA12636@kroah.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:44191
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750857AbWEFGA5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 May 2006 02:00:57 -0400
To: greg@kroah.com
In-Reply-To: <20060506040839.GA12636@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Greg KH <greg@kroah.com>
Date: Fri, 5 May 2006 21:08:39 -0700

> On Fri, May 05, 2006 at 06:41:58PM -0700, David S. Miller wrote:
> > From: Stephen Hemminger <shemminger@osdl.org>
> > Date: Fri, 21 Apr 2006 12:54:38 -0700
> > 
> > > Atomically create attributes when class device is added. This avoids the
> > > race between registering class_device (which generates hotplug event),
> > > and the creation of attribute groups.
> > > 
> > > Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
> > 
> > Did the first patch that adds the attribute_group creation
> > infrastructure go in so that we can get this networking fix in?
> 
> It and the netdev patch are setting in my tree which is showing up in
> -mm.  I'm going to wait until 2.6.17 is out to send the first patch.  I
> can send the second one then too if you want me to (probably make it
> easier that way.)

The networking bit by Stephen is a bug fix.
