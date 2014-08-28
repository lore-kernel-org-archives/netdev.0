From: Ley Foon Tan <lftan@altera.com>
Subject: Re: [PATCH] net: stmmac: fix warning from Sparse for socfpga
Date: Thu, 28 Aug 2014 11:33:44 +0800
Message-ID: <CAFiDJ5_AT5QoYiiWCMt5iWBbJkSzF8XAyMEX=H4boQSM4RDsbw@mail.gmail.com>
References: <1409037076-14775-1-git-send-email-lftan@altera.com>
	<20140827.163343.715764078341662382.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Vince Bridgers <vbridger@altera.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140827.163343.715764078341662382.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 28, 2014 at 7:33 AM, David Miller <davem@davemloft.net> wrote:
> From: Ley Foon Tan <lftan@altera.com>
> Date: Tue, 26 Aug 2014 15:11:16 +0800
>
>> @@ -119,7 +119,8 @@ static int socfpga_dwmac_parse_data(struct socfpga_dwmac *dwmac, struct device *
>>                       return -EINVAL;
>>               }
>>
>> -             dwmac->splitter_base = (void *)devm_ioremap_resource(dev,
>> +             dwmac->splitter_base =
>> +                     (void __iomem *)devm_ioremap_resource(dev,
>>                       &res_splitter);
>
> Please either put this entire call on one line (it'll only be slightly
> over 80 columns, which is fine), or indent it properly.
>
> And by properly I meant that the second and subsequent lines of a function
> call must be indented precisely to the first column after the openning
> parenthesis of the function call on the first line.  You must use the
> appropriate number of TAB and SPACE characters necessary to do so.
>
> If it is indented using only TAB characters, it is very likely that you
> are doing it wrong.
Okay, will send in new patch to fix this.
Thanks.
