From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: [[RFT] convert appletalk over to new protocol
Date: Thu, 10 Jul 2003 03:20:11 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030710062010.GC11670@conectiva.com.br>
References: <20030709131300.660c052f.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, Jay Schulist <jschlst@samba.org>,
   netdev@oss.sgi.com, linux-atalk@lists.netspace.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20030709131300.660c052f.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Em Wed, Jul 09, 2003 at 01:13:00PM -0700, Stephen Hemminger escreveu:
> This fixes appletalk ddp protocol to address a couple of issues:
> 	- routing code was holding a reference to device without doing ref counting.
> 	- packet interface was old style
> 	   - add shared buffer checks
> 	   - add pullup's where needed
> 	   - change checksum to handle fragmented sk_buff's
> 	- clean up comments to match above changes.
> 
> I don't have real appletalk test infrastructure, and given the checksum change it should
> be tested against real Apple hardware.  It does build, and loads/unloads fine.  I can
> bring up the netatalk stuff without problem but have nothing to talk to it.

I'll take a look, but I missed the sock_hold/put stuff from a first look, it
is OK by now when adding and removing from a lista of socks due to the hlist
conversion work, but needs to be done in routines that search a list of socks
and return a sock.

I do have a good Appletalk test bed, with m68k and ppc macs, but I'll only will
be able to test this next wednesday, as I'll be on a business trip starting
tomorrow.

Good work as far as I quickly glanced, will review it further and provide
comments, probably in the next days.

- Arnaldo
