From: Scott Feldman <sfeldma@pobox.com>
Subject: Re: [PATCH 2.6] e100: remove reference to NAPI config option
Date: Mon, 31 Jan 2005 18:04:28 -0800
Message-ID: <1107223468.3366.21.camel@sfeldma-mobl.dsl-verizon.net>
References: <1107220952.3366.4.camel@sfeldma-mobl.dsl-verizon.net>
	 <20050201014358.GD15786@krispykreme.ozlabs.ibm.com>
Reply-To: sfeldma@pobox.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Anton Blanchard <anton@samba.org>
In-Reply-To: <20050201014358.GD15786@krispykreme.ozlabs.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2005-01-31 at 17:43, Anton Blanchard wrote:
> We have seen issues with NAPI on ppc64 on various cards in the past.
> Its possibly due to missing memory barriers; the interrupt and read of
> the interrupt status provide syncronization with DMA on the non NAPI
> case. Without this you need to be very careful to order reads (eg
> between reading the ring status and the packet data).

Anton, do you think this is the same issue Russel King is reporting
against ARM?

http://marc.theaimsgroup.com/?l=linux-netdev&m=110686676829392&w=2

What happens in the ppc64 case?  Do you have a fix for the ppc64 case?

-scott
