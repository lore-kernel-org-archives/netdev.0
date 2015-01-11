From: Richard Weinberger <richard@nod.at>
Subject: Re: [PATCH 3/3] x_tables: Factor out 16bit aligment ifname_compare()
Date: Sun, 11 Jan 2015 22:02:21 +0100
Message-ID: <54B2E4DD.90200@nod.at>
References: <1421009571-5279-1-git-send-email-richard@nod.at>	 <1421009571-5279-4-git-send-email-richard@nod.at> <1421009969.9233.5.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, coreteam@netfilter.org,
	netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, bhutchings@solarflare.com,
	john.fastabend@gmail.com, herbert@gondor.apana.org.au,
	vyasevic@redhat.com, jiri@resnulli.us, vfalico@gmail.com,
	therbert@google.com, edumazet@google.com, yoshfuji@linux-ipv6.org,
	jmorris@namei.org, kuznet@ms2.inr.ac.ru, kadlec@blackhole.kfki.hu,
	kaber@trash.net, pablo@netfilter.org, kay@vrfy.org,
	stephen@networkplumber.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1421009969.9233.5.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 11.01.2015 um 21:59 schrieb Joe Perches:
> On Sun, 2015-01-11 at 21:52 +0100, Richard Weinberger wrote:
>> arp_tables.c has a 16bit aligment ifname_compare(), factor
>> it out to use it for all tables.
> []
>> diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilter/x_tables.h
> []
>> @@ -331,14 +331,15 @@ static inline void xt_write_recseq_end(unsigned int addend)
>>  /*
>>   * This helper is performance critical and must be inlined
>>   */
>> -static inline unsigned long ifname_compare_aligned(const char *_a,
>> -						   const char *_b,
>> -						   const char *_mask)
>> +static inline unsigned long ifname_compare(const char *_a,
>> +					   const char *_b,
>> +					   const char *_mask)
> 
> Perhaps this would be better as bool ifname_compare

Let's discuss the whole concept first, then we can go to bikeshedding mode.

Thanks,
//richard
