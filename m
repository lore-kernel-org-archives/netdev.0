From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: [PATCH v3 00/13] net: ethernet: ti: cpsw: split driver data and
 per ndev data
Date: Wed, 10 Aug 2016 19:38:01 +0300
Message-ID: <ee835c48-4978-10ab-f061-1a77387941a6@ti.com>
References: <1470784964-26440-1-git-send-email-ivan.khoronzhuk@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-omap@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<dlide@ti.com>
To: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>,
	<netdev@vger.kernel.org>, <mugunthanvnm@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1470784964-26440-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/10/2016 02:22 AM, Ivan Khoronzhuk wrote:
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

Reviewed-by: Grygorii Strashko <grygorii.strashko@ti.com>

-- 
regards,
-grygorii
