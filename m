From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/mlx4_core: fix handling return value of
 mlx4_slave_convert_port
Date: Tue, 15 Dec 2015 11:55:16 -0500 (EST)
Message-ID: <20151215.115516.1151100457916943363.davem@davemloft.net>
References: <1450087564-28441-1-git-send-email-a.hajda@samsung.com>
	<566FD8D4.5030506@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: a.hajda@samsung.com, jackm@dev.mellanox.co.il,
	b.zolnierkie@samsung.com, m.szyprowski@samsung.com,
	eranbe@mellanox.com, hadarh@mellanox.com, monis@mellanox.com,
	yishaih@mellanox.com, maorg@mellanox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: ogerlitz@mellanox.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <566FD8D4.5030506@mellanox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Tue, 15 Dec 2015 11:09:40 +0200

> On 12/14/2015 12:05 PM, Andrzej Hajda wrote:
>> The function can return negative values, so its result should
>> be assigned to signed variable.
>>
>> The problem has been detected using proposed semantic patch
>> scripts/coccinelle/tests/assign_signed_to_unsigned.cocci [1].
>>
>> [1]: http://permalink.gmane.org/gmane.linux.kernel/2046107
>>
> 
> Please add here
> 
> Fixes: fc48866f7 ('net/mlx4: Adapt code for N-Port VF')
> 
>> Signed-off-by: Andrzej Hajda <a.hajda@samsung.com>
> 
> otherwise, Looks good
> 
> Acked-by: Or Gerlitz <ogerlitz@mellanox.com>

Applied with Fixes tag added.
