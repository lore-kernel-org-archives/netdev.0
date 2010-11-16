From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [net-2.6 PATCH] nete zero kobject in rx_queue_release
Date: Mon, 15 Nov 2010 18:06:52 -0800
Message-ID: <4CE1E73C.1000105@intel.com>
References: <20101111201341.4418.16400.stgit@jf-dev1-dcblab>	<20101112.130824.68146775.davem@davemloft.net>	<AANLkTi=1Xzne6HZN-w_3RTeUmqtjGpHPfW211SKvW17w@mail.gmail.com> <20101114.151529.183053743.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "therbert@google.com" <therbert@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:35715 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759099Ab0KPCHF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Nov 2010 21:07:05 -0500
In-Reply-To: <20101114.151529.183053743.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/14/2010 3:15 PM, David Miller wrote:
> From: Tom Herbert <therbert@google.com>
> Date: Sun, 14 Nov 2010 14:40:00 -0800
> 
>>> So we'll need something like:
>>>
>>>        if (atomic_dec_and_test(&first->count))
>>>                kfree(first);
>>>        else
>>>                /* clear everything except queue->first */
>>>
>>
>> The patches to get rid of the separate refcnt should obviate this
>> complexity.  Could just clear the queue in kobject release.
> 
> True but we'll still need a patch for older kernels.

OK Thanks. I'll have a stable patch and a net-2.6 patch soon.

-- John
