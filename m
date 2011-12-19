From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 14/15] module_param: make bool parameters really bool
 (net & drivers/net)
Date: Sun, 18 Dec 2011 22:42:56 -0800
Message-ID: <1324276976.23473.4.camel@joe2Laptop>
References: <877h1ysenl.fsf@rustcorp.com.au>
	 <1323920752.29500.11.camel@joe2Laptop> <87k45xqvfs.fsf@rustcorp.com.au>
	 <20111215.231517.185391590658983405.davem@davemloft.net>
	 <87ehw1nm9r.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	pawel.moll@arm.com, netdev@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87ehw1nm9r.fsf@rustcorp.com.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2011-12-19 at 16:19 +1030, Rusty Russell wrote:
> diff --git a/drivers/net/ethernet/amd/amd8111e.h b/drivers/net/ethernet/amd/amd8111e.h
[]
> @@ -808,8 +808,8 @@ typedef enum {
[]
> +static bool coalesce[MAX_UNITS] = {1,1,1,1,1,1,1,1};
> +static bool dynamic_ipg[MAX_UNITS] = {0,0,0,0,0,0,0,0};

Perhaps these array initializations could/should be:

static bool coalesce[MAX_UNITS] = { [0 ... MAX_UNITS - 1] = true };
static bool dynamic_irq[MAX_UNITS] = { [0 ... MAX_UNITS - 1] = false };

in a separate patch maybe.
