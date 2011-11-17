From: Rick Jones <rick.jones2@hp.com>
Subject: Re: under-performing bonded interfaces
Date: Wed, 16 Nov 2011 17:45:34 -0800
Message-ID: <4EC4673E.4060605@hp.com>
References: <CANj2EbeMRzicixHwrKpCQ3mMqQ1qbyjbRCxpW+CmVRREAhyeRQ@mail.gmail.com> <4EC44ECB.4050201@candelatech.com> <CANj2EbfrtbysEbj+gMa+fOhWo0EWjBXVyGkw8WyiPAV9nPduuQ@mail.gmail.com> <1321491449.2709.90.camel@bwh-desktop> <CANj2Ebdd89=Fk6i4e4Txsb3ANuzz-x4t+tT6CAnWDNZe0zvx9g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Ben Greear <greearb@candelatech.com>, netdev@vger.kernel.org
To: Simon Chen <simonchennj@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0185.atlanta.hp.com ([15.193.32.62]:18526 "EHLO
	g6t0185.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752620Ab1KQBpi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2011 20:45:38 -0500
In-Reply-To: <CANj2Ebdd89=Fk6i4e4Txsb3ANuzz-x4t+tT6CAnWDNZe0zvx9g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/16/2011 05:38 PM, Simon Chen wrote:
> Thanks, Ben. That's good discovery...
>
> Are you saying that both 10G NICs are on the same PCIe x4 slot, so
> that they're subject to the 12G throughput bottleneck?
>
> I'm gonna verify this with the hardware vendor...

Look at the PCI addresses - they are:

0000:03:00.0
0000:03:00.1

The numbers after the "dot" are PCI function numbers, meaning that both 
*ports* of the dual-port NIC are in the same PCIe slot, in this case a 
x4 slot.

more generally, the format is:

DDDD:BB:SS.F

D == DOMAIN; B == BUS; S == SLOT; F == FUNCTION.  If domain, bus and 
slot are the same, but functions differ, the "devices" are in the same slot.

rick jones
