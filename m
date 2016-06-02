From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][V2] net/ethoc: fix null dereference on error exit path
Date: Wed, 01 Jun 2016 22:02:20 -0700 (PDT)
Message-ID: <20160601.220220.760215551109095573.davem@davemloft.net>
References: <1464787010-3089-1-git-send-email-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, f.fainelli@gmail.com, tklauser@distanz.ch,
	jcmvbkbc@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464787010-3089-1-git-send-email-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com>
Date: Wed,  1 Jun 2016 14:16:50 +0100

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

Applied, thanks.
