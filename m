From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH v4 1/4] can: m_can: move Message RAM initialization to
 function
Date: Mon, 15 May 2017 20:51:30 -0700
Message-ID: <1d41efe1-d24f-4700-8986-0d5dc848ea23@hartkopp.net>
References: <20170505135033.8349-1-quentin.schulz@free-electrons.com>
 <90788d6d-24f3-64ba-43f3-16301b777536@free-electrons.com>
 <4676456c-823c-d7db-2139-35c8229109f0@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, alexandre.belloni@free-electrons.com,
        thomas.petazzoni@free-electrons.com
To: Marc Kleine-Budde <mkl@pengutronix.de>,
        Quentin Schulz <quentin.schulz@free-electrons.com>,
        wg@grandegger.com, mario.huettel@gmx.net
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <4676456c-823c-d7db-2139-35c8229109f0@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 05/15/2017 06:50 AM, Marc Kleine-Budde wrote:
> On 05/12/2017 08:37 AM, Quentin Schulz wrote:
>> Hi all,
>>
>> On 05/05/2017 15:50, Quentin Schulz wrote:
>>> To avoid possible ECC/parity checksum errors when reading an
>>> uninitialized buffer, the entire Message RAM is initialized when probing
>>> the driver. This initialization is done in the same function reading the
>>> Device Tree properties.
>>>
>>> This patch moves the RAM initialization to a separate function so it can
>>> be called separately from device initialization from Device Tree.
>>>
>>> Signed-off-by: Quentin Schulz <quentin.schulz@free-electrons.com>
>>
>> It's been a week since I sent this patch series. Any comments?
>
> Looks good, added to linux-can-next.

Isn't this a fix for linux-can instead?

At least it would make no sense to me to have the upgraded M_CAN driver 
in Linux 4.12 without this fix.

Regards,
Oliver
