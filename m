From: David Miller <davem@davemloft.net>
Subject: Re: [patch] fsl/fman: fix a leak in tgec_free()
Date: Fri, 25 Nov 2016 20:30:26 -0500 (EST)
Message-ID: <20161125.203026.453934005279145007.davem@davemloft.net>
References: <20161124111931.GK17225@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: madalin.bucur@nxp.com, igal.liberman@freescale.com,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20161124111931.GK17225@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 24 Nov 2016 14:20:43 +0300

> We set "tgec->cfg" to NULL before passing it to kfree().  There is no
> need to set it to NULL at all.  Let's just delete it.
> 
> Fixes: 57ba4c9b56d8 ("fsl/fman: Add FMan MAC support")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
