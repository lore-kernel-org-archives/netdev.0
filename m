From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Runtime power management for network interfaces
Date: Mon, 31 Jul 2006 09:17:28 -0700
Message-ID: <20060731091728.4d992cf1@dxpl.pdx.osdl.net>
References: <Pine.LNX.4.44L0.0607251147040.6498-100000@iolanthe.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Network development list <netdev@vger.kernel.org>,
	David Brownell <david-b@pacbell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:44426 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1030215AbWGaQRe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2006 12:17:34 -0400
To: Alan Stern <stern@rowland.harvard.edu>
In-Reply-To: <Pine.LNX.4.44L0.0607251147040.6498-100000@iolanthe.rowland.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 25 Jul 2006 11:59:52 -0400 (EDT)
Alan Stern <stern@rowland.harvard.edu> wrote:

> During a Power Management session at the Ottawa Linux Symposium, it was
> generally agreed that network interface drivers ought to automatically
> suspend their devices (if possible) whenever:
> 
>     (1) The interface is ifconfig'ed down, or
> 
>     (2) No link is available.

This is hard because most of the power may be consumed by the PHY interface
and it needs to be alive to see link.

> 
> Presumably (1) should be easy enough to implement.  (2) might or might not
> be feasible, depending on how much WOL support is available.  (It might
> not be feasible at all for wireless networking.)  Still, there can be no
> question that it would be a Good Thing for laptops to power-down their
> ethernet controllers when the network cable is unplugged.
> 
> Has any progress been made in this direction?  If not, a natural approach 
> would be to start with a reference implementation in one driver which 
> could then be copied to other drivers.
> 

The problem is not generic, it really is specific to each device.
We have all the necessary infrastructure to do the right thing in the network
device driver, but in many cases we don't have the code or the technical information
to do proper power management.

-- 
Stephen Hemminger <shemminger@osdl.org>
"And in the Packet there writ down that doome"
