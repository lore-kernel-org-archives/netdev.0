From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [net-next-2.6 PATCH] can: SJA1000: generic OF platform bus driver
Date: Fri, 22 May 2009 16:47:26 +0200
Message-ID: <4A16BAFE.7090401@grandegger.com>
References: <4A143896.7050200@grandegger.com>	<fa686aa40905212142n4a8c3caamb2f28eef036e3922@mail.gmail.com> <20090521.233123.135354184.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: grant.likely@secretlab.ca, netdev@vger.kernel.org,
	Linuxppc-dev@ozlabs.org, devicetree-discuss@ozlabs.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:55405 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756173AbZEVOr2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2009 10:47:28 -0400
In-Reply-To: <20090521.233123.135354184.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Grant Likely <grant.likely@secretlab.ca>
> Date: Thu, 21 May 2009 22:42:07 -0600
> 
>> On Wed, May 20, 2009 at 11:06 AM, Wolfgang Grandegger <wg@grandegger.com> wrote:
>>> This patch adds a generic driver for SJA1000 chips on the OpenFirmware
>>> platform bus found on embedded PowerPC systems. You need a SJA1000 node
>>> definition in your flattened device tree source (DTS) file similar to:
>>>
>>>   can@3,100 {
>>>           compatible = "philips,sja1000";
>>>           reg = <3 0x100 0x80>;
>>>           clock-frequency = <8000000>;
>>>           cdr-reg = <0x48>;
>>>           ocr-reg = <0x0a>;
>>>           interrupts = <2 0>;
>>>           interrupt-parent = <&mpic>;
>>>   };
>> This new binding must be documented in Documentation/powerpc/dts-bindings
> 
> Wolfgang, please add this documentation and resubmit your patch.
> Thanks!

I just sent out v2 incuding the missing documentation.

Thanks,

Wolfgang.
