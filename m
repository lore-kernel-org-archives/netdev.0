From: Hui Wang <jason77.wang@gmail.com>
Subject: Re: [PATCH] can: flexcan: use be32_to_cpup to handle the value of
 dt entry
Date: Thu, 28 Jun 2012 09:54:12 +0800
Message-ID: <4FEBB944.1060701@gmail.com>
References: <1340789236-28266-1-git-send-email-mkl@pengutronix.de> <1340789236-28266-2-git-send-email-mkl@pengutronix.de> <CAAQ0ZWT3ovG7eKZZuoSZkx4FGd+W9XvnTk8R1yuD02u4wqGNHQ@mail.gmail.com> <4FEAEFC1.4060104@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Shawn Guo <shawn.guo@linaro.org>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>, <linux-can@vger.kernel.org>,
	Hui Wang <jason77.wang@gmail.com>
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <4FEAEFC1.4060104@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Marc Kleine-Budde wrote:
> On 06/27/2012 01:26 PM, Shawn Guo wrote:
>   
>> On 27 June 2012 17:27, Marc Kleine-Budde <mkl@pengutronix.de> wrote:
>>     
>>> From: Hui Wang <jason77.wang@gmail.com>
>>>
>>> The freescale arm i.MX series platform can support this driver, and
>>> usually the arm cpu works in the little endian mode by default, while
>>> device tree entry value is stored in big endian format, we should use
>>> be32_to_cpup() to handle them, after modification, it can work well
>>> both on the le cpu and be cpu.
>>>
>>>       
>> I'm wondering if you want to just use of_property_read_u32() to make
>> it a little bit easier.
>>     
>
> Even better. Hui can you send a updated patch.
>   
OK.

Regards,
Hui.
> Marc
>
>   

