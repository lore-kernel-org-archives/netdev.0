From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH][BNX2]: Disable MSI on 5706 if AMD 8132 bridge is present
Date: Fri, 29 Sep 2006 19:00:15 -0400
Message-ID: <451DA57F.60609@garzik.org>
References: <1159564053.3741.19.camel@rh4>	<451D9007.6010905@garzik.org>	<1159565963.3741.23.camel@rh4> <20060929.154917.125894679.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:33473 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1030218AbWI2XAS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2006 19:00:18 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060929.154917.125894679.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: "Michael Chan" <mchan@broadcom.com>
> Date: Fri, 29 Sep 2006 14:39:23 -0700
> 
>> On Fri, 2006-09-29 at 17:28 -0400, Jeff Garzik wrote:
>>> Michael Chan wrote:
>>>> AMD believes this incompatibility is unique to the 5706, and
>>>> prefers to locally disable MSI rather than globally disabling it
>>>> using pci_msi_quirk.
>>> Why is it unique to the 5706?  Is this just a guess on AMD and 
>>> Broadcom's part?
>>>
>> I just took AMD's word for it.  It doesn't matter to me whether we
>> disable it locally or globally.  Since this is AMD's bridge, I just
>> follow their recommendation.  They probably haven't seen this issue on
>> any other devices except ours.
> 
> I really think this is a reasonable thing to do.
> 
> It's absolutely rediculious to disable MSI for every card just
> because one decided to use a masked 64-bit transaction for
> what's supposed to be a 32-bit one.
> 
> Jeff, I totally understand your knee-jerk reaction to per-device MSI
> validation checks, but in this case I find that knee-jerk reaction
> to be totally unreasonable. :-)

How it is unreasonable to clarify a completely vague description of the 
problem?

The patch and description provided no information about whether or not 
it would be better to blacklist 8132 globally, as we have already done 
with the 8131.

	Jeff



