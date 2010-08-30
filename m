From: Jerry Chu <hkchu@google.com>
Subject: Re: [PATCH] TCP_USER_TIMEOUT: a new socket option to specify max
 timeout before a TCP connection is aborted
Date: Mon, 30 Aug 2010 15:41:26 -0700
Message-ID: <AANLkTinBcP7KtSeq1daP=jU9YWgkcZbjrc4bqGA9o=8Y@mail.gmail.com>
References: <AANLkTimW_7a9=yK4po9FshH0i0LT-MZF+fysGRvgT3jG@mail.gmail.com>
	<20100829.211954.232753860.davem@davemloft.net>
	<AANLkTinrPcJwMs+frY7J_QKuNv1MDGRQAgPgwofuFydw@mail.gmail.com>
	<20100830.132502.68138403.davem@davemloft.net>
	<1283200212.2405.14.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, hannemann@nets.rwth-aachen.de,
	hagen@jauu.net, lars.eggert@nokia.com, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:41907 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755607Ab0H3Wla convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Aug 2010 18:41:30 -0400
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id o7UMfSoY029414
	for <netdev@vger.kernel.org>; Mon, 30 Aug 2010 15:41:28 -0700
Received: from gxk20 (gxk20.prod.google.com [10.202.11.20])
	by wpaz37.hot.corp.google.com with ESMTP id o7UMfR4V019324
	for <netdev@vger.kernel.org>; Mon, 30 Aug 2010 15:41:27 -0700
Received: by gxk20 with SMTP id 20so2650589gxk.31
        for <netdev@vger.kernel.org>; Mon, 30 Aug 2010 15:41:27 -0700 (PDT)
In-Reply-To: <1283200212.2405.14.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric, will surly do but perhaps we should wait till Hagen gets his
TCP_ADV_UTO part so we can update the man page altogether in a
cohesive way (in case we're missing something, since he's on vacation
right now)?

Jerry

On Mon, Aug 30, 2010 at 1:30 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le lundi 30 ao=FBt 2010 =E0 13:25 -0700, David Miller a =E9crit :
>
>> I was just saying that it can result in unexpected situations. =A0Th=
e
>> user can increase and increase the timeout they use, but to no effec=
t
>> because due to backoff the increase isn't adding any more probes at
>> all.
>>
>> In any event, I've applied your patch, let's see how this goes.
>
>
>
> Jerry, could you please send a man update ?
>
> http://www.kernel.org/doc/man-pages/online/pages/man7/tcp.7.html
>
> (To Michael Kerrisk <mtk.manpages@gmail.com> )
>
> Thanks
>
>
>
