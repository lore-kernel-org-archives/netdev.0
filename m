From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH 7/7] gianfar: add support for wake-on-packet
Date: Tue, 8 Nov 2011 07:42:09 -0600
Message-ID: <5D4A38A7-B662-40CC-97AB-9E2A64531776@kernel.crashing.org>
References: <1320410403-14639-1-git-send-email-chenhui.zhao@freescale.com> <4EB45515.6060405@freescale.com> <3F607A5180246847A760FD34122A1E052BC9C7@039-SN1MPN1-004.039d.mgd.msft.net>
Mime-Version: 1.0 (Apple Message framework v1251.1)
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8BIT
Cc: Wood Scott-B07421 <B07421@freescale.com>,
	Zhao Chenhui-B35336 <B35336@freescale.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	Fleming Andy-AFLEMING <afleming@freescale.com>
To: Li Yang-R58472 <r58472@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:50571 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751927Ab1KHNmX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2011 08:42:23 -0500
In-Reply-To: <3F607A5180246847A760FD34122A1E052BC9C7@039-SN1MPN1-004.039d.mgd.msft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Nov 8, 2011, at 5:20 AM, Li Yang-R58472 wrote:

> 
> 
>> -----Original Message-----
>> From: linuxppc-dev-bounces+leoli=freescale.com@lists.ozlabs.org
>> [mailto:linuxppc-dev-bounces+leoli=freescale.com@lists.ozlabs.org] On
>> Behalf Of Scott Wood
>> Sent: Saturday, November 05, 2011 5:12 AM
>> To: Zhao Chenhui-B35336
>> Cc: netdev@vger.kernel.org; linuxppc-dev@lists.ozlabs.org; Fleming Andy-
>> AFLEMING
>> Subject: Re: [PATCH 7/7] gianfar: add support for wake-on-packet
>> 
>> On 11/04/2011 07:40 AM, Zhao Chenhui wrote:
>>> diff --git a/Documentation/devicetree/bindings/net/fsl-tsec-phy.txt
>> b/Documentation/devicetree/bindings/net/fsl-tsec-phy.txt
>>> index 2c6be03..543e36c 100644
>>> --- a/Documentation/devicetree/bindings/net/fsl-tsec-phy.txt
>>> +++ b/Documentation/devicetree/bindings/net/fsl-tsec-phy.txt
>>> @@ -56,6 +56,9 @@ Properties:
>>>     hardware.
>>>   - fsl,magic-packet : If present, indicates that the hardware supports
>>>     waking up via magic packet.
>>> +  - fsl,wake-on-filer : If present, indicates that the hardware
>> supports
>>> +    waking up via arp request to local ip address or unicast packet to
>>> +    local mac address.
>> 
>> Is there any way to determine this at runtime via the device's registers?
>> 
>> I think TSEC_ID2[TSEC_CFG] can be used.  The manual describes it
>> awkwardly, but it looks like 0x20 is the bit for the filer.
> 
> That bit only defines the filer feature but not wakeup on it.  Another solution is to get the capability from the fsl_pmc driver, but will make the driver a lot more complex.

I don't believe there is a way to know this from the controller itself.  We have to use device tree for it.

- k