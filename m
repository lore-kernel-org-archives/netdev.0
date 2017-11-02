From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] liquidio: remove redundant setting of inst_processed
 to zero
Date: Thu, 02 Nov 2017 15:54:02 +0900 (KST)
Message-ID: <20171102.155402.2303424878123786750.davem@davemloft.net>
References: <20171101090913.16215-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: derek.chickles@caviumnetworks.com,
        satananda.burla@caviumnetworks.com,
        felix.manlunas@caviumnetworks.com,
        raghu.vatsavayi@caviumnetworks.com, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171101090913.16215-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com>
Date: Wed,  1 Nov 2017 09:09:13 +0000

> From: Colin Ian King <colin.king@canonical.com>
> 
> The zero value assigned to inst_processed at the end of each
> iteration of the do-while loop is overwritten on the next iteration
> and hence it is a redundant assignment and can be removed. Cleans
> up clang warning:
> 
> drivers/net/ethernet/cavium/liquidio/request_manager.c:480:3:
> warning: Value stored to 'inst_processed' is never read
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied.
