From: jamal <hadi@cyberus.ca>
Subject: Re: bonding vs 802.3ad/Cisco EtherChannel link agregation
Date: Wed, 18 Sep 2002 07:48:42 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0209180745010.3686-100000@shell.cyberus.ca>
References: <3D87FBD5.3030508@candelatech.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Chris Friesen <cfriesen@nortelnetworks.com>,
   Cacophonix <cacophonix@yahoo.com>, <linux-net@vger.kernel.org>,
   <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3D87FBD5.3030508@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Tue, 17 Sep 2002, Ben Greear wrote:

> I see reordering on regular old socket calls from user space, and I see
> the same thing with pktgen packets as well (which clears the stack of fault).
>
> > Did you get reordering with affinity?
>
> Yes.  I'm not sure I tried affinity w/out NAPI though.  I definately tried
> it with NAPI and saw reordering.
>

Ok, now it is getting interesting. I would start to be suspicious
about either the hardware or driver.
Please try without NAPI and affinity and post what you see (not that this
result matters but should help confirn things).

cheers,
jamal
