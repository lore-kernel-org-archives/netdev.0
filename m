From: Ley Foon Tan <lftan@altera.com>
Subject: Re: [PATCH (net-next) v2] net: stmmac: fix warning from Sparse for socfpga
Date: Wed, 27 Aug 2014 09:24:22 +0800
Message-ID: <CAFiDJ5-S40ve--sg_2sskx2BBm7zmZdmDmNpyMeXnHcVdrx8ag@mail.gmail.com>
References: <1409046479-18546-1-git-send-email-lftan@altera.com>
	<53FC5DCF.4060202@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Vince Bridgers <vbridger@altera.com>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <53FC5DCF.4060202@st.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 26, 2014 at 6:13 PM, Giuseppe CAVALLARO
<peppe.cavallaro@st.com> wrote:
> On 8/26/2014 11:47 AM, Ley Foon Tan wrote:
>>
>> Warning:
>> drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c:122:41:
>> sparse: cast removes address space of expression
>> drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c:122:38:
>> sparse: incorrect type in assignment (different address spaces)
>>
>> Signed-off-by: Ley Foon Tan <lftan@altera.com>
>> ---
>>   drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c | 2 +-
>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
>> b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
>> index cd613d7..ff54a1f 100644
>> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
>> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
>> @@ -119,7 +119,7 @@ static int socfpga_dwmac_parse_data(struct
>> socfpga_dwmac *dwmac, struct device *
>>                         return -EINVAL;
>>                 }
>>
>> -               dwmac->splitter_base = (void *)devm_ioremap_resource(dev,
>> +               dwmac->splitter_base = devm_ioremap_resource(dev,
>>                         &res_splitter);
>
>
> can the ioremap call stay in a single line ? or pls review indent looks
> NOK

It will has "line over 80 characters" if it is one line code.
BTW, this patch passed "checkpatch.pl" script.
Let me know if think indent is not okay.

Thanks.
