From: "David S. Miller" <davem@redhat.com>
Subject: Re: [2.4 PATCH] bugfix: ARP respond on all devices
Date: Sun, 17 Aug 2003 22:31:18 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030817223118.3cbc497c.davem@redhat.com>
References: <20030728213933.F81299@coredump.scriptkiddie.org>
	<200308171509570955.003E4FEC@192.168.128.16>
	<200308171516090038.0043F977@192.168.128.16>
	<1061127715.21885.35.camel@dhcp23.swansea.linux.org.uk>
	<200308171555280781.0067FB36@192.168.128.16>
	<1061134091.21886.40.camel@dhcp23.swansea.linux.org.uk>
	<200308171759540391.00AA8CAB@192.168.128.16>
	<1061137577.21885.50.camel@dhcp23.swansea.linux.org.uk>
	<200308171827130739.00C3905F@192.168.128.16>
	<1061141045.21885.74.camel@dhcp23.swansea.linux.org.uk>
	<20030817224849.GB734@alpha.home.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: alan@lxorguk.ukuu.org.uk, carlosev@newipnet.com, lamont@scriptkiddie.org,
   davidsen@tmr.com, bloemsaa@xs4all.nl, marcelo@conectiva.com.br,
   netdev@oss.sgi.com, linux-net@vger.kernel.org, layes@loran.com,
   torvalds@osdl.org, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Willy Tarreau <willy@w.ods.org>
In-Reply-To: <20030817224849.GB734@alpha.home.local>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 18 Aug 2003 00:48:49 +0200
Willy Tarreau <willy@w.ods.org> wrote:

> On Sun, Aug 17, 2003 at 06:24:06PM +0100, Alan Cox wrote:
>  
> > So stick the address on eth0 not on lo since its not a loopback but an eth0
> > address, then use arpfilter so you don't arp for the invalid magic shared IP
> > address, or NAT it, or it may work to do
> > 
> >          ip route add nexthop-addr src my-virtual-addr dev eth0 scope local onlink
> >          ip route add default src my-virtual-addr via nexthop-addr dev eth0 scope global
>  
> I have a case where this doesn't work

Replying again... Alan does mention in the paragraph you've quoted
to use arpfilter, which works for every case imaginable.

The facilities to solve these problems are there, people simply
don't want to use them.
