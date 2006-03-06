From: Martin Michlmayr <tbm@cyrius.com>
Subject: Re: [PATCH, RESEND] Add MWI workaround for Tulip DC21143
Date: Mon, 6 Mar 2006 22:51:31 +0000
Message-ID: <20060306225131.GA23327@unjust.cyrius.com>
References: <20060129230816.GD4094@colonel-panic.org> <20060218220851.GA1601@colonel-panic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-mips-bounce@linux-mips.org>
Resent-Message-ID: <20060307034851.GB29936@unjust.cyrius.com>
To: netdev@vger.kernel.org, linux-mips@linux-mips.org
Content-Disposition: inline
In-Reply-To: <20060218220851.GA1601@colonel-panic.org>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

* Peter Horton <pdh@colonel-panic.org> [2006-02-18 22:08]:
> This patch works around the MWI bug on the DC21143 rev 65 Tulip by
> ensuring that the receive buffers don't end on a cache line boundary (as
> documented in the errata).
> 
> This patch is required for the MIPs based Cobalt Qube/RaQ as supporting
> the extra PCI commands seems to reduce the chance of a hard lockup
> between the Tulip and the PCI bridge.

Does anyone have comments regarding this patch?  I received
confirmation from a number of Debian users that this patch
significantly improves the lockup situation on Cobalt, so
it would be nice if it could go in.
-- 
Martin Michlmayr
tbm@cyrius.com
