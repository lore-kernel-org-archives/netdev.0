From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next] filter: add bpf_optimize_div()
Date: Thu, 20 Nov 2014 22:57:19 +0100
Message-ID: <546E63BF.8030000@redhat.com>
References: <1416512551-22252-1-git-send-email-kda@linux-powerpc.org> <CAMEtUuw1q_=CuZOHqd1WDd8ZE+bo-CNsbQ4rFPgRRVy7H1Q4uA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Denis Kirjanov <kda@linux-powerpc.org>,
	Network Development <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52608 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755100AbaKTV5Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Nov 2014 16:57:24 -0500
In-Reply-To: <CAMEtUuw1q_=CuZOHqd1WDd8ZE+bo-CNsbQ4rFPgRRVy7H1Q4uA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/20/2014 10:07 PM, Alexei Starovoitov wrote:
> On Thu, Nov 20, 2014 at 11:42 AM, Denis Kirjanov <kda@linux-powerpc.org> wrote:
...
>> diff --git a/include/linux/filter.h b/include/linux/filter.h
>> index ca95abd..b385637 100644
>> --- a/include/linux/filter.h
>> +++ b/include/linux/filter.h
>> +
>> +static inline int bpf_optimize_div(u32 *k)
>
> 'inline' is unnecessary

Btw, it's a header file here, so it's necessary here.

...
> In general I don't think such optimizations
> belong in kernel at all. User space should be doing this.

+1
