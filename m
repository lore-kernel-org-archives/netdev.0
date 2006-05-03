From: "Caitlin Bestler" <caitlinb@broadcom.com>
Subject: RE: VJ Channel API - driver level (PATCH)
Date: Wed, 3 May 2006 13:40:06 -0700
Message-ID: <54AD0F12E08D1541B826BE97C98F99F149E8D5@NT-SJCA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Leonid.Grossman@neterion.com, shemminger@osdl.org,
	alex@neterion.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:41232 "EHLO
	MMS3.broadcom.com") by vger.kernel.org with ESMTP id S1750869AbWECUkU convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 May 2006 16:40:20 -0400
Content-class: urn:content-classes:message
To: "David S. Miller" <davem@davemloft.net>, johnpol@2ka.mipt.ru
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
> Date: Wed, 3 May 2006 22:07:40 +0400
> 
>> On Wed, May 03, 2006 at 08:56:23AM -0700, Caitlin Bestler
> (caitlinb@broadcom.com) wrote:
>>>> I'd expect high end NIC ASICs to implement rx steering based upon
>>>> some sort of hash (for load balancing), as well as explicit "1:1"
>>>> steering between a sw channel and a hw channel. Both options for
>>>> channel configuration are present in the driver interface.
>>>> If netfilter assists can be done in hardware, I agree the driver
>>>> interface will need to add support for these - otherwise,
>>>> netfilter processing will stay above the driver.
>>>> 
>>>> 
>>> 
>>> Even if the hardware cannot fully implement netfilter rules there is
>>> still value in having an interface that documents exactly how much
>>> filtering a given piece of hardware can do.
>>> There is no point in having the kernel repeat packet classifications
>>> that have already been done by the NIC.
>> 
>> Please do not suppose that vj channel must rely on underlaying
>> hardware. 
> 
> I am not.  I am just saying that it is futile to build
> hardware that cannot handle netfilter at least to some
> extent, because this will result in HW net channels being
> disabled for %99 of real users which makes the hardware just a waste.

Or netfilters being disabled, which would be just as bad or worse.
The kernel and hardware need to co-operate so that users are not
asked to make artificial choices between performance and security.



