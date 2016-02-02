From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH iproute2] tc: fix compilation with old gcc (< 4.6) (bis)
Date: Tue, 02 Feb 2016 10:08:38 +0100
Message-ID: <56B07216.5080604@iogearbox.net>
References: <1f5ba49033cd4c55a0d0005487efde39@HQ1WP-EXMB11.corp.brocade.com> <20160202155157.2f492bfd@samsung9>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"julien.floret@6wind.com" <julien.floret@6wind.com>
To: Stephen Hemminger <shemming@brocade.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:45330 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753962AbcBBJIl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 04:08:41 -0500
In-Reply-To: <20160202155157.2f492bfd@samsung9>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/02/2016 05:51 AM, Stephen Hemminger wrote:
> On Tue, 19 Jan 2016 11:01:45 +0000
> Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:
>
>> diff --git a/tc/tc_bpf.c b/tc/tc_bpf.c
>> index 42c8841869f5..219ffa582c1a 100644
>> --- a/tc/tc_bpf.c
>> +++ b/tc/tc_bpf.c
>> @@ -49,6 +49,10 @@
>>   #include "tc_util.h"
>>   #include "tc_bpf.h"
>>
>> +#ifndef AF_ALG
>> +#define AF_ALG 38
>> +#endif
>
> Why is this here? AF_ALG is not used anywhere in this code.

It is used, this patch is fine as-is.

Thanks!

> Please remove it and resubmit
