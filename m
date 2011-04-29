From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] bridge: Module use count must be updated as bridges are
 created/destroyed
Date: Fri, 29 Apr 2011 08:34:18 -0700
Message-ID: <20110429083418.1ce9415c@nehalam>
References: <4DBA830A020000780003ED5D@vpn.id2.novell.com>
	<20110429.002530.112581952.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: JBeulich@novell.com, bridge@lists.linux-foundation.org,
	jeffm@suse.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:43545 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754727Ab1D2Pez (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2011 11:34:55 -0400
In-Reply-To: <20110429.002530.112581952.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 29 Apr 2011 00:25:30 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: "Jan Beulich" <JBeulich@novell.com>
> Date: Fri, 29 Apr 2011 08:21:14 +0100
> 
> > Otherwise 'modprobe -r' on a module having a dependency on bridge will
> > implicitly unload bridge, bringing down all connectivity that was using
> > bridges.
> > 
> > Signed-off-by: Jan Beulich <jbeulich@novell.com>
> > Cc: Jeff Mahoney <jeffm@suse.com>
> 
> All network device drivers behave exactly the same way, when you rmmod
> the thing we unconfigure all the routes, addresses, etc. going through
> that device and let you unload it.
> 
> And this behavior is very much intentional.
> 
> Don't add an exception here.

Agreed.
