From: Andre Heider <a.heider@gmail.com>
Subject: Re: atl1c: DMA: Out of SW-IOMMU space
Date: Sun, 3 Mar 2013 04:21:52 +0100
Message-ID: <CAHsu+b_2dGk+-hkbnE8ziVxP52tKhUkL6BOek67HMA-R-2zPaw@mail.gmail.com>
References: <CAHsu+b8JkVPbh7p7pj4u2XFJ3oA+HfxiGVJyz7TLG3FNQzBZCQ@mail.gmail.com>
	<157393863283F442885425D2C4542856489D5748@nasanexd02f.na.qualcomm.com>
	<1362279166.15793.59.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Huang, Xiong" <xiong@qca.qualcomm.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	stable@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1362279166.15793.59.camel@edumazet-glaptop>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Mar 3, 2013 at 3:52 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Sun, 2013-03-03 at 01:48 +0000, Huang, Xiong wrote:
>> There is another patch follows commit ac574804d412047e52de4dd887615cc88f58aeb0, would you have a try ?
>
>
> Do you mean the following ?
>
> commit 7cb08d7f3a5ea6131f4f243c2080530ac41cb293
> Author: Huang, Xiong <xiong@qca.qualcomm.com>
> Date:   Tue Feb 19 07:23:09 2013 +0000
>
>     atl1c: restore buffer state
>
>     in the previous commit : f1f220ea1dda078, the BUSY state of buffer is wrongly
>     deleted. this patch just restore it.
>
>     Signed-off-by: xiong <xiong@qca.qualcomm.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>

Yeah, that's the only relevant commit I could find too, and indeed
that patch fixes the problem, thanks!

Can we please apply this to 3.8.y ? atl1c is broken on 3.8 and 3.8.1,
<= 3.7 is fine.

Thanks,
Andre
