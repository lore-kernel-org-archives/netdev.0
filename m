From: jamal <hadi@cyberus.ca>
Subject: Re: rtnetlink interface state monitoring problems.
Date: Mon, 28 Oct 2002 07:35:01 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0210280711490.9849-100000@shell.cyberus.ca>
References: <5.1.0.14.2.20021023124123.09b83e00@mail1.qualcomm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Tim Hockin <thockin@hockin.org>, David Woodhouse <dwmw2@infradead.org>,
   <linux-kernel@vger.kernel.org>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Maksim (Max) Krasnyanskiy" <maxk@qualcomm.com>
In-Reply-To: <5.1.0.14.2.20021023124123.09b83e00@mail1.qualcomm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Wed, 23 Oct 2002, Maksim (Max) Krasnyanskiy wrote:

>
> >netlink is a messaging system; so what i am thinking is creating
> >a event notifier for other devices other than network devices.
> >Something other non-network devices could use (eg bluetooth).
>
> What kind of events are we taking about ?
>

Currently,  for net events, notifier_call_chain() calls from the same
routines which also send netlink announcements. I am thinking actually
having notifier_call_chain make the netlink advertisements.
There are not that many subsystems that use notifier block calls (seems
the network subsytem is their best customer ;->)
i think it is the best async notification scheme in the kernel. Too bad
someone had to invent hotplug the way it is right now.
As i said earlier, the advantage with netlink is that you could easily
add a distributed event notification scheme since it is already in packet
format.

cheers,
jamal
