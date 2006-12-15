From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [Bridge] Bridge & it's MAC address question
Date: Fri, 15 Dec 2006 07:52:36 -0800
Message-ID: <20061215075236.321e6a07@localhost.localdomain>
References: <200610301527.15018.dim@openvz.org>
	<20061030072837.51177183@localhost.localdomain>
	<20061215131908.GC11579@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Dmitry Mishin <dim@openvz.org>, netdev@vger.kernel.org,
	bridge@osdl.org, devel@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:47775 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752762AbWLOPwm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Dec 2006 10:52:42 -0500
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20061215131908.GC11579@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 15 Dec 2006 14:19:08 +0100
Lennert Buytenhek <buytenh@wantstofly.org> wrote:

> On Mon, Oct 30, 2006 at 07:28:37AM -0800, Stephen Hemminger wrote:
> 
> > > Could somebody explain, why bridge uses minimal MAC of the attached devices?
> > > It makes this address instable, variable during bridge life-cycle, which is 
> > > not good for DHCP. For example, I want to attach multiple virtual devices to 
> > > one physical. Then, I need to make sure that after each virtual device 
> > > addition, bridge addr is not changed and still addr of the physical device.  
> > > Why not to use MAC of the first attached device?
> > 
> > The bridge physical address is the minimum of all the attached devices.
> > This is done because the STP standard requires it.  You can reset it
> > to be the same as any of the attached devices. This will not cause a
> > problem unless using STP.
> 
> You can in fact use any MAC address.  The STP standard recommends using
> the minimum address, as that is deterministic, and so it doesn't depend
> on the order in which you enslave subdevices.

So should restriction be lifted?
Please update wiki page FAQ, or I'll do it
