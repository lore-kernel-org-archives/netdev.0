From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH] net: ugg_geth: Fix build error in -next
Date: Sun, 10 Aug 2014 11:42:41 -0700
Message-ID: <53E7BD21.6010301@roeck-us.net>
References: <1407687554-14539-1-git-send-email-linux@roeck-us.net> <20140810183622.GC5134@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Li Yang <leoli@freescale.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org
To: =?windows-1252?Q?Uwe_Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140810183622.GC5134@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/10/2014 11:36 AM, Uwe Kleine-K=F6nig wrote:
> Hello Guenter,
>
> On Sun, Aug 10, 2014 at 09:19:14AM -0700, Guenter Roeck wrote:
>> powerpc:mpc83xx_defconfig and other builds fail with
>>
>> drivers/net/ethernet/freescale/ucc_geth.c: In function 'ucc_geth_rem=
ove':
>> drivers/net/ethernet/freescale/ucc_geth.c:3927:19: error:
>> 	'struct ucc_geth_private' has no member named 'info'
>>    of_node_put(ugeth->info->tbi_node);
>>                       ^
>> drivers/net/ethernet/freescale/ucc_geth.c:3928:19: error:
>> 	     'struct ucc_geth_private' has no member named 'info'
>>    of_node_put(ugeth->info->phy_node);
>>    		     ^
>>
>> Introduced by commit "net: ucc_geth: drop acquired references in pro=
be error
>> path and remove".
>>
>>  From the context, it appears that the variable is named ug_info.
>>
>> Cc: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
>> Signed-off-by: Guenter Roeck <linux@roeck-us.net>
>> ---
>> Only seen in -next.
> My patch was only sent just now, but it has the subject right:
>
Excellent.

> 	http://mid.gmane.org/1407695525-32227-1-git-send-email-u.kleine-koen=
ig@pengutronix.de
>
The link doesn't seem to work for some reason.

> Another upside is that it contains a Fixes: header.
>
Even better. I need to start using that.

> Other than that my patch is the same. In case davem picks up yours:
>
> Acked-by: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
>

I don't need the glory ;-). Dave, please pick Uwe's patch.

Thanks,
Guenter
