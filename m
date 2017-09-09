From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethernet: ti: netcp_core: no need in
 netif_napi_del
Date: Fri, 08 Sep 2017 20:54:06 -0700 (PDT)
Message-ID: <20170908.205406.1092753716665560544.davem@davemloft.net>
References: <1504798350-790-1-git-send-email-ivan.khoronzhuk@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: w-kwok2@ti.com, m-karicheri2@ti.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, grygorii.strashko@ti.com
To: ivan.khoronzhuk@linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1504798350-790-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Date: Thu,  7 Sep 2017 18:32:30 +0300

> Don't remove rx_napi specifically just before free_netdev(),
> it's supposed to be done in it and is confusing w/o tx_napi deletion.
> 
> Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>

Applied.
