From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2 1/4] siphash: add cryptographically secure hashtable
 function
Date: Thu, 15 Dec 2016 13:50:02 +0100
Message-ID: <0f3c3694-c00b-aae2-5b08-25bc64bf6372@stressinduktion.org>
References: <20161214035927.30004-1-Jason@zx2c4.com>
 <CAHmME9q9ffdtWRbzyMO1ktTdtEFdfumTfojTTNLXFhoa+R+MWQ@mail.gmail.com>
 <8ea3fdff-23c4-b81d-2588-44549bd2d8c1@stressinduktion.org>
 <063D6719AE5E284EB5DD2968C1650D6DB02401ED@AcuExch.aculab.com>
 <707472e1-b385-836d-c4c6-791c1dcc0776@stressinduktion.org>
 <063D6719AE5E284EB5DD2968C1650D6DB02402C0@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
        "kernel-hardening@lists.openwall.com"
        <kernel-hardening@lists.openwall.com>,
        Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>,
        LKML <linux-kernel@vger.kernel.org>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        "Daniel J . Bernstein" <djb@cr.yp.to>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Eric Biggers <ebiggers3@gmail.com>
To: David Laight <David.Laight@ACULAB.COM>,
        "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:59480 "EHLO
        out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755419AbcLOMuG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Dec 2016 07:50:06 -0500
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB02402C0@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15.12.2016 13:28, David Laight wrote:
> From: Hannes Frederic Sowa
>> Sent: 15 December 2016 12:23
> ...
>> Hmm? Even the Intel ABI expects alignment of unsigned long long to be 8
>> bytes on 32 bit. Do you question that?
> 
> Yes.
> 
> The linux ABI for x86 (32 bit) only requires 32bit alignment for u64 (etc).

Hmm, u64 on 32 bit is unsigned long long and not unsigned long. Thus I
am actually not sure if the ABI would say anything about that (sorry
also for my wrong statement above).

Alignment requirement of unsigned long long on gcc with -m32 actually
seem to be 8.
