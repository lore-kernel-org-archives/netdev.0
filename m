From: jamal <hadi@cyberus.ca>
Subject: Re: NAPI-ized tulip patch against 2.4.20-rc1
Date: Thu, 7 Nov 2002 08:24:41 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0211070823590.11358-100000@shell.cyberus.ca>
References: <3DCA1152.7040002@candelatech.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Donald Becker <becker@scyld.com>,
   "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3DCA1152.7040002@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Wed, 6 Nov 2002, Ben Greear wrote:

>
> Here's an update of the tulip-NAPI and skb-recycle patches.  I made some
> changes to get it to compile and work when the RECYCLE define in skbuff.h
> was not enabled.
>
> I also got some test runs in.  Nothing really conclusive.
>
> Test setup:  Phobos 4-port NIC in each P-IV 1.8Ghz machine 32/33 PCI bus.
> Kernel 2.4.20-rc1 + my patches.  NICs connected to each other over CX cables.
> Sending 4k 1514 byte packets per second, send + receive. (48Mbps or so)
> RX ring size is 1024 for all of these tests.  No significant errors reported
> by the driver.  I don't know where these dropped packets go..no counter
> seems to be catching them.
>
> I sent 1 million packets (or very close to that) on every interface (received
> the same, mostly)
>
> Without SKB-Recycle:
>    dropped 339 out of 1Million, repeated test twice, numbers very similar.
>    When packets do drop, they drop on all interfaces in bursts of 10-150, generally.
>    Latency was about .3ms
>
> With SKB-Recycle (300 pkt hot-list)
>    dropped 230, 500, and 180 in consecutive runs.  They also drop in bursts.
>    The middle run may be bad luck...don't know.
>    Latency was about .3ms
>    While typing, I ran a longer test.  Dropped about 1600 out of 4 million.
>

Trash the machines harder. Try using smaller packets;

cheers,
jamal
