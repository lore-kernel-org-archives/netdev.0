From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: Re: [PATCH 4/5] rds: stop including asm-generic/bitops/le.h directly
Date: Mon, 11 Oct 2010 00:09:36 +0900
Message-ID: <AANLkTikM35ovGdikDQ6nHs6_GUDF6KTqjjEM20oymOhL@mail.gmail.com>
References: <1286532193-29814-1-git-send-email-akinobu.mita@gmail.com>
	<1286532193-29814-4-git-send-email-akinobu.mita@gmail.com>
	<4CAF693B.9030706@oracle.com>
	<20101008.115900.245387221.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: andy.grover@oracle.com, linux-kernel@vger.kernel.org,
	linux-arch@vger.kernel.org, arnd@arndb.de,
	akpm@linux-foundation.org, rds-devel@oss.oracle.com,
	netdev@vger.kernel.org, Alexander Graf <agraf@suse.de>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101008.115900.245387221.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2010/10/9 David Miller <davem@davemloft.net>:
> From: Andy Grover <andy.grover@oracle.com>
> Date: Fri, 08 Oct 2010 11:55:55 -0700
>
>> On 10/08/2010 03:03 AM, Akinobu Mita wrote:
>>> asm-generic/bitops/le.h is only intended to be included directly fr=
om
>>> asm-generic/bitops/ext2-non-atomic.h or asm-generic/bitops/minix-le=
=2Eh
>>> which implements generic ext2 or minix bit operations.
>>>
>>> This stops including asm-generic/bitops/le.h directly and use ext2
>>> non-atomic bit operations instead.
>>>
>>> An alternative approach is introducing little endian bit operations
>>> in linux/bitops.h. But it needs to touch more files than this chang=
e
>>> does.
>>
>>> - =A0 =A0generic___set_le_bit(off, (void *)map->m_page_addrs[i]);
>>> + =A0 =A0ext2_set_bit(off, (void *)map->m_page_addrs[i]);
>>
>> I'd like a solution that doesn't have rds calling a function startin=
g
>> with ext2_. Seems wrong.
>
> Agreed.

OK, I'll rewrite the patch series to take the alternative approach.
