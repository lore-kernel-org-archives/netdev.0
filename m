From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] gianfar: reduce stack usage in gianfar_ethtool.c
Date: Tue, 09 Aug 2011 19:28:36 -0700
Message-ID: <1312943316.11924.54.camel@Joe-Laptop>
References: <1312943399-14435-1-git-send-email-wangshaoyan.pt@taobao.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, Wang Shaoyan <wangshaoyan.pt@taobao.com>
To: stufever@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1312943399-14435-1-git-send-email-wangshaoyan.pt@taobao.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2011-08-10 at 10:29 +0800, stufever@gmail.com wrote:
> Signed-off-by: Wang Shaoyan <wangshaoyan.pt@taobao.com>
[]
> diff --git a/drivers/net/gianfar_ethtool.c b/drivers/net/gianfar_ethtool.c
[]
> @@ -686,10 +686,21 @@ static int gfar_ethflow_to_filer_table(struct gfar_private *priv, u64 ethflow, u
[]
> +	if (!local_rqfpr || !local_rqfcr) {
> +		pr_err("Out of memory\n");
> +		ret = 0;
> +		got err;

"got err" is true.

Please compile test your patches before sending them.
