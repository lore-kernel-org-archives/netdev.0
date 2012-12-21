From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 4/5] net: sfc: fix return value check in
 efx_ptp_probe_channel().
Date: Fri, 21 Dec 2012 03:09:45 +0000
Message-ID: <1356059385.7055.11.camel@deadeye.wl.decadent.org.uk>
References: <1355271894-5284-1-git-send-email-tipecaml@gmail.com>
	 <1355271894-5284-5-git-send-email-tipecaml@gmail.com>
	 <20121212.001550.741463250196231082.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <kernel-janitors@vger.kernel.org>,
	<linux-net-drivers@solarflare.com>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>, <tipecaml@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121212.001550.741463250196231082.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-12-12 at 00:15 -0500, David Miller wrote:
> From: Cyril Roelandt <tipecaml@gmail.com>
> Date: Wed, 12 Dec 2012 01:24:53 +0100
> 
> > The ptp_clock_register() returns ERR_PTR() and never returns NULL. Replace the
> > NULL check by a call to IS_ERR().
> > 
> > Signed-off-by: Cyril Roelandt <tipecaml@gmail.com>
> 
> I'll let Ben queue this up.
> 
> Probably he'll want to avoid potentially leaving an ERR_PTR
> in ptp->phc_clock even if, with this fix, that would be
> harmless.

Sorry for the delay in looking at this.  This change is fine, as the
entire structure *ptp will be freed on the failure path.

I'm now on vacation until the new year.  Cyril, please re-send your
patch with the addition of:

Acked-by: Ben Hutchings <bhutchings@solarflare.com>

so it will show up on 'patchwork' again and David can apply it from
there.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
