From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch] netpoll: allow spaces in its parameter
Date: Wed, 17 Mar 2010 14:01:06 +0800
Message-ID: <4BA07022.1040702@redhat.com>
References: <20100317055707.5013.72217.sendpatchset@localhost.localdomain> <20100316.225431.200776775.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100316.225431.200776775.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Amerigo Wang <amwang@redhat.com>
> Date: Wed, 17 Mar 2010 01:53:26 -0400
> 
>> It would be nice if we allow spaces in netconsole parameters,
>> otherwise we get weird results if there are spaces in it.
>>
>> After this patch, we will allow things like:
>>  "netconsole= @192.168.0.1/eth0 , 66666@192.168.0.2/".
>>
>> Signed-off-by: WANG Cong <amwang@redhat.com>
>> Cc: David Miller <davem@davemloft.net>
> 
> That kernel command line looks absolutely awful, not
> better.
> 
> Sorry I'm not applying this.

The problem is that the dst port is 0 when I even use:

"netconsole=@192.168.0.1/eth0, 66666@192.168.0.2/"

This is awful too? I don't think so...
