From: "David S. Miller" <davem@davemloft.net>
Subject: Re: on the wire behaviour of TSO on/off is supposed to be the same
 yes?
Date: Mon, 24 Jan 2005 12:43:53 -0800
Message-ID: <20050124124353.2f760e1a.davem@davemloft.net>
References: <41F1516D.5010101@hp.com>
	<200501211358.53783.jdmason@us.ibm.com>
	<41F163AD.5070400@hp.com>
	<20050121124441.76cbbfb9.davem@davemloft.net>
	<41F17B7E.2020002@hp.com>
	<20050121141820.7d59a2d1.davem@davemloft.net>
	<41F186A8.9030805@hp.com>
	<20050121204948.034b2510.davem@davemloft.net>
	<41F55B93.6040603@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Rick Jones <rick.jones2@hp.com>
In-Reply-To: <41F55B93.6040603@hp.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 24 Jan 2005 12:33:23 -0800
Rick Jones <rick.jones2@hp.com> wrote:

> It would seem that the segmentation code, if it knew ssthresh as well as cwnd 
> _could_ make some reasonably optimistic guesses as to cwnd growth while doing 
> its segmentation.

Becuase we disable TSO on any packet loss whatsoever, we can predict
exactly what the CWND will be at the time a packet is sent.

I've been quiet the past few days, but this is the kind of implementation
I've been thinking of.

When we take away that invariant, which we do want to do, we'll need
to tweak how this works.
