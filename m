From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] ax25 & netrom fixes for 2.6
Date: Wed, 13 Aug 2003 03:10:38 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030813031038.2c2afc6d.davem@redhat.com>
References: <20030812194653.A28977@jeroen.pe1rxq.ampr.org>
	<20030812135655.7334887b.shemminger@osdl.org>
	<20030812230951.E28977@jeroen.pe1rxq.ampr.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, pe1rxq@amsat.org, linux-hams@vger.kernel.org,
   ralf@linux-mips.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeroen Vreeken <pe1rxq@amsat.org>
In-Reply-To: <20030812230951.E28977@jeroen.pe1rxq.ampr.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 12 Aug 2003 23:09:51 +0200
Jeroen Vreeken <pe1rxq@amsat.org> wrote:

> Since at the moment the only zero-copy path I can imagine is from packets
> over a bpq ethernet device wouldn't it be the easiest to just check at
> ax25_rcv() for non-linear packets and call skb_linearize() for them?

skb_linearize() is a deprecated interface, no new pieces of
code should use it.  If you want to mark the protocol as a new
one you must do the non-linear handling properly just like every
other protocol.

Please, if you're going to be working in this area, fix this up properly
and don't paper around the problems Stephen is showing to you.
