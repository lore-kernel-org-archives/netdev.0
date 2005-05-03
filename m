From: Hasso Tepper <hasso@estpak.ee>
Subject: Re: icmp_unreachable uses wrong ip
Date: Tue, 3 May 2005 14:00:47 +0300
Message-ID: <200505031400.48287.hasso@estpak.ee>
References: <1115040079.5620.11.camel@jeroens.office.netland.nl> <Pine.LNX.4.61.0505031239460.3205@netcore.fi> <20050503103806.GB8864@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Pekka Savola <pekkas@netcore.fi>, netdev@oss.sgi.com,
        "J. Simonetti" <jeroens@office.netland.nl>
Return-path: <netdev-bounce@oss.sgi.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20050503103806.GB8864@xi.wantstofly.org>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Lennert Buytenhek wrote:
> The ones I've worked with in the past do, and I just did some
> simple tests (doing traceroute from a foreign IP in a different
> network and looking at the ICMP time-exceededs arriving at that
> foreign IP) to confirm that:
> - Juniper M5 and M20 both running JUNOS 7.0R2.7
> - Cisco 7206VXR and 12k(unsure which model) running unknown IOS versions

I haven't seen JUNOS or IOS versions behave differently.

> - Foundry FastIron 3 (the 15-slot chassis) running BIR06636.bin

I can add to it (probably all) Extreme Networks line. Tested with both 
software lines - Summit 24e3 and Inferno (Black Diamond 6808).

> do all behave opposite of the linux way, i.e. sending ICMPs with (one
> of) the source address(es) of the interface where the original packet
> (that we're sending an ICMP for) came in.


-- 
Hasso Tepper
Elion Enterprises Ltd.
WAN administrator
