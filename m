From: Kalle Valo <kvalo@adurom.com>
Subject: Re: [PATCH] drivers/net/wireless: Remove typedef local_info_t
Date: Wed, 13 Aug 2014 15:59:49 +0300
Message-ID: <87egwka6ka.fsf@purkki.adurom.net>
References: <20140813091713.GA2995@himangi-Dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Simon Kelley <simon@thekelleys.org.uk>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Julia Lawall <julia.lawall@lip6.fr>
To: Himangi Saraogi <himangi774@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140813091713.GA2995@himangi-Dell> (Himangi Saraogi's message
	of "Wed, 13 Aug 2014 14:47:13 +0530")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Himangi Saraogi <himangi774@gmail.com> writes:

> The Linux kernel coding style guidelines suggest not using typedefs
> for structure types. This patch gets rid of the typedef for
> local_info_t. Also, the name of the struct is changed to drop the _t,
> to make the name look less typedef-like.

[...]

>
> Signed-off-by: Himangi Saraogi <himangi774@gmail.com>
> Acked-by: Julia Lawall <julia.lawall@lip6.fr>
> ---
>  drivers/net/wireless/atmel_cs.c | 22 +++++++++++-----------

You should prefix the patch with "atmel_cs:", not
"drivers/net/wireless".

-- 
Kalle Valo
