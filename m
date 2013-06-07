From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH 0/2 v4] net/macb: RX path enhancement
Date: Fri, 7 Jun 2013 10:36:36 +0200
Message-ID: <51B19B94.6060301@atmel.com>
References: <cover.1370418770.git.nicolas.ferre@atmel.com> <20130606.162358.506642916485125446.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-arm-kernel@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>, <plagnioj@jcrosoft.com>,
	<hein_tibosch@yahoo.es>, <s.trumtrar@pengutronix.de>,
	<michal.simek@xilinx.com>, <monstr@monstr.eu>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130606.162358.506642916485125446.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/06/2013 01:23, David Miller :
> From: Nicolas Ferre <nicolas.ferre@atmel.com>
> Date: Wed, 5 Jun 2013 09:57:10 +0200
>
>> Here is the patch series for modifying the RX path in macb driver.
>> This change applies on GEM variant of the Cadence IP and introduces
>> function pointers to match the path to the proper adapter. The move
>> to RX buffers adapted to MTU and that can be DMAed directly in SKB
>> is done in two steps but can be merged in a single patch.
>>
>> v4: - rebased on top of net-next
>>      - removed the last patch of the series which needs rework
>>
>> v3: - rebased on top of net-next (containing recently added
>>        net/macb: fix ISR clear-on-write behavior only for some SoC)
>>      - added the ___cacheline_aligned_in_smp qualifier to napi field
>>        following Ben Hutchings' advice
>>
>> v2: - gave up the idea of using non-coherent memory for
>>        rx buffers
>>      - addition of the struct macb layout optimization
>
> Applied to net-next but I had to fix the printf format strings
> used in macb_init_rx_buffer_size().
>
> netdev->mtu is "unsigned int" so "%u"
> bp->rx_buffer_size is "size_t" so "%Zu"
>
> otherwise we get build warnings.

Thanks David.

Best regards,
-- 
Nicolas Ferre
