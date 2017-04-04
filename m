From: Akshay Bhat <akshay.bhat-jEh4hwF5bVhBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH v4 2/2] can: spi: hi311x: Add Holt HI-311x CAN driver
Date: Tue, 4 Apr 2017 14:22:03 -0400
Message-ID: <df7c7be0-8590-3517-403a-e50aeea61b8d@timesys.com>
References: <1489785040-26477-1-git-send-email-akshay.bhat@timesys.com>
 <1489785040-26477-2-git-send-email-akshay.bhat@timesys.com>
 <32114de2-8ab7-daec-9b36-209cab0ea550@timesys.com>
 <145b8725-c3dd-e899-8a3e-133e68a3b1e6@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Akshay Bhat <nodeax-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>, wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <145b8725-c3dd-e899-8a3e-133e68a3b1e6-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On 04/04/2017 11:34 AM, Marc Kleine-Budde wrote:
> On 03/24/2017 06:20 PM, Akshay Bhat wrote:
>> Hi Marc,
>>
>> On 03/17/2017 05:10 PM, Akshay Bhat wrote:
>>> This patch adds support for the Holt HI-311x CAN controller. The HI311x
>>> CAN controller is capable of transmitting and receiving standard data
>>> frames, extended data frames and remote frames. The HI311x interfaces
>>> with the host over SPI.
>>>
>>> Datasheet: www.holtic.com/documents/371-hi-3110_v-rev-jpdf.do
>>>
>>> Signed-off-by: Akshay Bhat <nodeax-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>>> ---
>>>
>>
>> If there are no further review comments can this series be applied to
>> can-next or does it need to wait for the next kernel release cycle (4.13)?
> 
> The driver doesn't check if the workqueue allocation is successfull,
> I've squashed this patch:
> 

Thanks Marc, appreciate it. The squashed patch looks good.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
