From: "David S. Miller" <davem@redhat.com>
Subject: Re: [2.4 PATCH] bugfix: ARP respond on all devices
Date: Mon, 18 Aug 2003 05:53:29 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030818055329.44db9262.davem@redhat.com>
References: <200308171555280781.0067FB36@192.168.128.16>
	<1061134091.21886.40.camel@dhcp23.swansea.linux.org.uk>
	<200308171759540391.00AA8CAB@192.168.128.16>
	<1061137577.21885.50.camel@dhcp23.swansea.linux.org.uk>
	<200308171827130739.00C3905F@192.168.128.16>
	<1061141045.21885.74.camel@dhcp23.swansea.linux.org.uk>
	<20030817224849.GB734@alpha.home.local>
	<20030817223118.3cbc497c.davem@redhat.com>
	<20030818133957.3d3d51d2.skraw@ithnet.com>
	<20030818044419.0bc24d14.davem@redhat.com>
	<20030818125158.GA18699@alpha.home.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: skraw@ithnet.com, willy@w.ods.org, alan@lxorguk.ukuu.org.uk,
   carlosev@newipnet.com, lamont@scriptkiddie.org, davidsen@tmr.com,
   bloemsaa@xs4all.nl, marcelo@conectiva.com.br, netdev@oss.sgi.com,
   linux-net@vger.kernel.org, layes@loran.com, torvalds@osdl.org,
   linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Willy Tarreau <willy@w.ods.org>
In-Reply-To: <20030818125158.GA18699@alpha.home.local>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 18 Aug 2003 14:51:58 +0200
Willy Tarreau <willy@w.ods.org> wrote:

> > 1) consider how you might want to make that configurable
> >    by the user
> 
> ip route ... src ... is really fine to me for the IP part, and I would have
> expected it to act on ARP too ;-)

More precisely, "preferred source".

> > 2) what the default behavior should be
> 
> I think we should apply the exact same source selection as IP to ARP.

This is what setting the "arp_filter" sysctl on a device does
if you've setup the preferred source on your routes correctly.
If we would use that IP address to speak to the destination in
the ARP, we respond, else we do not.

I've quoted the 'arp_filter' entry in Documentation/sysctl/ip-sysctl.txt
please give it a read.
