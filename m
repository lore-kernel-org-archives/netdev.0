From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netdev: generate kobject uevent on network state
 transitions
Date: Tue, 25 Nov 2008 01:09:43 -0800 (PST)
Message-ID: <20081125.010943.205685748.davem@davemloft.net>
References: <20081124150347.73050f98@extreme>
	<AAE2573A-3C23-4C61-89E1-3A6F31D7B23E@holtmann.org>
	<20081124201440.0e4d61cc@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: marcel@holtmann.org, bhutchings@solarflare.com,
	kay.sievers@vrfy.org, linux-hotplug@vger.kernel.org,
	netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <linux-hotplug-owner@vger.kernel.org>
In-Reply-To: <20081124201440.0e4d61cc@extreme>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 24 Nov 2008 20:14:40 -0800

> On Tue, 25 Nov 2008 04:51:53 +0100
> Marcel Holtmann <marcel@holtmann.org> wrote:
> 
> > > It is easier for some applications to deal with text based interfaces
> > > like uevent, rather than using netlink to listen for events.
> > >
> > > Note, this does not deal with network namespaces but that is a generic
> > > problem that already exists with kobjects (see rename events).
> > >
> > > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
 ...
> > do we wanna copy just what ifconfig shows or do we might be a more  
> > intelligent and have separate variables like RUNNING=1 etc.?
> 
> Was arbitrary choice to just use same flags as existing ifconfig.
> What ever feels best I guess...

So what do folks want me to do here?  Should I put Stephen's
latest patch in, or do we want to make some kind of flags change?
