From: Sander Eikelenboom <linux@eikelenboom.it>
Subject: Re: [Xen-devel] [PATCH V8 net-next 0/6] xen-net{back, front}: Multiple transmit and receive queues
Date: Wed, 14 May 2014 20:37:19 +0200
Message-ID: <1296806729.20140514203719@eikelenboom.it>
References: <1400075550-4580-1-git-send-email-andrew.bennieston@citrix.com> <526369072.20140514160923@eikelenboom.it> <20140514141347.GR6332@zion.uk.xensource.com> <53739757.5060905@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Wei Liu <wei.liu2@citrix.com>, xen-devel@lists.xenproject.org,
	<davem@davemloft.net>, <ian.campbell@citrix.com>,
	<netdev@vger.kernel.org>, <paul.durrant@citrix.com>,
	<david.vrabel@citrix.com>, <zoltan.kiss@citrix.com>
To: Andrew Bennieston <andrew.bennieston@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vserver.eikelenboom.it ([84.200.39.61]:46492 "EHLO
	smtp.eikelenboom.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750702AbaENShW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 14:37:22 -0400
In-Reply-To: <53739757.5060905@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Wednesday, May 14, 2014, 6:18:31 PM, you wrote:

> On 14/05/14 15:13, Wei Liu wrote:
>> On Wed, May 14, 2014 at 04:09:23PM +0200, Sander Eikelenboom wrote:
>>>
>>> Wednesday, May 14, 2014, 3:52:24 PM, you wrote:
>>>
>>>> This patch series implements multiple transmit and receive queues (i.e.
>>>> multiple shared rings) for the xen virtual network interfaces.
>>>
>>>> The series is split up as follows:
>>>>   - Patch 1 brings the 'grant_copy_op' array back into struct xenvif, in
>>>>     preparation for multi-queue support. See the patch itself for more details.
>>>> - Patches 2 and 4 factor out the queue-specific data for netback and
>>>>    netfront respectively, and modify the rest of the code to use these
>>>>    as appropriate.
>>>> - Patches 3 and 5 introduce new XenStore keys to negotiate and use
>>>>    multiple shared rings and event channels, and code to connect these
>>>>    as appropriate.
>>>> - Patch 6 documents the XenStore keys required for the new feature
>>>>    in include/xen/interface/io/netif.h
>>>
>>>> All other transmit and receive processing remains unchanged, i.e. there
>>>> is a kthread per queue and a NAPI context per queue.
>>>
>>>> The performance of these patches has been analysed in detail, with
>>>> results available at:
>>>
>>> <snip>
>>>
>>> Would it be possible to also put these somewhere in a tree (or branch of the
>>> xen-tree), so it is more easy to pull and test ?
>>>
>>
>> I cannot speak for Andrew. FWIW you can save this thread and use 'git
>> am' to apply them to 'net-next'.
>>
>> Wei.

> I don't currently have a public-facing git repo for this. If you'd 
> prefer I can send you the patches directly in a tarball, which you may 
> be able to apply more easily than grabbing them from email threads?

Got the patches from the thread .. but as i expected they interfere with 
Zoltan's v3 fix for 3.15.

> - Andrew
>>
>>> --
>>> Sander
>>>
>>>> --
>>>> Andrew J. Bennieston
>>>
>>>
