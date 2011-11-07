From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH 6/7] fsl_pmc: Add API to enable device as wakeup event
 source
Date: Mon, 7 Nov 2011 12:41:27 -0600
Message-ID: <4EB82657.4090204@freescale.com>
References: <1320410349-14600-1-git-send-email-chenhui.zhao@freescale.com> <CAOZdJXXB9zJWqC+kPq7ZDdzePtp8XNBnWcf5UmE8Ye50U-G7Dg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Zhao Chenhui-B35336 <B35336@freescale.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	Li Yang-R58472 <r58472@freescale.com>
To: Tabi Timur-B04825 <B04825@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe005.messaging.microsoft.com ([216.32.181.185]:30348
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751831Ab1KGSmI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2011 13:42:08 -0500
In-Reply-To: <CAOZdJXXB9zJWqC+kPq7ZDdzePtp8XNBnWcf5UmE8Ye50U-G7Dg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/04/2011 07:08 PM, Tabi Timur-B04825 wrote:
> On Fri, Nov 4, 2011 at 7:39 AM, Zhao Chenhui <chenhui.zhao@freescale.com> wrote:
>> +       /* clear to enable clock in low power mode */
>> +       if (enable)
>> +               clrbits32(&pmc_regs->pmcdr, *pmcdr_mask);
>> +       else
>> +               setbits32(&pmc_regs->pmcdr, *pmcdr_mask);
> 
> You need to use be32_to_cpup() when dereferencing a pointer to a
> device tree property.

Or just use of_property_read_u32().

-Scott
