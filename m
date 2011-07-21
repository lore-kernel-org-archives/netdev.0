From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] jme: Fix unmap error (Causing system
	freeze)
Date: Thu, 21 Jul 2011 15:23:31 -0700 (PDT)
Message-ID: <20110721.152331.2027457406280709611.davem@davemloft.net>
References: <1311217056-9073-1-git-send-email-cooldavid@cooldavid.org>
	<20110721193008.GC9766@sequoia.sous-sol.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jason@lambhome.org, netdev@vger.kernel.org, cooldavid@cooldavid.org,
        jason@octgsoftware.com, marcus.disi@gmail.com, arieslee@jmicron.com,
        devinchiu@jmicron.com, mschiff@gentoo.org, stable@kernel.org
To: chrisw@sous-sol.org
Return-path: <stable-bounces@linux.kernel.org>
In-Reply-To: <20110721193008.GC9766@sequoia.sous-sol.org>
List-Unsubscribe: <http://linux.kernel.org/mailman/options/stable>,
	<mailto:stable-request@linux.kernel.org?subject=unsubscribe>
List-Archive: <http://linux.kernel.org/mailman/private/stable/>
List-Post: <mailto:stable@linux.kernel.org>
List-Help: <mailto:stable-request@linux.kernel.org?subject=help>
List-Subscribe: <http://linux.kernel.org/mailman/listinfo/stable>,
	<mailto:stable-request@linux.kernel.org?subject=subscribe>
Sender: stable-bounces@linux.kernel.org
Errors-To: stable-bounces@linux.kernel.org
List-Id: netdev.vger.kernel.org

From: Chris Wright <chrisw@sous-sol.org>
Date: Thu, 21 Jul 2011 12:30:08 -0700

> * cooldavid@cooldavid.org (cooldavid@cooldavid.org) wrote:
>> From: Guo-Fu Tseng <cooldavid@cooldavid.org>
>> 
>> This patch add the missing dma_unmap().
>> Which solved the critical issue of system freeze on heavy load.
>> 
>> Michal Miroslaw's rejected patch:
>> [PATCH v2 10/46] net: jme: convert to generic DMA API
>> Pointed out the issue also, thank you Michal.
>> But the fix was incorrect. It would unmap needed address
>> when low memory.
>> 
>> Got lots of feedback from End user and Gentoo Bugzilla.
>> https://bugs.gentoo.org/show_bug.cgi?id=373109
>> Thank you all. :)
> 
> Also referred to in kernel bugzilla:
> 
> https://bugzilla.kernel.org/show_bug.cgi?id=39312
> 
>> Cc: stable@kernel.org
>> Signed-off-by: Guo-Fu Tseng <cooldavid@cooldavid.org>
> 
> Acked-by: Chris Wright <chrisw@sous-sol.org>

Applied, but it's too late for 3.0 so I'll just submit it to all
the -stable branches after 3.0-final is released.

Thanks.

_______________________________________________
stable mailing list
stable@linux.kernel.org
http://linux.kernel.org/mailman/listinfo/stable
