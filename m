From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2.6 NET] Device name changing via rtnetlink
Date: Fri, 10 Sep 2004 22:06:44 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040910200644.GJ20088@postel.suug.ch>
References: <20040910195003.GA13912@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jt@hpl.hp.com
Content-Disposition: inline
In-Reply-To: <20040910195003.GA13912@bougret.hpl.hp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Jean Tourrilhes <20040910195003.GA13912@bougret.hpl.hp.com> 2004-09-10 12:50
> Thomas Graf wrote :
> > 
> > Allows changing of device name via rtnetlink. Last bit needed to do full
> > link configuration via rtnetlink.
> > 
> > Signed-off-by: Thomas Graf <tgraf@suug.ch>
> 
> 	This does not work, because you don't return the new name to
> user space. If the new name is a pattern, such as "eth%d" or "wlan%d",
> you absolutely need to return the new instanciated device name to user
> space so that userspace doesn't loose track of the device.

The ifindex stays the same, therefore the user space application can
simply dump the link list and fetch the new interface name. It would
theoretically be possible to provide the new name via an ACK but
this would break the RFC.

> 				if (colon)
> 					*colon = ':';

I ignored the colon handling on purpose, this is better done
in user space. I can change this if required.
