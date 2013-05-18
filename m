From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] filter: do not output bpf image address for
 security reason
Date: Fri, 17 May 2013 18:27:21 -0700 (PDT)
Message-ID: <20130517.182721.470869310914541917.davem@davemloft.net>
References: <1368833499.3301.126.camel@edumazet-glaptop>
	<1368839478.3469.70.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, dborkman@redhat.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47012 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752642Ab3ERB1W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 May 2013 21:27:22 -0400
In-Reply-To: <1368839478.3469.70.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Sat, 18 May 2013 02:11:18 +0100

> On Fri, 2013-05-17 at 16:31 -0700, Eric Dumazet wrote:
>> @@ -58,10 +58,11 @@ extern void bpf_jit_free(struct sk_filter *fp);
>>  static inline void bpf_jit_dump(unsigned int flen, unsigned int proglen,
>>  				u32 pass, void *image)
>>  {
>> -	pr_err("flen=%u proglen=%u pass=%u image=%p\n",
>> -	       flen, proglen, pass, image);
>> +	/* Do not output address (image) for security reason */
>> +	pr_err("flen=%u proglen=%u pass=%u image=10\n",
> 
> Not "%pK"?

Yes, that's the acceptable way to deal with this issue.
