From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] liquidio: remove unnecessary NULL check before
 kfree in delete_glists
Date: Thu, 19 Oct 2017 13:28:11 +0100 (WEST)
Message-ID: <20171019.132811.2090742958169338799.davem@davemloft.net>
References: <20171017185920.GA16976@embeddedor.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: derek.chickles@caviumnetworks.com,
        satananda.burla@caviumnetworks.com,
        felix.manlunas@caviumnetworks.com,
        raghu.vatsavayi@caviumnetworks.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, garsilva@embeddedorcom
To: garsilva@embeddedor.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171017185920.GA16976@embeddedor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Date: Tue, 17 Oct 2017 13:59:20 -0500

> NULL check before freeing functions like kfree is not needed.
> 
> This issue was detected with the help of Coccinelle.
> 
> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>

Applied to net-next.
