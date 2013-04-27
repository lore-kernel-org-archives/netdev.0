From: Chris Wright <chrisw@sous-sol.org>
Subject: Re: [PATCH net] vxlan: use IANA assigned port
Date: Fri, 26 Apr 2013 18:51:29 -0700
Message-ID: <20130427015129.GJ8882@sequoia.sous-sol.org>
References: <20130426163346.762c41c1@nehalam.linuxnetplumber.net>
 <20130426.194405.764067901709113311.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	kduda@aristanetworks.com, chrisw@sous-sol.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sous-sol.org ([216.99.217.87]:46711 "EHLO sequoia.sous-sol.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751108Ab3D0COn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Apr 2013 22:14:43 -0400
Content-Disposition: inline
In-Reply-To: <20130426.194405.764067901709113311.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* David Miller (davem@davemloft.net) wrote:
> From: Stephen Hemminger <stephen@networkplumber.org>
> Date: Fri, 26 Apr 2013 16:33:46 -0700
> 
> > Ken Duda of Arista Networks, one of the VXLAN RFC authors notified
> > me that IANA has assigned an official port for VXLAN. My initial version
> > of the driver used the value from CISCO LISP that was also being used by
> > OpenVswitch.
> > 
> > Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
> 
> So how does this interact with already deployed VXLAN links?
> 
> What is the backwards compatability story?  What if one node upgrades
> with this patch installed, but all the other nodes are left using
> the older port number by default?

With this patch, I think one node upgrading would need to override
the default vxlan_port module param (falling back to the pre IANA
default) to keep active with the existing overlays.
