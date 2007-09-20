From: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Subject: Re: [2.6.23-rc4-mm1][Bug] kernel BUG at include/linux/netdevice.h:339!
Date: Thu, 20 Sep 2007 15:08:19 +0530
Message-ID: <46F23F8B.9020108@linux.vnet.ibm.com>
References: <46EE7026.2070203@linux.vnet.ibm.com> <20070917141622.330b27b8.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from E23SMTP02.au.ibm.com ([202.81.18.163]:58361 "EHLO
	e23smtp02.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750718AbXITK3s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2007 06:29:48 -0400
In-Reply-To: <20070917141622.330b27b8.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
> On Mon, 17 Sep 2007 17:46:38 +0530
> Kamalesh Babulal <kamalesh@linux.vnet.ibm.com> wrote:
>
>   
>> Kernel Bug is hit with 2.6.23-rc4-mm1 kernel on ppc64 machine.
>>
>> kernel BUG at include/linux/netdevice.h:339!
>>     
>
> (please cc netdev@vger.kernel.org on networking-related matters)
>
> You died here:
>
> static inline void napi_complete(struct napi_struct *n)
> {
>         BUG_ON(!test_bit(NAPI_STATE_SCHED, &n->state));
>
> The NAPI changes have had a few problems and hopefully things have
> been fixed up since then.  I'll try to get rc6-mm1 out this evening,
> so please retest that?
>   
Hi Andrew,

I don't see this bug in the 2.6.23-rc6-mm1, till now.

-- 
Thanks & Regards,
Kamalesh Babulal,
Linux Technology Center,
IBM, ISTL.

