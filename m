From: David Miller <davem@davemloft.net>
Subject: Re: [patch -mainline v2] af_key: more info leaks in pfkey messages
Date: Sun, 28 Jul 2013 13:21:28 -0700 (PDT)
Message-ID: <20130728.132128.473273050357111535.davem@davemloft.net>
References: <20130725073205.GQ3109@secunet.com>
	<20130728200444.GA8684@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, herbert@gondor.hengli.com.au,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	minipli@googlemail.com
To: dan.carpenter@oracle.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20130728200444.GA8684@elgon.mountain>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Sun, 28 Jul 2013 23:04:45 +0300

> This is inspired by a5cc68f3d6 "af_key: fix info leaks in notify
> messages".  There are some struct members which don't get initialized
> and could disclose small amounts of private information.
> 
> Acked-by: Mathias Krause <minipli@googlemail.com>
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> ---
> v2: set ->sadb_x_policy_priority correctly instead of just clearing it

I'll apply this as soon as Steffen reviews it.
