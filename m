From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Convert ax25 to seq_file
Date: Wed, 13 Aug 2003 08:42:52 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030813084252.7b667fb8.davem@redhat.com>
References: <20030812194653.A28977@jeroen.pe1rxq.ampr.org>
	<20030812135655.7334887b.shemminger@osdl.org>
	<20030812230951.E28977@jeroen.pe1rxq.ampr.org>
	<20030812153901.6e700dcb.shemminger@osdl.org>
	<20030813010301.K28977@jeroen.pe1rxq.ampr.org>
	<20030812172151.7de0c950.shemminger@osdl.org>
	<20030813031159.6c6c9629.davem@redhat.com>
	<20030813173446.A2604@jeroen.pe1rxq.ampr.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, linux-hams@vger.kernel.org, ralf@linux-mips.org,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeroen Vreeken <pe1rxq@amsat.org>
In-Reply-To: <20030813173446.A2604@jeroen.pe1rxq.ampr.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 13 Aug 2003 17:34:46 +0200
Jeroen Vreeken <pe1rxq@amsat.org> wrote:

> This is my last patch (rxq4) plus Stephen's last three (dev locking,
> setsockopt, seq_file)

Please don't combine the patches, I want the each individual
patch with the author and his comments for that change.

If you combine all the work, this information gets lost.

Also, please use something more intelligent to generate these
diffs, so that I don't have to sift through all of the lines
like "Only in ...".

Thanks.

> p.s. Which protocol is a good example of non-linear skb usage? Most still
> seem to use skb_linearize() and the skb documentation is somewhat outdated.

What are you talking about?  There are only a handful of skb_linearize()
users in the current 2.6.x sources, and those will be eradicated
soon.

IPV4 is probably the best example.
