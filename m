From: Antonio Murdaca <antoniomurdaca@gmail.com>
Subject: Re: [PATCH] ethernet: micrel: use time_after_eq macro
Date: Fri, 5 Jun 2015 18:54:13 +0200
Message-ID: <CAA7r0fokoEnp9wb9taegXbXsUYiHtQj44naTnw2A7WZfxQWJ5Q@mail.gmail.com>
References: <1433514627-16845-1-git-send-email-antonio.murdaca@gmail.com>
	<alpine.DEB.2.10.1506051745370.2388@hadrien>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Antonio Murdaca <antonio.murdaca@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	joe@perches.com, akpm@linux-foundation.org
To: Julia Lawall <julia.lawall@lip6.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.10.1506051745370.2388@hadrien>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'll use that then and resubmit this patch

Thanks

2015-06-05 17:45 GMT+02:00 Julia Lawall <julia.lawall@lip6.fr>:
> On Fri, 5 Jun 2015, Antonio Murdaca wrote:
>
>> use time_after_eq macro for time comparison
>>
>> Signed-off-by: Antonio Murdaca <antonio.murdaca@gmail.com>
>> ---
>>  drivers/net/ethernet/micrel/ksz884x.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/ethernet/micrel/ksz884x.c b/drivers/net/ethernet/micrel/ksz884x.c
>> index 48d2aec..9bce30c 100644
>> --- a/drivers/net/ethernet/micrel/ksz884x.c
>> +++ b/drivers/net/ethernet/micrel/ksz884x.c
>> @@ -6689,7 +6689,7 @@ static void mib_monitor(unsigned long ptr)
>>
>>       /* This is used to verify Wake-on-LAN is working. */
>>       if (hw_priv->pme_wait) {
>> -             if (hw_priv->pme_wait <= jiffies) {
>> +             if (time_after_eq(jiffies, hw_priv->pme_wait)) {
>
> There is also time_is_before_eq_jiffies.
>
> julia
>
>>                       hw_clr_wol_pme_status(&hw_priv->hw);
>>                       hw_priv->pme_wait = 0;
>>               }
>> --
>> 2.4.2
>>
>>



-- 
Antonio Murdaca
