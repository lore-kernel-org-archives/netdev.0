From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH v4 3/5] net: ethernet: ti: cpsw: add multi queue support
Date: Tue, 23 Aug 2016 11:09:37 +0530
Message-ID: <507f44e1-f004-7d00-e069-e96a8e5c7e0a@ti.com>
References: <1471889908-29983-1-git-send-email-ivan.khoronzhuk@linaro.org>
 <1471889908-29983-4-git-send-email-ivan.khoronzhuk@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <linux-omap@vger.kernel.org>,
        <nsekhar@ti.com>, <dlide@ti.com>
To: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>,
        <davem@davemloft.net>, <netdev@vger.kernel.org>,
        <grygorii.strashko@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1471889908-29983-4-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 22 August 2016 11:48 PM, Ivan Khoronzhuk wrote:
> The cpsw h/w supports up to 8 tx and 8 rx channels. This patch adds
> multi-queue support to the driver only, shaper configuration will
> be added with separate patch series. Default shaper mode, as
> before, priority mode, but with corrected priority order, 0 - is
> highest priority, 7 - lowest.
> 
> The poll function handles all unprocessed channels, till all of
> them are free, beginning from hi priority channel.
> 
> In dual_emac mode the channels are shared between two network devices,
> as it's with single-queue default mode.
> 
> The statistic for every channel can be read with:
> $ ethtool -S ethX
> 
> Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>

Reviewed-by: Mugunthan V N <mugunthanvnm@ti.com>

Regards
Mugunthan V N
