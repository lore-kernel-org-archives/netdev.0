From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: via-rhine unable to send back-to-back packets?
Date: Wed, 1 Dec 2004 20:55:50 +0100
Message-ID: <20041201195550.GC14470@xi.wantstofly.org>
References: <20041129222700.GA22918@xi.wantstofly.org> <20041129172540.6b959858.davem@davemloft.net> <20041130064823.GA27872@xi.wantstofly.org> <41ACB0C3.5020408@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
Content-Disposition: inline
In-Reply-To: <41ACB0C3.5020408@candelatech.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Nov 30, 2004 at 09:41:23AM -0800, Ben Greear wrote:

> >Yeah, preamble (8 bytes), CRC (4 bytes), inter-packet gap (12 bytes).
> >
> >Perhaps the via-rhine simply can't send out packets back-to-back and
> >needs 14 byte times of inter-packet gap.  I couldn't find any stray +2
> >in the driver anywhere but I'm just checking.
> 
> Couldn't you just sniff the resulting traffic to see if it is too big?

Sorry, forgot to mention: I did check that, and the data portion of
the packet doesn't appear to be too big.


--L
