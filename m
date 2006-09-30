From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH][BNX2]: Disable MSI on 5706 if AMD 8132 bridge is present
Date: Fri, 29 Sep 2006 20:38:07 -0400
Message-ID: <451DBC6F.2010901@garzik.org>
References: <451DA57F.60609@garzik.org>	<20060929.160807.28788865.davem@davemloft.net>	<451DA902.7030409@garzik.org> <20060929.162958.102576741.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:6597 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1422630AbWI3AiL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2006 20:38:11 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060929.162958.102576741.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Jeff Garzik <jeff@garzik.org>
> Date: Fri, 29 Sep 2006 19:15:14 -0400
> 
>> It was completely vague as to why this incompatibility was specific to 
>> the 5706, when -- as the description noted -- the behavior is legal.
>>
>> Re-read the patch.  At no time does it say 5706 was in the wrong.
> 
> True, but it does indicate that using a masked 64-bit transaction
> for MSI instead of a true 32-bit one is considered to be quite rare.
> 
> Do you wish to put a table of all devices that do this, and at PCI
> quirk time disable PCI for everyone on the AMD chipset if even one
> such device is found in the device?
> 
> That doesn't make any sense to me.

David, rejoin reality.  You are either arguing with a fictionalized Jeff 
Garzik in your head, or constructing a classical strawman.

Let me say it for the cheap seats:  AT NO TIME DID I PROPOSE ACTION OF 
ANY KIND.  I sought clarification.  Information.

So, please, quit making stupid and incorrect assumptions about my 
intentions.  If this is indeed a rare behavior and most other MSI cases 
work with the 8132, then the patch is quite reasonable.  I see no reason 
to NAK the patch.

	Jeff


