From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH][BNX2]: Disable MSI on 5706 if AMD 8132 bridge is present
Date: Fri, 29 Sep 2006 19:15:14 -0400
Message-ID: <451DA902.7030409@garzik.org>
References: <1159565963.3741.23.camel@rh4>	<20060929.154917.125894679.davem@davemloft.net>	<451DA57F.60609@garzik.org> <20060929.160807.28788865.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:7618 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1750927AbWI2XPR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2006 19:15:17 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060929.160807.28788865.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Jeff Garzik <jeff@garzik.org>
> Date: Fri, 29 Sep 2006 19:00:15 -0400
> 
>> The patch and description provided no information about whether or not 
>> it would be better to blacklist 8132 globally, as we have already done 
>> with the 8131.
> 
> It absolutely was not vague, it gave an explicit description of what
> the problem was, down to the transaction type being used by 5706 and
> what the stated rules are in the PCI spec, and it also gave a clear
> indication that the 5706 was in the wrong and that this was believed
> to be a unique situation.

It was completely vague as to why this incompatibility was specific to 
the 5706, when -- as the description noted -- the behavior is legal.

Re-read the patch.  At no time does it say 5706 was in the wrong.

	Jeff



