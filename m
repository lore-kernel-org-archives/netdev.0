From: Florian Vaussard <florian.vaussard@epfl.ch>
Subject: Re: [PATCH 0/5] can: sja1000: cleanups and new OF property
Date: Thu, 30 Jan 2014 17:51:01 +0100
Message-ID: <52EA82F5.5000004@epfl.ch>
References: <1391092168-21246-1-git-send-email-florian.vaussard@epfl.ch> <52EA6E31.2030604@pengutronix.de> <52EA6F6E.1010405@epfl.ch> <52EA718B.3090006@pengutronix.de>
Reply-To: florian.vaussard@epfl.ch
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Marc Kleine-Budde <mkl@pengutronix.de>,
	Wolfgang Grandegger <wg@grandegger.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52EA718B.3090006@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 01/30/2014 04:36 PM, Marc Kleine-Budde wrote:
> On 01/30/2014 04:27 PM, Florian Vaussard wrote:
>> Hello,
>>
>> On 01/30/2014 04:22 PM, Marc Kleine-Budde wrote:
>>> Hello Florian,
>>>
>>> On 01/30/2014 03:29 PM, Florian Vaussard wrote:
>>>> The first part of this series performs serveral small cleanups
>>>> (patches 1 to 3).
>>>
>>> Thanks for your contribution. I like patches 1 and 2.
>>>
>>>> The second part introduces the 'reg-io-width' binding (already used
>>>> by some other drivers) to perform a similar job as what was done
>>>> with IORESOURCE_MEM_XXBIT on the sja1000_platform. This is needed
>>>> on my system to correctly take into account the aliasing of the
>>>> address bus.
>>>
>>> And I appreciate the improvements for the of_platform driver. However
>>> that driver was written back when it was not possible to have platform
>>> and of bindings in the same driver. So I'd like to see that the
>>> of_platform driver gets merged into the platform driver.
>>>
>>
>> Fine. Is an incremental patch on top of this series ok for you ?
> 
> I'd rather see patches 1 and 2 you have already posted, then probably a
> modernization patch which converts the platform driver to use devm_ and
> friends. Then a patch adding the existing of bindings [1]. This patch is
> probably quite small if you prepare the driver in the modernization
> patch properly. The last patch will add the new reg-io-width property.
> 

Ok, I will do it.

Regards,
Florian
