From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net-next 0/2] macvlan: fix the problem when mac address
 changes for passthru mode
Date: Thu, 29 May 2014 11:29:58 +0800
Message-ID: <5386A9B6.40505@huawei.com>
References: <1401106233-11320-1-git-send-email-dingtianhong@huawei.com> <53860DA5.8090407@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Vlad Yasevich <vyasevich@gmail.com>, <kaber@trash.net>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:63657 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753458AbaE2DbW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 May 2014 23:31:22 -0400
In-Reply-To: <53860DA5.8090407@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/5/29 0:24, Vlad Yasevich wrote:
> On 05/26/2014 08:10 AM, Ding Tianhong wrote:
>> Ding Tianhong (2):
>>   macvlan: don't change macvlan address alone for passthru mode
>>   macvlan: propagate lowerdev mac address changes for passthru mode
>>
>>  drivers/net/macvlan.c | 40 +++++++++++++++++++++++++++++++---------
>>  1 file changed, 31 insertions(+), 9 deletions(-)
>>
> 
> This ends up working kind-of backwards...  A user now has to know
> that passthru macvlans he has to change the lower-level mac, but
> for all others, changing the macvlan mac is ok and will work...

Yes, more rules for it, but I think a user should know it.

> 
> This also will not work if the passthru macvlan is stacked on
> something other the hw (for example: a vlan).

passthru is a special mode, will not be used for every situation.

> 
> Why not simply propagate the mac address change of the passhtru macvlan
> down to the real device?
> 
Yes, I am considering this problem for a long time, I'm not sure the macvlan should propagate the mac address change to
the real device, but your suggestion looks good to me, thanks for your advise, I will think about it and fix it.

Ding

> Thanks
> -vlad
> 
> 
