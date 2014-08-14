From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net] macvlan: Fix the bug when destroy macvlan dev port
Date: Thu, 14 Aug 2014 14:32:36 -0700 (PDT)
Message-ID: <20140814.143236.466435177296125156.davem@redhat.com>
References: <53EC7D8C.6060908@huawei.com>
	<CAHA+R7MarK5Jx4ZVmyAnQp-DZ6aRNi=rqd3aKBW7OnB8YWsrbQ@mail.gmail.com>
	<1408037910.6804.22.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cwang@twopensource.com, dingtianhong@huawei.com,
	jacob.e.keller@intel.com, kaber@trash.net, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40113 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932132AbaHNVcv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Aug 2014 17:32:51 -0400
In-Reply-To: <1408037910.6804.22.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 14 Aug 2014 10:38:30 -0700

> On Thu, 2014-08-14 at 09:58 -0700, Cong Wang wrote:
>> On Thu, Aug 14, 2014 at 2:12 AM, Ding Tianhong <dingtianhong@huawei.com> wrote:
>> >
>> > To fix this problem, we need to check whether the port is exist when calling
>> > macvlan_port_destroy(), do nothing if the port has been destroyed yet.
>> >
>> 
>> As I said, this will make the first call of macvlan_port_destroy()
>> free the port,
>> which was freed by the last one before.
>> 
>> Why not just revert your change? It doesn't give any benefit.
>> --
> 
> Yes please, I think patch should be reverted.

I agree, this should be reverted, I'm going to do it myself.

 
