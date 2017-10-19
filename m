From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/ethernet/sgi: Code cleanup
Date: Thu, 19 Oct 2017 13:27:04 +0100 (WEST)
Message-ID: <20171019.132704.299365871401082792.davem@davemloft.net>
References: <53f0ad54-514a-b572-5801-7bd237055f86@gentoo.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ralf@linux-mips.org, linux-mips@linux-mips.org,
        netdev@vger.kernel.org, tglx@linutronix.de,
        linux-kernel@vger.kernel.org
To: kumba@gentoo.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <53f0ad54-514a-b572-5801-7bd237055f86@gentoo.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joshua Kinard <kumba@gentoo.org>
Date: Tue, 17 Oct 2017 13:54:30 -0400

> From: Joshua Kinard <kumba@gentoo.org>
> 
> The below patch attempts to clean up the code for the in-tree driver
> for IOC3 ethernet and serial console support, primarily used by SGI
> MIPS platforms.  Notable changes include:
> 
>   - Lots of whitespace cleanup
>   - Using shorthand integer types (u16, u32, etc) where appropriate

These seem to be arbitrary, "unsigned int" is a fine value for a
hash computation.

You're also making many different kinds of changes in one patch
which makes it very difficult to review.

This driver is also for such ancient hardware, that the risk
of potentially breaking the driver far outweighs the value of
"cleaning up" the code.
