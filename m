From: Henrik Nordstrom <hno@marasystems.com>
Subject: Re: primary and secondary ip addresses
Date: Thu, 16 Dec 2004 11:07:11 +0100 (CET)
Message-ID: <Pine.LNX.4.61.0412161103320.30452@filer.marasystems.com>
References: <41912F7A.6000408@redhat.com> <Pine.LNX.4.61.0411100034320.10593@filer.marasystems.com>
 <20041216092831.GO2862@sunbeam.de.gnumonks.org> <200412161153.51251.hasso@estpak.ee>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Harald Welte <laforge@gnumonks.org>, Neil Horman <nhorman@redhat.com>,
        linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Hasso Tepper <hasso@estpak.ee>
In-Reply-To: <200412161153.51251.hasso@estpak.ee>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 16 Dec 2004, Hasso Tepper wrote:

> And why I can't even choose which address is primary?

It is the first you add in a subnet.

> Primary
> =======
>
> Configure this address to be the primary address of the protocol on
> the interface. If the logical unit has more than one address, the
> primary address is used by default as the source address when packets
> originate from the interface and the destination does not indicate
> the subnet (ie. multicast destination for example).

This is what the primary addresses is used for, indirectly via the 
automatically created route entries.

> Preferred
> =========
>
> Configure this address to be the preferred address on the interface.
> If you configure more than one address on the same subnet, the
> preferred source address is chosen by default as the source address
> when you originate packets to destinations on the subnet.

What is the difference from primary here?

Broadcast traffic using the primary, the rest using preferred?

Regards
Henrik
