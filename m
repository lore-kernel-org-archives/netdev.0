From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2.6 NET] Device name changing via rtnetlink
Date: 10 Sep 2004 22:01:10 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1094868070.1042.77.camel@jzny.localdomain>
References: <20040910195003.GA13912@bougret.hpl.hp.com>
	 <20040910200644.GJ20088@postel.suug.ch>
	 <20040910201302.GA16556@bougret.hpl.hp.com>
	 <20040910202235.GK20088@postel.suug.ch>
	 <20040910203203.GA17078@bougret.hpl.hp.com>
	 <20040910204348.GL20088@postel.suug.ch>
	 <1094857082.1041.19.camel@jzny.localdomain>
	 <20040910231726.GP20088@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jt@hpl.hp.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20040910231726.GP20088@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2004-09-10 at 19:17, Thomas Graf wrote:

> There is one remaining problem, currently, changes via rtnetlink will
> result in multiple notifies being sent out because NETDEV_CHANGEMTU
> and NETDEV_CHANGENAME are invoked as well and result in a netlink
> message. Changing them to not do anything in rtnetlink context
> would solve it but we would lose the notify if the change was made
> via ioctl.
> 

notify via ioctls is still needed.
Are you changing MTU and NAME at the same time?
Valid to receive the two updates i would think in that case.

cheers,
jamal
