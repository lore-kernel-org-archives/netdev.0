From: Andi Kleen <ak@suse.de>
Subject: Re: how to report network device errors to userspace?
Date: Wed, 19 Jun 2002 23:54:06 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020619235406.A11706@wotan.suse.de>
References: <Pine.LNX.4.33.0206191616060.1669-100000@presario> <3D10F552.C05ADD53@nortelnetworks.com> <20020619233659.A7368@wotan.suse.de> <3D10FB25.667421CB@nortelnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@suse.de>, Donald Becker <becker@scyld.com>,
   netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: Chris Friesen <cfriesen@nortelnetworks.com>
Content-Disposition: inline
In-Reply-To: <3D10FB25.667421CB@nortelnetworks.com>
List-Id: netdev.vger.kernel.org

On Wed, Jun 19, 2002 at 05:44:05PM -0400, Chris Friesen wrote:
> Andi Kleen wrote:
> 
> > I would suggest sending a netlink message from the driver.  That's really
> > what netlink was designed for.
> 
> Can you point me to a driver that's done this cleanly as an example to follow?

Not exactly a driver, but you can e.g. look at the ip_queue netfilter 
module.

-Andi
