From: Christophe Ngo Van Duc <cngovanduc@gmail.com>
Subject: Re: bnx2/5709: Strange interrupts spread
Date: Sun, 4 Jul 2010 17:36:40 -0300
Message-ID: <AANLkTillLjztYe7mmyO_LoTXavDtTd2nsaAsd22z0dG-@mail.gmail.com>
References: <AANLkTiniNNPV9ztxXHtX4np7PIZabkm0I4v5O29chf8i@mail.gmail.com>
	<1278104311.11828.12.camel@HP1>
	<AANLkTimTcqANb3HQuC1W6VHWTh0ixO1lXAmVrmP6OZy2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:55221 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757980Ab0GDUgn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Jul 2010 16:36:43 -0400
Received: by wwb24 with SMTP id 24so1435219wwb.1
        for <netdev@vger.kernel.org>; Sun, 04 Jul 2010 13:36:40 -0700 (PDT)
In-Reply-To: <AANLkTimTcqANb3HQuC1W6VHWTh0ixO1lXAmVrmP6OZy2@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Is it a requirement that the interface has an IP address for the TX
and RX hash to work?

Christophe.

On Fri, Jul 2, 2010 at 7:12 PM, Christophe Ngo Van Duc
<cngovanduc@gmail.com> wrote:
> Hi
>
> Well that's the strange thing: it is IP traffic. The only difference
> with eth0 and eth1 is that eth2 and eth3 belongs to a bridge (br0).
>
> Best Regards,
> Christophe.
>
> On 7/2/10, Michael Chan <mchan@broadcom.com> wrote:
>>
>> On Fri, 2010-07-02 at 13:33 -0700, Christophe Ngo Van Duc wrote:
>>> On eth2 (external card) all interrupts goes to CPU0
>>>
>>>
>>> =A0 =A0 =A0 =A0 =A0 =A0CPU0 =A0 =A0 =A0 CPU1 =A0 =A0 =A0 CPU2 =A0 =A0=
 =A0 CPU3 =A0 =A0 =A0 CPU4 =A0 =A0 =A0 CPU5
>>> =A0 CPU6 =A0 =A0 =A0 CPU7
>>> =A0 80: =A0 46973077 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 =
=A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
>>> =A0 =A0 =A0 0 =A0 =A0 =A0 =A0 =A00 =A0 PCI-MSI-edge =A0 =A0 =A0eth2=
-0
>>> =A0 81: =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A0=
0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
>>> =A0 =A0 =A0 0 =A0 =A0 =A0 =A0 =A00 =A0 PCI-MSI-edge =A0 =A0 =A0eth2=
-1
>>> =A0 82: =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A0=
0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
>>> =A0 =A0 =A0 0 =A0 =A0 =A0 =A0 =A00 =A0 PCI-MSI-edge =A0 =A0 =A0eth2=
-2
>>> =A0 83: =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A0=
0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
>>> =A0 =A0 =A0 0 =A0 =A0 =A0 =A0 =A00 =A0 PCI-MSI-edge =A0 =A0 =A0eth2=
-3
>>> =A0 84: =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A0=
0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
>>> =A0 =A0 =A0 0 =A0 =A0 =A0 =A0 =A00 =A0 PCI-MSI-edge =A0 =A0 =A0eth2=
-4
>>> =A0 85: =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A0=
0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
>>> =A0 =A0 =A0 0 =A0 =A0 =A0 =A0 =A00 =A0 PCI-MSI-edge =A0 =A0 =A0eth2=
-5
>>> =A0 86: =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 2445 =
=A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 37 =A0 =A0 =A0 =A0 =A00
>>> =A0 =A08463 =A0 =A0 =A0 =A0 13 =A0 PCI-MSI-edge =A0 =A0 =A0eth2-6
>>> =A0 87: =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A0=
0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
>>> =A0 =A0 =A0 0 =A0 =A0 =A0 =A0 =A00 =A0 PCI-MSI-edge =A0 =A0 =A0eth2=
-7
>>
>> Reformatted your output
>>
>>> If I understand correctly the RSS hash is used to dispatch the pack=
ets
>>> into the different queues running on the different CPU.
>>
>> It looks like most interrupts go to eth2-0, a few go to eth2-6. =A0T=
he rx
>> ring for eth2-0 is for non-IP packets. =A0The RSS hash will hash IP
>> packets and place them on eth2-1 to eth2-7. =A0eth2-0 also handles t=
x
>> interrupts for TX ring 0. =A0TX traffic is hashed by the stack.
>>
>> What kind of traffic is passing through eth2?
>>
>> Thanks.
>>
>>
>>
>
> --
> Sent from my mobile device
>
