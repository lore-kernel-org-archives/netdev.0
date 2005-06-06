From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] tg3: Fix link failure in 5701
Date: Mon, 06 Jun 2005 15:16:41 -0700 (PDT)
Message-ID: <20050606.151641.95895557.davem@davemloft.net>
References: <1118086942.5008.14.camel@rh4>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: iod00d@hp.com, peterc@gelato.unsw.edu.au, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: mchan@broadcom.com
In-Reply-To: <1118086942.5008.14.camel@rh4>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Mon, 06 Jun 2005 12:42:22 -0700

> On some 5701 devices with older bootcode, the LED configuration bits in
> SRAM may be invalid with value zero. The fix is to check for invalid
> bits (0) and default to PHY 1 mode. Incorrect LED mode will lead to
> error in programming the PHY.
> 
> Thanks to Grant Grundler for debugging the problem.

Applied, thanks a log.
