From: jamal <hadi@cyberus.ca>
Subject: Re: VLAN patches
Date: Mon, 7 Oct 2002 08:05:07 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0210070757520.1861-100000@shell.cyberus.ca>
References: <3DA13332.4080109@mrv.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ben Greear <greearb@candelatech.com>, "David S. Miller" <davem@redhat.com>,
   <Bjorn.Andersson@ebc.ericsson.se>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Eran Mann <emann@mrv.com>
In-Reply-To: <3DA13332.4080109@mrv.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Mon, 7 Oct 2002, Eran Mann wrote:

> Regarding the 0 VID it is indeed used for priority-only frames.
> Shouldn't it be supported by alowing the user to configure a priority
> map for the ethernet device (rather than creating another user-visible
> device?
>

That or you complain and drop the packet when someone sends; btw
also VLANid > 0 and p tag 0 is legal - i guess that is the default
for linux.
On a side not:
I never liked Bens patches that much compared to the other VLAN
imp. -- would have prefered a marriage of the two.

cheers,
jamal
