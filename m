From: Florian Vaussard <florian.vaussard@epfl.ch>
Subject: Re: [PATCH v2 0/6] can: sja1000: cleanups and new OF property
Date: Fri, 31 Jan 2014 13:41:36 +0100
Message-ID: <52EB9A00.9050102@epfl.ch>
References: <1391164513-11529-1-git-send-email-florian.vaussard@epfl.ch> <52EB9908.2090903@pengutronix.de>
Reply-To: florian.vaussard@epfl.ch
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Marc Kleine-Budde <mkl@pengutronix.de>,
	Wolfgang Grandegger <wg@grandegger.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <52EB9908.2090903@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Marc,

On 01/31/2014 01:37 PM, Marc Kleine-Budde wrote:
> On 01/31/2014 11:35 AM, Florian Vaussard wrote:
>> Hello,
>>
>> Changes sinces v1:
>> - Merge sja1000_of_platform.c into sja1000_platform.c (patch 4)
>>
>> The first part of this series performs serveral small cleanups
>> (patches 1 to 3).
>>
>> Patch 4 merges sja1000_of_platform.c into sja1000_platform.c.
>> Changes are pretty conservatives (mostly copy/paste/move). IRQ
>> is treated differently in the OF and non-OF versions, thus this
>> is where the fused version differs the most.
>>
>> The final part introduces the 'reg-io-width' binding (already used
>> by some other drivers) to perform a similar job as what was done
>> with IORESOURCE_MEM_XXBIT. This is needed on my system to correctly
>> take into account the aliasing of the address bus.
> 
> Good work, please keep compatibility for DTs without the 'reg-io-width'
> binding. The rest of my comments are only nitpicks. :)
> 

Good points. I will send a v3.

Regards,

Florian
