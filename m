From: Kazunori Miyazawa <kazunori@miyazawa.org>
Subject: Re: [PATCH][IPv6] separation xfrm_lookup from ip6_dst_lookup
Date: Tue, 03 Aug 2004 18:21:10 +0900
Sender: netdev-bounce@oss.sgi.com
Message-ID: <410F5906.30402@miyazawa.org>
References: <20040730171205.114f22ba.kazunori@miyazawa.org>	<20040801195135.16734846.davem@redhat.com> <20040803.020015.44364045.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, herbert@gondor.apana.org.au, netdev@oss.sgi.com,
        usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
In-Reply-To: <20040803.020015.44364045.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

YOSHIFUJI Hideaki wrote:

> In article <20040801195135.16734846.davem@redhat.com> (at Sun, 1 Aug 2004 19:51:35 -0700), "David S. Miller" <davem@redhat.com> says:
> 
> 
>>On Fri, 30 Jul 2004 17:12:05 +0900
>>Kazunori Miyazawa <kazunori@miyazawa.org> wrote:
>>
>>
>>>I consider copying flowi(fl_rt) uses too much stack at the moment.
>>>I'll re-send the fixed patch again.
>>
>>I agree, and let's defer this patch until we
>>resolve that.
> 
> 
> Is the overhead for allocating memory okay?
> Or, do we allcoate some per-cpu memory while ipv6.o initalization phase?
> (check: lock? preemption?)
> Or, will we allocate fl (and fl_rt) per sock{} (ipv6_pinfo{})?
> (ditto.)
> 

My intention is not high art, just using struct in6_addr
instead of struct flowi to store final destination.

> We have similar stack usage in other codes, and 
> I would fix them at the same time.
> 

These might be my changes. I will fix them.

> 
> Another question just for future reference: 
> how many bytes (approx.) do we accept on stack?
> 
> Note: sizeof(struct flowi) is 72 bytes (on i386)
> 
> --yoshfuji

--Kazunori Miyazawa
