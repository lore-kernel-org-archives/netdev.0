From: jamal <hadi@cyberus.ca>
Subject: Re: rtnetlink interface state monitoring problems.
Date: Tue, 22 Oct 2002 23:17:13 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0210222313050.24323-100000@shell.cyberus.ca>
References: <200210230144.g9N1iDx11822@www.hockin.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Woodhouse <dwmw2@infradead.org>, <linux-kernel@vger.kernel.org>,
   <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Tim Hockin <thockin@hockin.org>
In-Reply-To: <200210230144.g9N1iDx11822@www.hockin.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Tue, 22 Oct 2002, Tim Hockin wrote:

> > If not, it probably time for someone to write a generic notification
> > scheme via netlink.
>
> How generic?  I need to pay some attention to cleaning up the next version
> of the link-changes via netlink patch that was discussed last week or the
> week before.

The patch posted by Stefan seems good to me and ready to merge.

>
> What kind of generic are you thinking about? :)
>

netlink is a messaging system; so what i am thinking is creating
a event notifier for other devices other than network devices.
Something other non-network devices could use (eg bluetooth).
Given that netlink packetizes the data, this facilitates a distributed
control type of environment.

cheers,
jamal
