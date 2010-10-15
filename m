From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] connector: remove lazy workqueue creation
Date: Fri, 15 Oct 2010 15:38:13 +0200
Message-ID: <4CB85945.8040801@kernel.org>
References: <4CB8250A.7040902@kernel.org> <20101015130604.GA1751@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:59994 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754659Ab0JONiU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Oct 2010 09:38:20 -0400
In-Reply-To: <20101015130604.GA1751@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On 10/15/2010 03:06 PM, Evgeniy Polyakov wrote:
> On Fri, Oct 15, 2010 at 11:55:22AM +0200, Tejun Heo (tj@kernel.org) wrote:
>> Commit 1a5645bc (connector: create connector workqueue only while
>> needed once) implements lazy workqueue creation for connector
>> workqueue.  With cmwq now in place, lazy workqueue creation doesn't
>> make much sense while adding a lot of complexity.  Remove it and
>> allocate an ordered workqueue during initialization.
>>
>> This also removes a call to flush_scheduled_work() which is deprecated
>> and scheduled to be removed.
> 
> Looks good, thank you.
> Ack.

Are you gonna route this patch?  If not, I can route it through
workqueue tree.

Thank you.

-- 
tejun
