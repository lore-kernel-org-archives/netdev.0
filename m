From: "Carlos Velasco" <carlosev@newipnet.com>
Subject: Re: Bug? ARP with wrong src IP address
Date: Fri, 25 Jul 2003 20:36:05 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200307252036050292.052A4780@192.168.128.16>
References: <200307241728270476.0031BAB0@192.168.128.16>
 <Pine.LNX.4.44.0307241849341.2177-100000@l>
 <20030724091007.68923845.davem@redhat.com>
 <200307252024190066.051F80CE@192.168.128.16>
 <20030725114634.73dc9e8d.davem@redhat.com>
Content-Type: text/plain; charset="us-ascii"
Cc: ja@ssi.bg, bdschuym@pandora.be, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20030725114634.73dc9e8d.davem@redhat.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 25/07/2003 at 11:46 David S. Miller wrote:

>This is impossible, hidden is a subset of what arpfilter can do.
>
>arpfilter is a netfilter module that can block ARP packets
>at any point in the networking stack, at your choosing.

Maybe I'm looking in the wrong place.

I have tried with this setting in /proc:

===
arp_filter - BOOLEAN
        1 - Allows you to have multiple network interfaces on the same
        subnet, and have the ARPs for each interface be answered
        based on whether or not the kernel would route a packet from
        the ARP'd IP out that interface (therefore you must use source
        based routing for this to work). In other words it allows control
        of which cards (usually 1) will respond to an arp request.
===

Should I need any user space program to configure it or so?

Regards,
Carlos Velasco
