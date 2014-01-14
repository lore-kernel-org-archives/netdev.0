From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH RESEND net-next v2 0/3] bonding: fix primary problem for
 bonding
Date: Tue, 14 Jan 2014 18:26:12 +0800
Message-ID: <52D510C4.9020809@huawei.com>
References: <52D4FE82.8020507@huawei.com> <20140114093720.GA20066@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>, Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:50977 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751566AbaANKbG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 05:31:06 -0500
In-Reply-To: <20140114093720.GA20066@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/1/14 17:37, Veaceslav Falico wrote:
> On Tue, Jan 14, 2014 at 05:08:18PM +0800, Ding Tianhong wrote:
>> If the slave's name changed, and the bond params primary is exist,
>> the bond should deal with the situation in two ways:
>>
>> 1) If the slave was the primary slave yet, clean the primary slave
>>   and reselect active slave.
>> 2) If the slave's new name is as same as bond primary, set the slave
>>   as primary slave and reselect active slave.
>>
>> If the new primary is not matching any slave in the bond, the bond should
>> record it to params, clean the primary slave and select a new active slave.
>>
>> Update bonding.txt for primary description.
> 
> You didn't even take into accoung my previous messages.
> 
> Nacked-by: Veaceslav Falico <vfalico@redhat.com>
> 

Yes, miss it, sorry about that, add and resend later.



>>
>> Ding Tianhong (3):
>>  bonding: update the primary slave when changing slave's name
>>  bonding: clean the primary slave if there is no slave matching new
>>    primary
>>  bonding: update bonding.txt for primary description.
>>
>> Documentation/networking/bonding.txt |  3 ++-
>> drivers/net/bonding/bond_main.c      | 24 ++++++++++++++++++++++--
>> drivers/net/bonding/bond_options.c   |  6 ++++++
>> 3 files changed, 30 insertions(+), 3 deletions(-)
>>
>> -- 
>> 1.8.0
>>
>>
>>
> 
> 
