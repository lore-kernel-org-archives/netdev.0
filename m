From: Ralf Baechle DL5RB <ralf@linux-mips.org>
Subject: Re: [PATCH] Get rid of sk_protinfo use in rose
Date: Mon, 21 Mar 2005 09:58:40 +0000
Message-ID: <20050321095840.GB10220@linux-mips.org>
References: <20050321095037.GA10220@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@oss.sgi.com, linux-hams@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20050321095037.GA10220@linux-mips.org>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 21, 2005 at 09:50:37AM +0000, Ralf Baechle DL5RB wrote:

> Below patch puts struct sock into rose_cb to get rid of the need for the
> use of sk_protinfo in rose_sk().  While we're touching the data structure
> convert it from a typedef into a struct.

The previous two patches leave the same thing to do in ax25 also - where
it's a more complicated thing to do since currently an ax25_cb may exist
without a struct sock - which unfortunately messes up locking.

  Ralf
