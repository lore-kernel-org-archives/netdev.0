From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.6.11 3/8] tg3: Add msi support for 5750 C0
Date: Tue, 22 Mar 2005 19:28:41 -0500
Message-ID: <4240B839.6090604@pobox.com>
References: <B1508D50A0692F42B217C22C02D84972020F3E31@NT-IRVA-0741.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
To: Michael Chan <mchan@broadcom.com>
In-Reply-To: <B1508D50A0692F42B217C22C02D84972020F3E31@NT-IRVA-0741.brcm.ad.broadcom.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Michael Chan wrote:
> "Jeff Garzik" wrote:
> 
> 
>>I would prefer that a new 'static inline' function was created, 
>>containing the core interrupt handler code.
>>
>>This avoids the code duplication you have in this patch, in 
>>new function 
>>tg3_msi().
>>
>>	Jeff
>>
> 
> 
> There are enough subtle differences between tg3_interrupt() and tg3_msi()
> that makes it impractical to create a core inline function to be shared by
> the two. To share a meaningful chunk of the code, it will have to check for
> MSI mode and skip some of the register reads. The reason I created tg3_msi()
> was to avoid all conditionals.

After reviewing the existing tg3.c code again, I agree.  Objection 
withdrawn.

	Jeff
