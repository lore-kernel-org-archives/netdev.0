From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v3] net: smc91: fix crash regression on the versatile
Date: Thu, 28 Nov 2013 17:24:42 +0000
Message-ID: <20131128172442.GC16203@mudshark.cambridge.arm.com>
References: <1385645632-3577-1-git-send-email-linus.walleij@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Nicolas Pitre <nico@fluxnic.net>,
	"David S. Miller" <davem@davemloft.net>,
	Russell King <linux@arm.linux.org.uk>,
	Eric Miao <eric.y.miao@gmail.com>,
	Jonathan Cameron <jic23@cam.ac.uk>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>
To: Linus Walleij <linus.walleij@linaro.org>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1385645632-3577-1-git-send-email-linus.walleij@linaro.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 28, 2013 at 01:33:52PM +0000, Linus Walleij wrote:
> After commit e9e4ea74f06635f2ffc1dffe5ef40c854faa0a90
> "net: smc91x: dont't use SMC_outw for fixing up halfword-aligned data"
> The Versatile SMSC LAN91C111 is crashing like this:

[...]

> ---
> ChangeLog v2->v3:
> - Fold in a hunk from Will Deacon's patch addressing the same
>   issue.
> ChangeLog v1->v2:
> - Correct commit message to nail the actual commit causing
>   the bug, as pointed out by Russell.
> ---
>  drivers/net/ethernet/smsc/smc91x.h | 22 ++++------------------
>  1 file changed, 4 insertions(+), 18 deletions(-)

  Acked-by: Will Deacon <will.deacon@arm.com>

Cheers for sorting that out, Linus.

Will
