From: jamal <hadi@cyberus.ca>
Subject: Re: PATCH Re: udp weirdness
Date: Tue, 1 Oct 2002 14:35:39 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0210011433300.18461-100000@shell.cyberus.ca>
References: <3D99EB40.8030006@nortelnetworks.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ben Greear <greearb@candelatech.com>, <kuznet@ms2.inr.ac.ru>,
   <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Chris Friesen <cfriesen@nortelnetworks.com>
In-Reply-To: <3D99EB40.8030006@nortelnetworks.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Tue, 1 Oct 2002, Chris Friesen wrote:

> to be silently dropped by the kernel because userspace is sending faster
> than they can get onto the wire during that tight loop.
>

So what happens when you find packets being dropped?
AFAIK, a dropped voice packet is as good as dead whether local or remote.

> Okay, so with IP_RECVERR set the case that Eric saw will not happen?  I
> mean that sendto() will return with -1 and errno set to ENOBUFS?

yes

cheers,
jamal
