From: Plamen Petrov <pvp-lsts@fs.uni-ruse.bg>
Subject: Re: [Bugme-new] [Bug 16626] New: Machine hangs with EIP at skb_copy_and_csum_dev
Date: Fri, 20 Aug 2010 13:53:27 +0300
Message-ID: <4C6E5EA7.3040609@fs.uni-ruse.bg>
References: <bug-16626-10286@https.bugzilla.kernel.org/>	 <20100819152143.8a57c465.akpm@linux-foundation.org>	 <4C6E0C99.2060407@fs.uni-ruse.bg>	 <20100819221142.b8f6a70a.akpm@linux-foundation.org>	 <4C6E1CBA.2060605@fs.uni-ruse.bg>	 <20100819232019.6f6074a8.akpm@linux-foundation.org>	 <4C6E202E.5030406@fs.uni-ruse.bg> <1282286070.2295.6.camel@edumazet-laptop>	 <4C6E3D58.5080303@fs.uni-ruse.bg> <4C6E488A.4010100@fs.uni-ruse.bg> <1282299972.2484.21.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [83.228.35.12] ([83.228.35.12]:52069 "EHLO fs.ru.acad.bg"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751102Ab0HTKx3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Aug 2010 06:53:29 -0400
In-Reply-To: <1282299972.2484.21.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=D0=9D=D0=B0 20.8.2010 =D0=B3. 13:26, Eric Dumazet =D0=BD=D0=B0=D0=BF=D0=
=B8=D1=81=D0=B0:
> Le vendredi 20 ao=C3=BBt 2010 =C3=A0 12:19 +0300, Plamen Petrov a =C3=
=A9crit :
>> =D0=9D=D0=B0 20.8.2010 =D0=B3. 11:31, Plamen Petrov =D0=BD=D0=B0=D0=BF=
=D0=B8=D1=81=D0=B0:
>> ...
=2E..
>>
>> Where to next?
>
>
> First, thanks a lot for finding this so fast.
=46or nothing.
>
> Hmmm, please check that on your net/core/dev.c file, line 3146 you ha=
ve
> the fix added in
>
> http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;a=3D=
commitdiff;h=3De5093aec2e6b60c3df2420057ffab9ed4a6d2792
>
> commit e5093aec2e6b60c3df2420057ffab9ed4a6d2792
> Author: Jarek Poplawski<jarkao2@gmail.com>
> Date:   Wed Aug 11 02:02:10 2010 +0000
>
>      net: Fix a memmove bug in dev_gro_receive()
>
>
>
> 	--skb_shinfo(skb)->nr_frags * sizeof(skb_frag_t));
>

Yes, I confirm I have the above code in place.

>
> If yes, I think David&  Herbert will probably have to dig again into =
gro
> code :(
>

So, I guess its David and Herbert's turn?...

Thanks!
Plamen
