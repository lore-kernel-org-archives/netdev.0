From: Yang Yingliang <yangyingliang@huawei.com>
Subject: Re: [PATCH iproute2] fq: don't allow set options to zero
Date: Mon, 12 May 2014 14:51:14 +0800
Message-ID: <53706F62.2050603@huawei.com>
References: <1399868319-2184-1-git-send-email-yangyingliang@huawei.com> <1399874336.7973.17.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <stephen@networkplumber.org>, <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:32749 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751645AbaELGv2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2014 02:51:28 -0400
In-Reply-To: <1399874336.7973.17.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/5/12 13:58, Eric Dumazet wrote:
> On Mon, 2014-05-12 at 12:18 +0800, Yang Yingliang wrote:
>> Now options of fair queue can be zero but cannot be (~0U).
>> Zero is useless, so don't allow set the options to zero.
>> Also, maxrate cannot be reset to unlimited because it
>> cannot be (~0U).
>>
>> Cc: Eric Dumazet <edumazet@google.com>
>> Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
>> ---
>>  tc/q_fq.c | 24 ++++++++++++------------
>>  1 file changed, 12 insertions(+), 12 deletions(-)
> 
> No, you are changing behavior for existing scripts.
> 
> If you really want to fix these cases, you need to do it properly.
> 

Do you mean allow options set to zero changing the behavior ?

Regards,
Yang
