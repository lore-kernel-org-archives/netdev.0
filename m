From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH]  Break 'budget' dependency on netdev_max_backlog.
Date: Tue, 22 Oct 2002 23:21:08 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0210222317210.24323-100000@shell.cyberus.ca>
References: <3DB60B4E.1090004@candelatech.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3DB60B4E.1090004@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Tue, 22 Oct 2002, Ben Greear wrote:

> Think we should add an IOCTL to change the weight of a device
> dynamically?  (I want my e1000 and tg3 to have higher weight than
> the tulip nics, I imagine)
>
> Is there a ready-built proc interface to do things to individual devices?
>

tulip hardcodes it; net/core/dev.c::weight_p is supposed to be the general
one and is proc settable via NET_CORE_DEV_WEIGHT; only problem is that
is not shadowed by the devices.
I am not sure if ioctls or module parameters are the best way to override
the default weight_p value. Somehow we need something to set this value.

cheers,
jamal
