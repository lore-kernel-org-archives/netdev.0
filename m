From: Ley Foon Tan <lftan@altera.com>
Subject: Re: [PATCH] net: stmmac: fix warning from Sparse for socfpga
Date: Tue, 26 Aug 2014 15:47:28 +0800
Message-ID: <CAFiDJ5_LspyDPnXnimZ=TRiZD191XQRvwqgfZSOU-ziu_DUx=Q@mail.gmail.com>
References: <1409037076-14775-1-git-send-email-lftan@altera.com>
	<53FC363E.6050604@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Vince Bridgers <vbridger@altera.com>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <53FC363E.6050604@st.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 26, 2014 at 3:24 PM, Giuseppe CAVALLARO
<peppe.cavallaro@st.com> wrote:
>> @@ -119,7 +119,8 @@ static int socfpga_dwmac_parse_data(struct
>> socfpga_dwmac *dwmac, struct device *
>>                         return -EINVAL;
>>                 }
>>
>> -               dwmac->splitter_base = (void *)devm_ioremap_resource(dev,
>> +               dwmac->splitter_base =
>> +                       (void __iomem *)devm_ioremap_resource(dev,
>
>
> I think, no casting should be done:
>
>    dwmac->splitter_base = devm_ioremap_resource(dev, ....
Oh ya, since both are same type. Will send new patch.

>
> patch should be for net-next
Do you mean the patch need based on net-next git?
I'm using linux-next git now.

Thanks.

Regards
Ley Foon
