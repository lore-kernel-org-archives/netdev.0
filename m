From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Subject: Re: [PATCH] net: ethernet: chelsio: cxgb4: t4_hw.c: Cleaning up
 uninitialized variables
Date: Sun, 1 Jun 2014 21:36:57 +0200
Message-ID: <CAFo99gbeRu=D4LqO=i43GfCY+opR_o+wwOo0u4VuxUKBNG+Xmw@mail.gmail.com>
References: <1401626055-15144-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
	<CBA48B605613B640864883107238931C13AC20@nice.asicdesigners.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Dimitrios Michailidis <dm@chelsio.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CBA48B605613B640864883107238931C13AC20@nice.asicdesigners.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dimitrios!

Okay sorry, I see what you mean...

Best regards
Rickard Strandqvist


2014-06-01 21:11 GMT+02:00 Dimitrios Michailidis <dm@chelsio.com>:
> Rickard Strandqvist wrote:
>> There is a risk that the variable will be used without being initialized.
>
> There isn't actual risk here, this variable is not used uninitialized AFAICS.
>
>> This was largely found by using a static code analysis program called cppcheck.
>
> It seems this is a false inference by the tool.  I think the preferred method to suppress false tool warnings is to use uninitialized_var.
>
>> Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
>> ---
>>  drivers/net/ethernet/chelsio/cxgb4/t4_hw.c |    2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
>> b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
>> index bba6768..326c005 100644
>> --- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
>> +++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
>> @@ -571,7 +571,7 @@ int t4_seeprom_wp(struct adapter *adapter, bool
>> enable)
>>   */
>>  int get_vpd_params(struct adapter *adapter, struct vpd_params *p)
>>  {
>> -     u32 cclk_param, cclk_val;
>> +     u32 cclk_param, cclk_val = 0;
>>       int i, ret, addr;
>>       int ec, sn, pn;
>>       u8 *vpd, csum;
>> --
>> 1.7.10.4
>
