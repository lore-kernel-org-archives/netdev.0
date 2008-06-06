From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: Re: [PATCH] forcedeth: msi interrupts
Date: Fri, 06 Jun 2008 14:04:05 -0400
Message-ID: <48497C15.4090505@nvidia.com>
References: <4845AEE2.1090905@nvidia.com>	<20080604151854.4a6f22b8.akpm@linux-foundation.org>	<484970B4.6080500@nvidia.com> <20080606131928.592fa23c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, manfred@colorfullife.com,
	akpm@linuxfoundation.org, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate03.nvidia.com ([216.228.112.145]:19604 "EHLO
	hqemgate03.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756330AbYFFVEG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2008 17:04:06 -0400
In-Reply-To: <20080606131928.592fa23c.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Andrew Morton wrote:
> On Fri, 06 Jun 2008 13:15:32 -0400
> Ayaz Abdulla <aabdulla@nvidia.com> wrote:
> 
> 
>>Andrew Morton wrote:
>>
>>>On Tue, 03 Jun 2008 16:51:46 -0400
>>>Ayaz Abdulla <aabdulla@nvidia.com> wrote:
>>>
>>> > This patch adds a workaround for lost MSI interrupts. There is a race
>>> > condition in the HW in which future interrupts could be missed. The
>>> > workaround is to toggle the MSI irq mask.
>>> >
>>>
>>>Do you think this is a 2.6.26 thing?
>>
>>It is by HW design, not related to the kernel.
> 
> 
> Sorry, what I meant was: do you believe that this patch should be in
> 2.6.26?
Yes, it should be treated as a critical fix.

-----------------------------------------------------------------------------------
This email message is for the sole use of the intended recipient(s) and may contain
confidential information.  Any unauthorized review, use, disclosure or distribution
is prohibited.  If you are not the intended recipient, please contact the sender by
reply email and destroy all copies of the original message.
-----------------------------------------------------------------------------------
