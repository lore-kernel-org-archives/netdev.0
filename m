From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/5] rds: stop including asm-generic/bitops/le.h
 directly
Date: Fri, 08 Oct 2010 11:59:00 -0700 (PDT)
Message-ID: <20101008.115900.245387221.davem@davemloft.net>
References: <1286532193-29814-1-git-send-email-akinobu.mita@gmail.com>
	<1286532193-29814-4-git-send-email-akinobu.mita@gmail.com>
	<4CAF693B.9030706@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akinobu.mita@gmail.com, linux-kernel@vger.kernel.org,
	linux-arch@vger.kernel.org, arnd@arndb.de,
	akpm@linux-foundation.org, rds-devel@oss.oracle.com,
	netdev@vger.kernel.org
To: andy.grover@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4CAF693B.9030706@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andy Grover <andy.grover@oracle.com>
Date: Fri, 08 Oct 2010 11:55:55 -0700

> On 10/08/2010 03:03 AM, Akinobu Mita wrote:
>> asm-generic/bitops/le.h is only intended to be included directly from
>> asm-generic/bitops/ext2-non-atomic.h or asm-generic/bitops/minix-le.h
>> which implements generic ext2 or minix bit operations.
>>
>> This stops including asm-generic/bitops/le.h directly and use ext2
>> non-atomic bit operations instead.
>>
>> An alternative approach is introducing little endian bit operations
>> in linux/bitops.h. But it needs to touch more files than this change
>> does.
> 
>> -	generic___set_le_bit(off, (void *)map->m_page_addrs[i]);
>> +	ext2_set_bit(off, (void *)map->m_page_addrs[i]);
> 
> I'd like a solution that doesn't have rds calling a function starting
> with ext2_. Seems wrong.

Agreed.
