From: Plamen Petrov <pvp-lsts@fs.uni-ruse.bg>
Subject: Re: [Bugme-new] [Bug 16626] New: Machine hangs with EIP at	skb_copy_and_csum_dev
Date: Mon, 23 Aug 2010 17:05:33 +0300
Message-ID: <4C72802D.8090405@fs.uni-ruse.bg>
References: <4C6E5EA7.3040609@fs.uni-ruse.bg> <20100820193835.GA6025@del.dom.local> <20100821074742.GA2367@del.dom.local> <1282377058.2636.12.camel@edumazet-laptop> <20100821080735.GA2409@del.dom.local> <4C725FCB.2000304@fs.uni-ruse.bg> <20100823124736.GA16966@ff.dom.local> <1282568443.2486.34.camel@edumazet-laptop> <20100823131056.GA19160@ff.dom.local> <4C727B06.2060002@fs.uni-ruse.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [83.228.35.12] ([83.228.35.12]:38092 "EHLO fs.ru.acad.bg"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753424Ab0HWOFf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Aug 2010 10:05:35 -0400
In-Reply-To: <4C727B06.2060002@fs.uni-ruse.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=D0=9D=D0=B0 23.8.2010 =D0=B3. 16:43, Plamen Petrov =D0=BD=D0=B0=D0=BF=D0=
=B8=D1=81=D0=B0:
> =D0=9D=D0=B0 23.8.2010 =D0=B3. 16:10, Jarek Poplawski =D0=BD=D0=B0=D0=
=BF=D0=B8=D1=81=D0=B0:
>> On Mon, Aug 23, 2010 at 03:00:43PM +0200, Eric Dumazet wrote:
>> ...
>>> I was about to suggest a similar patch ;)
>>>
>>> Also prints skb->csum_offset and skb->len if possible
>>
>> Feel free to send it: I'm a bit in hurry now...
>>
>> Jarek P.
>
> Currently compiling the kernel with the attached patch.
>
> And, by the way, if there are any patches to follow, would you
> please, send them as attachments? I think my mail client is
> line-wrapping the patches...
>
> The results will be sent soon, too.

Well, so far - so good. No oopses.

I think I'm hitting some compiler related issue here...

The kernel with the patch I sent applied is working pretty fine
even with "generic-receive-offload" ON for my tg3 nic...

What is the big difference there?

Or do we need to dig into the object files now? Because that's
what's too scary for me...

Plamen

P.S. The compiler I am using is :
root@crux:~# gcc -v
> Using built-in specs.
> Target: i686-pc-linux-gnu
> Configured with: ../gcc-4.4.4/configure --prefix=3D/usr --libexecdir=3D=
/usr/lib --enable-languages=3Dc,c++,objc --enable-threads=3Dposix --ena=
ble-__cxa_atexit --enable-clocale=3Dgnu --enable-shared --disable-nls -=
-with-x=3Dno
> Thread model: posix
> gcc version 4.4.4 (CRUX) (GCC)
Anything obviously special about it?
