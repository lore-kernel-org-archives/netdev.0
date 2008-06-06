From: Andy Fleming <afleming@freescale.com>
Subject: Re: phylib interrupt question
Date: Fri, 6 Jun 2008 12:19:02 -0500
Message-ID: <8FE9058F-AE56-40FF-A91F-125C18949D83@freescale.com>
References: <OF401D8BC0.37350235-ONC1257460.005643D3-80257460.00589565@smsc.com> <4B4372CF-7AE3-40B2-980D-4D65637E7382@freescale.com>
Mime-Version: 1.0 (Apple Message framework v924)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: steve.glendinning@smsc.com, netdev@vger.kernel.org
To: Andy Fleming <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw01.freescale.net ([192.88.158.102]:51835 "EHLO
	az33egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753804AbYFFRTS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2008 13:19:18 -0400
In-Reply-To: <4B4372CF-7AE3-40B2-980D-4D65637E7382@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Jun 6, 2008, at 12:11, Andy Fleming wrote:

>
> On Jun 6, 2008, at 11:07, steve.glendinning@smsc.com wrote:
>
>> Hi everybody,
>>
>> I'm converting an ethernet driver to use phylib, and I have an  
>> interrupt
>> question.  My device is an integrated mac/phy, with the option to  
>> disable
>> the internal phy and use an external phy instead.  I've succesfully  
>> used
>> phylib in polling mode, but I'd like to convert this to be
>> interrupt-driven if possible.
>>
>> When using the internal phy, it can raise interrupts via the mac (by
>> setting a "phy interrupt" bit in the mac's interrupt status  
>> register).  Is
>> there a way of signalling this phy interrupt to phylib from my mac
>> driver's isr?  Phylib seems to want to connect to a real irq?
>
> Hm.  Looks like one of the features of Phylib got accidentally  
> dropped.  However, it's a simple 2-line fix which I'm about to submit.


D'oh, I'm totally wrong about that being a bug.  Both of the places  
that check phydev->irq != PHY_POLL are valid.  Good news is: that  
means you don't need to wait for a patch!

Andy
