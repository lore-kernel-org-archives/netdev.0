From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 4/7] qlcnic: Remove casts of pointer to same
 type
Date: Wed, 26 Mar 2014 15:47:21 -0400 (EDT)
Message-ID: <20140326.154721.548465980290363881.davem@davemloft.net>
References: <cover.1395692043.git.joe@perches.com>
	<ac82455e9d2f0487a3f96c44a41b5557fd09af95.1395692043.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shahed.shaikh@qlogic.com,
	Dept-HSGLinuxNICDev@qlogic.com, linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <ac82455e9d2f0487a3f96c44a41b5557fd09af95.1395692043.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Mon, 24 Mar 2014 13:15:37 -0700

> Casting a pointer to a pointer of the same type is pointless,
> so remove these unnecessary casts.
> 
> Done via coccinelle script:
> 
> $ cat typecast_2.cocci
> @@
> type T;
> T *foo;
> @@
> 
> -	(T *)foo
> +	foo
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
