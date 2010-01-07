From: David Daney <ddaney@caviumnetworks.com>
Subject: Re: [PATCH 1/7] MIPS: Octeon: Fix EIO handling.
Date: Thu, 07 Jan 2010 12:52:07 -0800
Message-ID: <4B464977.2090801@caviumnetworks.com>
References: <4B463005.8060505@caviumnetworks.com> <1262891106-32146-1-git-send-email-ddaney@caviumnetworks.com> <4B4645EE.5050302@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ralf@linux-mips.org, linux-mips@linux-mips.org,
	netdev@vger.kernel.org, gregkh@suse.de
To: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.caviumnetworks.com ([12.108.191.235]:1838 "EHLO
	mail3.caviumnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754002Ab0AGU5k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 15:57:40 -0500
In-Reply-To: <4B4645EE.5050302@ru.mvista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sergei Shtylyov wrote:
> Hello.
> 
> David Daney wrote:
> 
>> If an interrupt handler disables interrupts, the EOI function will
>> just reenable them.  This will put us in an endless loop when the
>> upcoming Ethernet driver patches are applied.
>>
>> Only reenable the interrupt on EOI if it is not IRQ_DISABLED.  This
>> requires that the EIO function be separate from the ENABLE function.
>> We also rename the ACK functions to correspond with their function.
>>
>> Signed-off-by: David Daney <ddaney@caviumnetworks.com>
>>   
> 
>   I guess the subject should read "EIO", not "EIO"...
> 

Indeed.  The compiler didn't catch that one.

Perhaps Ralf can fix it if he merges it, otherwise I can resubmit with 
corrected spelling.

David Daney

