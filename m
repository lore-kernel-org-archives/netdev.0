From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [E1000-devel] Transmission limit
Date: Mon, 29 Nov 2004 16:19:40 +0100
Message-ID: <20041129151940.GA19184@xi.wantstofly.org>
References: <1101467291.24742.70.camel@mellia.lipar.polito.it> <41A73826.3000109@draigBrady.com> <20041127200030.GD27762@xi.wantstofly.org> <1101732267.14930.75.camel@verza.polito.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: e1000-devel@lists.sourceforge.net,
        Jorge Manuel Finochietto <jorge.finochietto@polito.it>,
        Giulio Galante <galante@polito.it>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Marco Mellia <mellia@prezzemolo.polito.it>
Content-Disposition: inline
In-Reply-To: <1101732267.14930.75.camel@verza.polito.it>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Nov 29, 2004 at 01:44:27PM +0100, Marco Mellia wrote:

> This "resets" the registers and writes in the TDFPC that there are 10
> pkts in the TX queue.
> Now when we do:
> 
> ping -c 1 x.x.x.x
> 
> You will see that the NIC will transmit 11 pkts (10 we "preloaded" + the
> new one).
> If you try to measure the TX speed you will see that it is ~ the wire
> speed.

How are you measuring this?


cheers,
Lennert
