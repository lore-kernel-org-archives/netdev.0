From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH] net: stmmac: fix warning from Sparse for socfpga
Date: Tue, 26 Aug 2014 10:04:25 +0200
Message-ID: <53FC3F89.9030406@st.com>
References: <1409037076-14775-1-git-send-email-lftan@altera.com>	<53FC363E.6050604@st.com> <CAFiDJ5_LspyDPnXnimZ=TRiZD191XQRvwqgfZSOU-ziu_DUx=Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Vince Bridgers <vbridger@altera.com>
To: Ley Foon Tan <lftan@altera.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAFiDJ5_LspyDPnXnimZ=TRiZD191XQRvwqgfZSOU-ziu_DUx=Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/26/2014 9:47 AM, Ley Foon Tan wrote:
> On Tue, Aug 26, 2014 at 3:24 PM, Giuseppe CAVALLARO
> <peppe.cavallaro@st.com> wrote:
>>> @@ -119,7 +119,8 @@ static int socfpga_dwmac_parse_data(struct
>>> socfpga_dwmac *dwmac, struct device *
>>>                          return -EINVAL;
>>>                  }
>>>
>>> -               dwmac->splitter_base = (void *)devm_ioremap_resource(dev,
>>> +               dwmac->splitter_base =
>>> +                       (void __iomem *)devm_ioremap_resource(dev,
>>
>>
>> I think, no casting should be done:
>>
>>     dwmac->splitter_base = devm_ioremap_resource(dev, ....
> Oh ya, since both are same type. Will send new patch.

thx a lot

>
>>
>> patch should be for net-next
> Do you mean the patch need based on net-next git?

yes I do.

> I'm using linux-next git now.

ok, can you signal it in the subject (e.g.  [PATCH (net-next)]
This can help on reviewing and IIRC required by Maintainer too

>
> Thanks.

welcome

BR
peppe

> Regards
> Ley Foon
>
>
