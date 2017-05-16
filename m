From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: Re: [PATCH] net: ethernet: broadcom: bnxt: remove dead code
Date: Tue, 16 May 2017 11:18:22 -0500
Message-ID: <20170516111822.Horde.UabU4yJ1mLiil9V-QRdsEDf@gator4166.hostgator.com>
References: <20170515222818.GA17519@embeddedgus>
 <CACKFLimtPW-uxEUK2GaL-ZPLhLOx19Qqzr8d-pVcV3bOEXqYTA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed; DelSp=Yes
Cc: Netdev <netdev@vger.kernel.org>,
        open list <linux-kernel@vger.kernel.org>
To: Michael Chan <michael.chan@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACKFLimtPW-uxEUK2GaL-ZPLhLOx19Qqzr8d-pVcV3bOEXqYTA@mail.gmail.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Michael,

Quoting Michael Chan <michael.chan@broadcom.com>:

> On Mon, May 15, 2017 at 3:28 PM, Gustavo A. R. Silva
> <garsilva@embeddedor.com> wrote:
>> Local variable _sh_ is assigned to a constant value and it is never updated
>> again. Remove this variable and the dead code it guards.
>>
>> Addresses-Coverity-ID: 1350916
>> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
>> ---
>>  drivers/net/ethernet/broadcom/bnxt/bnxt.c | 9 +++------
>>  1 file changed, 3 insertions(+), 6 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c  
>> b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
>> index 1f1e54b..018674b 100644
>> --- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
>> +++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
>> @@ -7380,12 +7380,10 @@ static int bnxt_get_dflt_rings(struct bnxt  
>> *bp, int *max_rx, int *max_tx,
>>  static int bnxt_set_dflt_rings(struct bnxt *bp)
>>  {
>>         int dflt_rings, max_rx_rings, max_tx_rings, rc;
>> -       bool sh = true;
>
> The point of this logic is that we can easily change the default to
> shared rings or separate rings.  I think what I'll do is change it so
> that the parameter sh is passed in and let the caller decide.  Thanks
> for pointing this out.
>

Sure thing, glad to help.
--
Gustavo A. R. Silva
