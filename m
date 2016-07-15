From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mlxsw: spectrum_router: Return -ENOENT in case of error
Date: Thu, 14 Jul 2016 22:15:11 -0700 (PDT)
Message-ID: <20160714.221511.31164307170492201.davem@davemloft.net>
References: <1468477125-3153-1-git-send-email-christophe.jaillet@wanadoo.fr>
	<20160714062819.GB2228@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: christophe.jaillet@wanadoo.fr, jiri@mellanox.com,
	idosch@mellanox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: jiri@resnulli.us
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20160714062819.GB2228@nanopsycho.orion>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jiri Pirko <jiri@resnulli.us>
Date: Thu, 14 Jul 2016 08:28:19 +0200

> Thu, Jul 14, 2016 at 08:18:45AM CEST, christophe.jaillet@wanadoo.fr wrote:
>>'vr' should be a valid pointer here, so returning 'PTR_ERR(vr)' is wrong.
>>Return an explicit error code (-ENOENT) instead.
>>
> 
> This is fo net-next.
> 
> Fixes: 61c503f976 ("mlxsw: spectrum_router: Implement fib4 add/del switchdev obj ops")
> 
>>Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
> 
> Acked-by: Jiri Pirko <jiri@mellanox.com>

Applied, thanks.
