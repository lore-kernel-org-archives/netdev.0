From: David Miller <davem@davemloft.net>
Subject: Re: [patch -mainline v2] af_key: more info leaks in pfkey messages
Date: Tue, 30 Jul 2013 16:26:50 -0700 (PDT)
Message-ID: <20130730.162650.1407736100425232005.davem@davemloft.net>
References: <20130728200444.GA8684@elgon.mountain>
	<20130728.132128.473273050357111535.davem@davemloft.net>
	<20130729091653.GS3109@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dan.carpenter@oracle.com, herbert@gondor.hengli.com.au,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	minipli@googlemail.com
To: steffen.klassert@secunet.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20130729091653.GS3109@secunet.com>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Mon, 29 Jul 2013 11:16:53 +0200

> On Sun, Jul 28, 2013 at 01:21:28PM -0700, David Miller wrote:
>> From: Dan Carpenter <dan.carpenter@oracle.com>
>> Date: Sun, 28 Jul 2013 23:04:45 +0300
>> 
>> > This is inspired by a5cc68f3d6 "af_key: fix info leaks in notify
>> > messages".  There are some struct members which don't get initialized
>> > and could disclose small amounts of private information.
>> > 
>> > Acked-by: Mathias Krause <minipli@googlemail.com>
>> > Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
>> > ---
>> > v2: set ->sadb_x_policy_priority correctly instead of just clearing it
>> 
>> I'll apply this as soon as Steffen reviews it.
> 
> The patch looks good, for the case you want to apply it directly to
> the net tree:
> 
> Acked-by: Steffen Klassert <steffen.klassert@secunet.com>

Applied and queued up for -stable, thanks everyone.
