From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 14/15] module_param: make bool parameters really bool
 (net & drivers/net)
Date: Wed, 14 Dec 2011 19:45:52 -0800
Message-ID: <1323920752.29500.11.camel@joe2Laptop>
References: <877h1ysenl.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: lkml - Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <877h1ysenl.fsf@rustcorp.com.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2011-12-15 at 13:51 +1030, Rusty Russell wrote:
> module_param(bool) used to counter-intuitively take an int.  In
> fddd5201 (mid-2009) we allowed bool or int/unsigned int using a messy
> trick.
[]
> diff --git a/drivers/net/caif/caif_serial.c b/drivers/net/caif/caif_serial.c
[]
> @@ -38,15 +38,15 @@ MODULE_ALIAS_LDISC(N_CAIF);
[]
> -static int ser_use_stx = 1;
> +static bool ser_use_stx = 1;

Could you respin these please using bool foo = true/false instead?
