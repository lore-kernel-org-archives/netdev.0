From: jamal <hadi@cyberus.ca>
Subject: Re: Patch: Idea for RFC2863 conform OperStatus
Date: Sun, 13 Oct 2002 10:04:02 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0210130957150.25992-100000@shell.cyberus.ca>
References: <3DA96B9D.412FDAF3@isg.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Stefan Rompf <srompf@isg.de>
In-Reply-To: <3DA96B9D.412FDAF3@isg.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Stefan,

This is looking good; some small nitpicks:
-where do you set the netlink state change, ifi_change etc?
I know we are waiting for Alexey to respond but how do you propagate
iff_up -> down and the cause fatale to user space?
-Do you really have to malloc and free everytime for that lw_event?

Dave, Alexey,
It's your call now to dissect it's maintainability; i am happy with it
when Stefan addresses the above nitpicks.

On Sun, 13 Oct 2002, Stefan Rompf wrote:

> While doing tests with a hacked vlan driver that creates
> NETDEV_OPER_LOWERDOWN/_UP events I found that I get a "No buffer space
> available" in ip monitor if the event list is longer than about 20
> entries. This can be worked around with setsockopt on SO_RCVBUF, but
> does anyone have a clue why netlink events are that expensive?

Take a look at the way memory is allocated in that area and you'll see it.
May i suggest thats another fire that may need to be put out at some
point? ;-> <hint, hint, wink, wink>


cheers,
jamal
