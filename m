From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [ANNOUNCE] Experimental Driver for Neterion/S2io 10GbE Adapters
Date: Mon, 14 Mar 2005 12:38:15 -0800
Message-ID: <20050314123815.73e7ee78.davem@davemloft.net>
References: <1109005880.1076.77.camel@jzny.localdomain>
	<200503142023.j2EKNMDD027705@guinness.s2io.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, leonid@neterion.com, jgarzik@pobox.com
To: <alex@neterion.com>
In-Reply-To: <200503142023.j2EKNMDD027705@guinness.s2io.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 14 Mar 2005 12:22:51 -0800
"Alex Aizman" <alex@neterion.com> wrote:

> For these reviewers who consider this a minus, we hope you will find the HAL
> code in full compliance with Linux guidelines (in fact, it was written by
> our Linux team). Performance-wise, there was no negative impact discovered
> either. Testing-wise, this HAL has undergone numerous stress, functional,
> and performance tests "under" different drivers on a variety of platforms.

So you wrote a non-HAL version of this driver and compared the
results?  Simply comparing against the existins s2io driver
does not count.

If you're simply comparing against s2io, and your driver is faster
than s2io is already, imagine how much faster it might be without
that HAL layer.

I totally reject this driver, HAL is unacceptable for in-tree drivers.
We've been over this a thousand times.
