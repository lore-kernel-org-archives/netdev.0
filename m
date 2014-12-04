From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: Where exactly will arch_fast_hash be used
Date: Thu, 04 Dec 2014 16:43:31 +0100
Message-ID: <54808123.8000704@redhat.com>
References: <20141204081147.GA19030@gondor.apana.org.au> <20141204152637.GA32140@casper.infradead.org> <20141204152929.GA22075@gondor.apana.org.au> <20141204153938.GC32140@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>,
	"Theodore Ts'o" <tytso@mit.edu>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141204153938.GC32140@casper.infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/04/2014 04:39 PM, Thomas Graf wrote:
> On 12/04/14 at 11:29pm, Herbert Xu wrote:
>> On Thu, Dec 04, 2014 at 03:26:37PM +0000, Thomas Graf wrote:
>>>
>>> As Daniel pointed out, this work originated for the OVS edge use
>>> case where security is of less concern and the rehashing is
>>> sufficient. Identifying collisions is less of interest as the user
>>> space fall back provides a greater surface for an attack.
>>
>> Well in that case the current setup I think is very misleading.
>> It's inviting unsuspecting kernel developers to use it as a hash
>> function for general hash tables, which AFAICS is something that
>> it fails at miserably.
>
> Well, it's called fast hash and not secure hash ;-) but a clear hint
> definitely wouldn't hurt.

Hm, I thought the kernel doc on arch_fast_hash() in include/linux/hash.h
would give enough of a hint ...
