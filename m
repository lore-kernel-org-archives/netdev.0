From: Jan Seiffert <kaffeemonster@googlemail.com>
Subject: Re: [REGRESSION][PATCH V4 3/3] bpf jit: Let the powerpc jit handle
 negative offsets
Date: Mon, 30 Apr 2012 05:43:05 +0200
Message-ID: <4F9E0A49.8090201@googlemail.com>
References: <4F75CA89.4010709@googlemail.com>  <4F75D2A5.7060407@googlemail.com>  <20120403.180302.342779808900865443.davem@davemloft.net>  <1333491102.3040.12.camel@pasglop> <1335753820.20866.27.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <eric.dumazet@gmail.com>,
	<matt@ozlabs.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <linuxppc-dev@lists.ozlabs.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1335753820.20866.27.camel@pasglop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Benjamin Herrenschmidt schrieb:
> On Wed, 2012-04-04 at 08:11 +1000, Benjamin Herrenschmidt wrote:
>> On Tue, 2012-04-03 at 18:03 -0400, David Miller wrote:
>> 
>>>> Signed-off-by: Jan Seiffert <kaffeemonster@googlemail.com>
>>>> 
>>>> I have only compile tested this, -ENOHARDWARE. Can someone with
>>>> more powerpc kung-fu review and maybe test this? Esp. powerpc
>>>> asm is not my strong point. I think i botched the stack frame
>>>> in the call setup. Help?
>>> 
>>> I'm not applying this until a powerpc person tests it.
>>> 
>>> Also, we have an ARM JIT in the tree which probably needs to be
>>> fixed similarly.
>> 
>> Matt's having a look at powerpc
> 
> Ok, he hasn't so I'll dig a bit.
> 

That would be great Benjamin!

> No obvious wrongness (but I'm not very familiar with bpf),

As long as you know PPC ASM you are my man ;-)

> though I do have a comment: sk_negative_common() and
> bpf_slow_path_common() should be made one and single macro which
> takes the fallback function as an argument.
> 

I don't know if this is possible.
The return value is different (one returns 0 on success, the other != 0,
the return value of != is needed). I didn't wanted to change to much,
because i'm not fluent in ppc.

> I'll mess around & try to test using Jan test case & will come back 
> with an updated patch.
> 

Would be great!

> Cheers, Ben.
> 

Greetings
	Jan

-- 
A UDP packet walks into a
