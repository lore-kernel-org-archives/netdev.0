From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: rtnetlink interface state monitoring problems.
Date: Mon, 21 Oct 2002 19:57:50 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <24818.1035226670@passion.cambridge.redhat.com>
References: <Pine.GSO.4.30.0210210852130.17911-100000@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <Pine.GSO.4.30.0210210852130.17911-100000@shell.cyberus.ca> 
To: jamal <hadi@cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


hadi@cyberus.ca said:
> I cant see anything on netlink and irda; i am also not very familiar
> with either IrDA or Bluetooth. Regardless,  you dont need to be a net
> device to use netlink. 

IrDA devices are network devices. The core network code sends a RTM_NETLINK 
message when they go up or down. All is well, and once the permission fix 
gets into the kernel I'm using, my irda monitor applet no longer needs to 
poll the state of the interface.

But Bluetooth devices are not network devices, it seems. There exists no 
current mechanism for notifying anyone of state changes. Should we invent a 
new method of notification using netlink, or should Bluetooth interfaces in 
fact be normal network devices just like IrDA devices are?

--
dwmw2
