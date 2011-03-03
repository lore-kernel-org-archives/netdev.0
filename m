From: Nico =?iso-8859-1?Q?Sch=FCmann?= <dev@nico22.de>
Subject: Re: Network link detection
Date: Thu, 3 Mar 2011 23:29:57 +0100
Message-ID: <20110303222957.GA30472@svh.nico22.de>
References: <20110303193006.GA29129@svh.nico22.de>
 <4D700A5B.2000807@genband.com>
 <20110303.140106.191399853.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: chris.friesen@genband.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110303.140106.191399853.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 03, 2011 at 02:01:06PM -0800, David Miller wrote:
> From: Chris Friesen <chris.friesen@genband.com>
> Date: Thu, 03 Mar 2011 15:38:35 -0600
> 
> > You might look at whether you could write a kernel module to register
> > for NETDEV_CHANGE notifications and pass that back to userspace.
> 
> This is the kind of responses you get when you ask networking specific
> questions and don't CC: netdev :-/
> 

Thank you for CC.

> There is this thing called netlink, you can listen for arbitrary
> network state change events on a socket, and get the link state
> notifications you are looking for.  It's in use by many real
> applications like NetworkManager and co.

That really looks like what I'm looking for. I was already wondering 
where NetworkManager gets the link state changes from, but I just 
expected it to poll. So now I'll read a bit of documentation and 
hopefully get it work.

Thanks to everyone,

Nico
