From: Ben Greear <greearb@candelatech.com>
Subject: Re: Testing server performance
Date: Mon, 12 Dec 2011 09:32:22 -0800
Message-ID: <4EE63AA6.2090402@candelatech.com>
References: <CAFdo_mW0sKSZp3L75BOPBN1Sa+ZQ8WiBRC98eFLM5BaxCVrpJQ@mail.gmail.com> <4EE242DF.2000609@candelatech.com> <CAFdo_mU-CHP0tyScF_ZmZJHeSuC6MEgASTZ+h2JWyumTn=sqqw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: igorm@etf.rs
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:35539 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753520Ab1LLRc2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2011 12:32:28 -0500
In-Reply-To: <CAFdo_mU-CHP0tyScF_ZmZJHeSuC6MEgASTZ+h2JWyumTn=sqqw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/12/2011 01:24 AM, Igor Maravi=C4=87 wrote:
>> Check the bus speed and width on your NICs.  dmesg usually shows thi=
s
>> info when the interfaces are first detected.
>>
>> If you can, try some Intel NICs..they will usually run wire speed
>> if the motherboard is reasonably fast.
>>
>> Thanks,
>> Ben
>
> Thanks for the advice.
> I' ll see if I can find some Intel NICs.
>
> NIC's specs says that they support 32-bit 33/66MHz clock speed PCI Bu=
s
> Master operation.
> Should that be enough?

No, probably not.  Your motherboard may only be 32/32mhz as well?

You really need pci-e (or high-end pci-x) for good 1Gbps performance.

On any modern system, use pci-e nics if you can.

Thanks,
Ben

>
> I'll see what dmesg showed tomorow, because I'm not at my computer cu=
rrently.
> BR
> Igor
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
