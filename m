From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: [PATCH v2 00/14] net: ethernet: ti: cpsw: split driver data and
 per ndev data
Date: Tue, 9 Aug 2016 18:45:35 +0300
Message-ID: <8e766576-e147-fdca-30bb-c12531cc91b8@ti.com>
References: <1470480524-6851-1-git-send-email-ivan.khoronzhuk@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-omap@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<dlide@ti.com>
To: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>,
	<netdev@vger.kernel.org>, <mugunthanvnm@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1470480524-6851-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/06/2016 01:48 PM, Ivan Khoronzhuk wrote:
> In dual_emac mode the driver can handle 2 network devices. Each of them can use
> its own private data and common data/resources. This patchset splits common driver
> data/resources and private per net device data.
> It leads to:
> - reduce memory usage
> - increase code readability
> - allows add a bunch of simplification
> - create prerequisites to add multi-channel support,
>   when channels are shared between net devices
>
> Doesn't have bad impact on performance.
> v1: https://lkml.org/lkml/2016/8/4/616

Patches 6-14 (except PATCH v2 12/14]) looks good.

Thanks.


-- 
regards,
-grygorii
