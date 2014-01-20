From: Wang Weidong <wangweidong1@huawei.com>
Subject: Re: [PATCH net-next 0/2] sctp: some small clean ups
Date: Mon, 20 Jan 2014 20:06:15 +0800
Message-ID: <52DD1137.8040502@huawei.com>
References: <1390217247-9408-1-git-send-email-wangweidong1@huawei.com> <52DD0A62.9050807@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <nhorman@tuxdriver.com>, <davem@davemloft.net>,
	<vyasevich@gmail.com>, <netdev@vger.kernel.org>,
	<linux-sctp@vger.kernel.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:55466 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751916AbaATMGt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jan 2014 07:06:49 -0500
In-Reply-To: <52DD0A62.9050807@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/1/20 19:37, Daniel Borkmann wrote:
> On 01/20/2014 12:27 PM, Wang Weidong wrote:
>> We have the macros in sctp.h, so use them for coding accordance
>> in sctp.
> 
> Thanks for doing this Wang.
> 
> I am actually wondering why we have these macro locking wrappers

Here, I didn't found any description about it. In v2.6.12-rc2, the sctp
use these macros.

> and not use these functions directly? Hm, any reasons? Maybe we
> should rather go in the other direction with this?
> 

Yeah. 
Should I do the other direction for clean ups now?

Regards,
Wang

>> Wang Weidong (2):
>>    sctp: use sctp_local_bh_{disable|enable} instead
>>      local_bh_{disable|enable}
>>    sctp: use sctp_read_[un]lock instead of read_[un]lock
>>
>>   net/sctp/endpointola.c   |  4 ++--
>>   net/sctp/input.c         | 10 +++++-----
>>   net/sctp/proc.c          | 12 ++++++------
>>   net/sctp/sm_make_chunk.c |  8 ++++----
>>   net/sctp/socket.c        |  8 ++++----
>>   5 files changed, 21 insertions(+), 21 deletions(-)
>>
> 
> 
