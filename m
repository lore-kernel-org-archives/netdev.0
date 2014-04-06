From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: Tree for Apr 1 (netfilter)
Date: Sun, 06 Apr 2014 11:31:06 -0400 (EDT)
Message-ID: <20140406.113106.564835222660199498.davem@davemloft.net>
References: <533B06A7.5010900@infradead.org>
	<20140401.152203.847120817141929645.davem@davemloft.net>
	<CAMuHMdXaoUvUButpaDYQh6aj=Zm9GCS7MKFA_-h8GOo1RkOObw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rdunlap@infradead.org, sfr@canb.auug.org.au,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: geert@linux-m68k.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <CAMuHMdXaoUvUButpaDYQh6aj=Zm9GCS7MKFA_-h8GOo1RkOObw@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Sun, 6 Apr 2014 15:50:04 +0200

> On Tue, Apr 1, 2014 at 9:22 PM, David Miller <davem@davemloft.net> wrote:
>> From: Randy Dunlap <rdunlap@infradead.org>
>> Date: Tue, 01 Apr 2014 11:34:15 -0700
>>
>>> on x86_64:
>>>
>>> net/netfilter/xt_connlimit.c: In function 'connlimit_mt_check':
>>> net/netfilter/xt_connlimit.c:380:18: warning: division by zero [-Wdiv-by-zero]
>>>
>>> Maybe just use CONNLIMIT_LOCK_SLOTS instead of ARRAY_SIZE(...).
>>
>> I'd rather see that ARRAY_SIZE() be adjusted to work cleanly for zero
>> sized array elements.
> 
> Anyone with a suggestion?
> 
> Please note this is now in Linus' tree, possibly crashing people's boxes...

I took in the version of the fix I didn't like via Pablo for
now.
