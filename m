From: Alexandre Torgue <alexandre.torgue@st.com>
Subject: Re: [PATCH] net: stmmac: enable tx queue 0 for gmac4 IPs synthesized
 with multiple TX queues
Date: Thu, 1 Dec 2016 18:21:05 +0100
Message-ID: <c5684f31-f1e4-75fd-852b-fd62f0940eef@st.com>
References: <1479998194-7113-1-git-send-email-niklass@axis.com>
 <20161128.112921.631621178188973017.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <peppe.cavallaro@st.com>, <niklass@axis.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>, <niklas.cassel@axis.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161128.112921.631621178188973017.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David and Niklas,

On 11/28/2016 05:29 PM, David Miller wrote:
> From: Niklas Cassel <niklas.cassel@axis.com>
> Date: Thu, 24 Nov 2016 15:36:33 +0100
>
>> From: Niklas Cassel <niklas.cassel@axis.com>
>>
>> The dwmac4 IP can synthesized with 1-8 number of tx queues.
>> On an IP synthesized with DWC_EQOS_NUM_TXQ > 1, all txqueues are disabled
>> by default. For these IPs, the bitfield TXQEN is R/W.
>>
>> Always enable tx queue 0. The write will have no effect on IPs synthesized
>> with DWC_EQOS_NUM_TXQ == 1.
>>
>> The driver does still not utilize more than one tx queue in the IP.
>>
>> Signed-off-by: Niklas Cassel <niklas.cassel@axis.com>
>
> Alexandre, we are still waiting for your implicit/explicit ACK on this
> change.

Yes you could add my Acked-by but it is already merged. My fault.
Sorry for my late answer :(

>
> Thank you.
>
