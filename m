From: jamal <hadi@cyberus.ca>
Subject: Re: rtnetlink interface state monitoring problems.
Date: Tue, 22 Oct 2002 20:59:22 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0210222055170.24323-100000@shell.cyberus.ca>
References: <24818.1035226670@passion.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <linux-kernel@vger.kernel.org>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: David Woodhouse <dwmw2@infradead.org>
In-Reply-To: <24818.1035226670@passion.cambridge.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Mon, 21 Oct 2002, David Woodhouse wrote:

>
> hadi@cyberus.ca said:
> > I cant see anything on netlink and irda; i am also not very familiar
> > with either IrDA or Bluetooth. Regardless,  you dont need to be a net
> > device to use netlink.
>
> IrDA devices are network devices. The core network code sends a RTM_NETLINK
> message when they go up or down. All is well, and once the permission fix
> gets into the kernel I'm using, my irda monitor applet no longer needs to
> poll the state of the interface.
>

Ah, ok. I see what you mean - for a moment i thought IrDA was doing
something clever with netlink.

> But Bluetooth devices are not network devices, it seems. There exists no
> current mechanism for notifying anyone of state changes. Should we invent a
> new method of notification using netlink, or should Bluetooth interfaces in
> fact be normal network devices just like IrDA devices are?
>

I think the only time you should go netdev is when it makes sense to run
IP. Is there IP over bluttooth? Then you could take advantage of all the
nice features provided by netdevices (other than being IP devices;->).
If not, it probably time for someone to write a generic notification
scheme via netlink.

cheers,
jamal
