From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH v4 1/5] net: ethernet: ti: davinci_cpdma: split descs num
 between all channels
Date: Tue, 23 Aug 2016 11:09:17 +0530
Message-ID: <a693f2fd-1e50-41cb-eab7-5007fc08be55@ti.com>
References: <1471889908-29983-1-git-send-email-ivan.khoronzhuk@linaro.org>
 <1471889908-29983-2-git-send-email-ivan.khoronzhuk@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <linux-omap@vger.kernel.org>,
        <nsekhar@ti.com>, <dlide@ti.com>
To: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>,
        <davem@davemloft.net>, <netdev@vger.kernel.org>,
        <grygorii.strashko@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1471889908-29983-2-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 22 August 2016 11:48 PM, Ivan Khoronzhuk wrote:
> Tx channels share same pool of descriptors. Thus one channel can
> block another if pool is emptied by one. But, the shaper should
> decide which channel is allowed to send packets. To avoid such
> impact of one channel on another, let every channel to have its
> own piece of pool.
> 
> Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>

Reviewed-by: Mugunthan V N <mugunthanvnm@ti.com>

Regards
Mugunthan V N
