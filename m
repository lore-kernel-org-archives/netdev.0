From: jamal <hadi@cyberus.ca>
Subject: Re: Patch: Idea for RFC2863 conform OperStatus
Date: Sat, 12 Oct 2002 10:09:37 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0210121003000.23509-100000@shell.cyberus.ca>
References: <3DA82269.CBB65E89@isg.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Stefan Rompf <srompf@isg.de>
In-Reply-To: <3DA82269.CBB65E89@isg.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Sat, 12 Oct 2002, Stefan Rompf wrote:

> If we decide to go this way, we'll also need an extension to rtnetlink
> and a new ioctl to transport the information to userspace.

Before you go doing that:
IFF_RUNNING and IFF_UP are already part of the ifi_flags(struct ifinfomsg)
passed today.
How about making use of ifi_change to extend them? Alexey, would this be
proper use of ifi_change?

cheers,
jamal
