From: Florian Vaussard <florian.vaussard@epfl.ch>
Subject: Re: [PATCH v2 4/6] can: sja1000: fuse of_platform into platform
Date: Fri, 31 Jan 2014 14:00:04 +0100
Message-ID: <52EB9E54.2020008@epfl.ch>
References: <1391164513-11529-1-git-send-email-florian.vaussard@epfl.ch> <1391164513-11529-5-git-send-email-florian.vaussard@epfl.ch> <52EB9824.2010703@pengutronix.de> <52EB9AEA.4010503@epfl.ch> <52EB9BE1.6060407@pengutronix.de> <52EB9C48.3010205@pengutronix.de>
Reply-To: florian.vaussard@epfl.ch
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Andreas Larsson <andreas@gaisler.com>
To: Marc Kleine-Budde <mkl@pengutronix.de>,
	Wolfgang Grandegger <wg@grandegger.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <52EB9C48.3010205@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 01/31/2014 01:51 PM, Marc Kleine-Budde wrote:
> On 01/31/2014 01:49 PM, Marc Kleine-Budde wrote:
>> On 01/31/2014 01:45 PM, Florian Vaussard wrote:
>>> Hello Marc,
>>>
>>> On 01/31/2014 01:33 PM, Marc Kleine-Budde wrote:
>>>> On 01/31/2014 11:35 AM, Florian Vaussard wrote:
>>>>> The OpenFirmware probe can be merged into the standard platform
>>>>> probe to leverage common code.
>>>>
>>>> Good work, as we want to replace the existing driver, I'm quite picky on
>>>> this patch, see more comments inline.
>>>>
>>>> Please don't delete of of_platform driver, yet.
>>>>
>>>
>>> Do you have any reason for not deleting of_platform? After this patch,
>>> we will have duplicated functionalities, this may be misleading for
>>> other people.
>>
>> Okay.
>> IIRC there _was_ a problem on sparc, it _should_ be fixed now, better
>> get a Tested-by from Andreas (Cc'ed).
> 

So it is ok for you if I remove of_platform, right?

> You have to use irq_of_parse_and_map() on sparc, but your patches does this.
> 

My first implementation was not using irq_of_parse_and_map(), as I do
not need it on ARM, but I suspected that other people might need it.
This is why the final code is slightly more complicated to handle both
cases.

Regards,
Florian
