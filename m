From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: Re: tun issue after e0b46d0ee9c: tun: Use iovec iterators
Date: Mon, 01 Dec 2014 11:05:55 -0200
Message-ID: <547C67B3.7040505@redhat.com>
References: <5478CC27.9040705@redhat.com> <20141128235935.GA2178@gondor.apana.org.au> <547954B9.2050804@redhat.com> <20141130082106.GA9531@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41330 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752404AbaLANGB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Dec 2014 08:06:01 -0500
In-Reply-To: <20141130082106.GA9531@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 30-11-2014 06:21, Herbert Xu wrote:
> On Sat, Nov 29, 2014 at 03:08:09AM -0200, Marcelo Ricardo Leitner wrote:
>> On 28-11-2014 21:59, Herbert Xu wrote:
>>> On Fri, Nov 28, 2014 at 05:25:27PM -0200, Marcelo Ricardo Leitner wrote:
>>>>
>>>> I saw there are tun updates on Dave's queue but none seemed to handle this.
>>>>
>>>> I can't use current net-next
>>>> (799d2fff1858004526ad75d66a5dd8a5cce6ad40) on a kvm hypervisor
>>>> because tun got clogged somehow. Bisected down to:
>>>>
>>>> commit e0b46d0ee9c240c7430a47e9b0365674d4a04522
>>>> Author: Herbert Xu <herbert@gondor.apana.org.au>
>>>> Date:   Fri Nov 7 21:22:23 2014 +0800
>>>
>>> Does this patch help?
>>
>> Yay, it does! Works for me, thanks Herbert.
>> I didn't test performance, but dhcp could get through.
>>
>> Are you sure about the Fixes tag? Because bisect really pointed to e0b46d0ee9c.
>
> Well according to your report you were having problems with
> tun_get_user.  The bug I introduced was in tun_put_user and has
> already been fixed by Jason Wang.

Ahh yes, ok. Thanks

Cheers,
Marcelo
