From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch] netpoll: allow spaces in its parameter
Date: Wed, 17 Mar 2010 14:07:57 +0800
Message-ID: <4BA071BD.5040900@redhat.com>
References: <20100317055707.5013.72217.sendpatchset@localhost.localdomain>	<20100316.225431.200776775.davem@davemloft.net>	<4BA07022.1040702@redhat.com> <20100316.225950.222623826.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100316.225950.222623826.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Cong Wang <amwang@redhat.com>
> Date: Wed, 17 Mar 2010 14:01:06 +0800
> 
>> The problem is that the dst port is 0 when I even use:
>>
>> "netconsole=@192.168.0.1/eth0, 66666@192.168.0.2/"
>>
>> This is awful too? I don't think so...
> 
> It's very simple, don't use spaces.  Is it so difficult
> to follow this rule?
> 

No, but silently accepting it as 0 is not correct, why don't
reject it if it is not allowed?
