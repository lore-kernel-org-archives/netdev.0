From: Yonghong Song <yhs@fb.com>
Subject: Re: [PATCH] samples/bpf: fix a build problem
Date: Thu, 22 Jun 2017 08:39:18 -0700
Message-ID: <9b65813c-62ef-9933-7949-0ae6ca30695b@fb.com>
References: <20170621204827.3259191-1-yhs@fb.com>
 <20170622.113602.1678719803845495653.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <ast@fb.com>, <daniel@iogearbox.net>, <netdev@vger.kernel.org>,
        <kernel-team@fb.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:48083 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752128AbdFVPjn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2017 11:39:43 -0400
In-Reply-To: <20170622.113602.1678719803845495653.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 6/22/17 8:36 AM, David Miller wrote:
> From: Yonghong Song <yhs@fb.com>
> Date: Wed, 21 Jun 2017 13:48:27 -0700
> 
>> tracex5_kern.c build failed with the following error message:
>>    ../samples/bpf/tracex5_kern.c:12:10: fatal error: 'syscall_nrs.h' file not found
>>    #include "syscall_nrs.h"
>> The generated file syscall_nrs.h is put in build/samples/bpf directory,
>> but this directory is not in include path, hence build failed.
>>
>> The fix is to add $(obj) into the clang compilation path.
>>
>> Signed-off-by: Yonghong Song <yhs@fb.com>
> 
> Applied, thanks.
> 
> Please be clear in the future that your patch is targetting 'net-next' by
> specifying this in your subject lines:
> 
> 	[PATCH net-next] ...

Thanks, Dave. Sorry, I forgot to tag the branch name. I will make sure 
it happen in the future.

> 
> I had to figure this out by hand.
> 
> Thank you.
> 
