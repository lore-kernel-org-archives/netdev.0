From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH 4/4] net: smsc911x: Move interrupt allocation to open/stop
Date: Fri, 2 Sep 2016 17:53:45 +0100
Message-ID: <20160902165344.GJ3423@arm.com>
References: <1472760909-19688-1-git-send-email-jeremy.linton@arm.com>
 <1472760909-19688-5-git-send-email-jeremy.linton@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, steve.glendinning@shawell.net,
        sergei.shtylyov@cogentembedded.com, andrew@lunn.ch
To: Jeremy Linton <jeremy.linton@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from foss.arm.com ([217.140.101.70]:56506 "EHLO foss.arm.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932621AbcIBQxm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 2 Sep 2016 12:53:42 -0400
Content-Disposition: inline
In-Reply-To: <1472760909-19688-5-git-send-email-jeremy.linton@arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 01, 2016 at 03:15:09PM -0500, Jeremy Linton wrote:
> The /proc/irq/xx information is incorrect for smsc911x because
> the request_irq is happening before the register_netdev has the
> proper device name. Moving it to the open also fixes the case
> of when the device is renamed.
> 
> Reported-by: Will Deacon <will.deacon@arm.com>
> Signed-off-by: Jeremy Linton <jeremy.linton@arm.com>
> ---
>  drivers/net/ethernet/smsc/smsc911x.c | 47 ++++++++++++++----------------------
>  1 file changed, 18 insertions(+), 29 deletions(-)

FWIW, this fixes the interface naming under /proc/<irq num>/ethX for me:

Tested-by: Will Deacon <will.deacon@arm.com>

Will
