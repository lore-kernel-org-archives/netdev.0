From: Bhaskar Dutta <bhaskie@gmail.com>
Subject: Re: TCP-MD5 checksum failure on x86_64 SMP
Date: Fri, 7 May 2010 16:20:45 +0530
Message-ID: <w2n571fb4001005070350m7af2a494s7e7b66b68b26e5c8@mail.gmail.com>
References: <i2h571fb4001005031027y4a58c4dtfd28ddcdc08d8401@mail.gmail.com>
	 <l2k571fb4001005041008k9b129a06vf5e40db2d119434c@mail.gmail.com>
	 <20100504101301.5f4dd9c2@nehalam>
	 <g2p571fb4001005051103w67e1b9ddn3e8f7feb84d0559@mail.gmail.com>
	 <1273085598.2367.233.camel@edumazet-laptop>
	 <i2y571fb4001005060455m39bed7f7if5fcfc45b12bc4d3@mail.gmail.com>
	 <1273210774.2222.45.camel@edumazet-laptop>
	 <1273219222.2261.11.camel@edumazet-laptop>
	 <n2u571fb4001005070159y91d8b13crb20d2f14ea26dd1a@mail.gmail.com>
	 <1273225039.2261.32.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:55937 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754199Ab0EGKup convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 May 2010 06:50:45 -0400
Received: by pwi5 with SMTP id 5so457637pwi.19
        for <netdev@vger.kernel.org>; Fri, 07 May 2010 03:50:45 -0700 (PDT)
In-Reply-To: <1273225039.2261.32.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 7, 2010 at 3:07 PM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> Le vendredi 07 mai 2010 =E0 14:29 +0530, Bhaskar Dutta a =E9crit :
>
>> Eric,
>>
>> Thanks a lot! I will test it out and let you know.
>> BTW this patch seems to essentially do the same as the earlier fix y=
ou
>> had posted (where you just do bh disable/enable).
>> Am I missing something?
>>
>> With the earlier fix, I ran load tests with 80 TCP connections for
>> over 6 hrs and found 5 bad checksum packets.
>> So there is still a problem. Without the fix I see a bad packet ever=
y
>> minute or so.
>
> My second patch is cleaner, using only out of line code (inline was n=
ot
> necessary and made include file bigger than necessary). Inline is fin=
e
> if we can avoid a function call, but it was not the case.
>
> If you notice another corruption, it may be because of another proble=
m,
> yet to be discovered.
>
> To you have a userland suite to test/stress tcp md5 connections ?
>
>

We are still trying to find the other corruption.

I will send you the tarball of a userland client/server suite to
stress test the TCP-MD5 that we've been using to reproduce the issue.

Thanks,
Bhaskar
