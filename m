From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH 1/7] netpoll: shorten carrier detect timeout
Date: Sat, 5 Mar 2005 16:20:15 -0800
Message-ID: <20050306002015.GD3120@waste.org>
References: <2.454130102@selenic.com> <422A4A38.4040303@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com,
        Jeff Moyer <jmoyer@redhat.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <422A4A38.4040303@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Mar 06, 2005 at 01:09:28AM +0100, Patrick McHardy wrote:
> Matt Mackall wrote:
> >Shorten carrier detect timeout to 4 seconds.
> 
> The carrier detection looks partially broken to me. The current logic
> detects an instantly available carrier as flaky because
> netif_carrier_ok() takes less than 1/10s. This patch does what
> I assume is intended, make sure the carrier is stable for 1/10s.

Looks ok, but I've been meaning to change the second loop to something
like msleep(). 

Did you try this with a card that otherwise goes into the wait?

-- 
Mathematics is the supreme nostalgia of our time.
