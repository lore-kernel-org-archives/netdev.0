From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH v2 2/2] can: spi: hi311x: Add Holt HI-311x CAN driver
Date: Thu, 9 Mar 2017 10:59:07 +0100
Message-ID: <6df4a9ae-eaba-6f3f-9c23-ae269548b005@grandegger.com>
References: <1484680922-25813-1-git-send-email-akshay.bhat@timesys.com>
 <1484680922-25813-2-git-send-email-akshay.bhat@timesys.com>
 <2197294b-e6cf-6c56-1419-3a4f95c29db7@timesys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
        Akshay Bhat <nodeax@gmail.com>
To: Akshay Bhat <akshay.bhat@timesys.com>, mkl@pengutronix.de
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <2197294b-e6cf-6c56-1419-3a4f95c29db7@timesys.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Akshay,

unfortunately there are not many CAN controllers for the SPI bus. I just 
know the MPC251x, which behaves badly (message losses) under Linux, 
especially at hight bit-rates due to insufficient RX buffering. What is 
your experience with that driver for the HI-311x?

Thanks,

Wolfgang.

Am 07.03.2017 um 16:31 schrieb Akshay Bhat:
>
>
> On 01/17/2017 02:22 PM, Akshay Bhat wrote:
>> This patch adds support for the Holt HI-311x CAN controller. The HI311x
>> CAN controller is capable of transmitting and receiving standard data
>> frames, extended data frames and remote frames. The HI311x interfaces
>> with the host over SPI.
>>
>> Datasheet: www.holtic.com/documents/371-hi-3110_v-rev-jpdf.do
>>
>> Signed-off-by: Akshay Bhat <nodeax@gmail.com>
>> ---
>>
>
>
> Hi Marc,
>
> Wanted to check if this patch can be included in the next kernel release
> (4.12).
>
> Thanks,
> Akshay
> --
> To unsubscribe from this list: send the line "unsubscribe linux-can" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
