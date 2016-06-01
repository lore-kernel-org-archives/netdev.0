From: Max Filippov <jcmvbkbc@gmail.com>
Subject: Re: [PATCH][V2] net/ethoc: fix null dereference on error exit path
Date: Thu, 2 Jun 2016 00:25:37 +0300
Message-ID: <20160601212537.GA14527@octofox.metropolis>
References: <1464787010-3089-1-git-send-email-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S . Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Tobias Klauser <tklauser@distanz.ch>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1464787010-3089-1-git-send-email-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 01, 2016 at 02:16:50PM +0100, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
> 
> priv is assigned to NULL however some of the early error exit paths to
> label 'free' dereference priv, causing a null pointer dereference.
> 
> Move the label 'free' to just the free_netdev statement, and add a new
> exit path 'free2' for the error cases were clk_disable_unprepare needs
> calling before the final free.
> 
> Fixes issue found by CoverityScan, CID#113260
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> ---
>  drivers/net/ethernet/ethoc.c | 7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)

Reviewed-by: Max Filippov <jcmvbkbc@gmail.com>

-- 
Thanks.
-- Max
