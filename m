From: Daniel Mack <daniel@zonque.org>
Subject: Re: [PATCH v2 net-next 1/5] bpf: Refactor cgroups code in prep for
 new type
Date: Mon, 31 Oct 2016 18:00:21 +0100
Message-ID: <542e0d3e-2f57-96f9-1da1-b71e2c970395@zonque.org>
References: <1477529922-4806-1-git-send-email-dsa@cumulusnetworks.com>
 <1477529922-4806-2-git-send-email-dsa@cumulusnetworks.com>
 <20161031.125801.874510216543796824.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@fb.com, daniel@iogearbox.net,
        maheshb@google.com, tgraf@suug.ch
To: David Miller <davem@davemloft.net>, dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:47412 "EHLO mail.zonque.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S944652AbcJaRAY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 31 Oct 2016 13:00:24 -0400
In-Reply-To: <20161031.125801.874510216543796824.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/31/2016 05:58 PM, David Miller wrote:
> From: David Ahern <dsa@cumulusnetworks.com>
> Date: Wed, 26 Oct 2016 17:58:38 -0700
> 
>> diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
>> index 6b62ee9a2f78..73da296c2125 100644
>> --- a/include/uapi/linux/bpf.h
>> +++ b/include/uapi/linux/bpf.h
>> @@ -98,7 +98,7 @@ enum bpf_prog_type {
>>  	BPF_PROG_TYPE_TRACEPOINT,
>>  	BPF_PROG_TYPE_XDP,
>>  	BPF_PROG_TYPE_PERF_EVENT,
>> -	BPF_PROG_TYPE_CGROUP_SKB,
>> +	BPF_PROG_TYPE_CGROUP,
>>  };
>>  
>>  enum bpf_attach_type {
> 
> If we do this then the cgroup-bpf series should use this value rather than
> changing it after-the-fact in your series here.
> 

Yeah, I'm confused too. I changed that name in my v7 from
BPF_PROG_TYPE_CGROUP_SOCK to BPF_PROG_TYPE_CGROUP_SKB on David's (Ahern)
request. Why is it now renamed again?


Thanks,
Daniel
