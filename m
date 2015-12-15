From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH] net/mlx4_core: fix handling return value of
 mlx4_slave_convert_port
Date: Tue, 15 Dec 2015 11:09:40 +0200
Message-ID: <566FD8D4.5030506@mellanox.com>
References: <1450087564-28441-1-git-send-email-a.hajda@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Hadar Hen Zion <hadarh@mellanox.com>,
	Moni Shoua <monis@mellanox.com>,
	Yishai Hadas <yishaih@mellanox.com>,
	Maor Gottlieb <maorg@mellanox.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: Andrzej Hajda <a.hajda@samsung.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1450087564-28441-1-git-send-email-a.hajda@samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/14/2015 12:05 PM, Andrzej Hajda wrote:
> The function can return negative values, so its result should
> be assigned to signed variable.
>
> The problem has been detected using proposed semantic patch
> scripts/coccinelle/tests/assign_signed_to_unsigned.cocci [1].
>
> [1]: http://permalink.gmane.org/gmane.linux.kernel/2046107
>

Please add here

Fixes: fc48866f7 ('net/mlx4: Adapt code for N-Port VF')


> Signed-off-by: Andrzej Hajda <a.hajda@samsung.com>

otherwise, Looks good

Acked-by: Or Gerlitz <ogerlitz@mellanox.com>

Or.
