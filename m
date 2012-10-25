From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: Re: listen(2) backlog changes in or around Linux 3.1?
Date: Thu, 25 Oct 2012 16:16:46 -0700
Message-ID: <CAGK4HS_DVtvEf78r3z_RoOWSyBCjqSVmFPtpEztDw=W5UkCvrw@mail.gmail.com>
References: <CAJgzZorigejCuFweNrvmkEJts3Um7exh1fYTH=4KrEcB=v=2SA@mail.gmail.com>
	<507C4401.7050500@oracle.com>
	<CAJgzZoqhw6HJxa6uRbekLMaVTDVOo92YDtzqHnZoRiQ8tq6G2g@mail.gmail.com>
	<CAJgzZoq9+KZpQ1tVQJUK++VVk4JfY9u8timaJ5q6wSYoF+_tog@mail.gmail.com>
	<5080279F.80008@oracle.com>
	<5080340F.3050207@oracle.com>
	<CAJgzZooJM7aj=K-idvdbwUOOmtDM6u-=gsVOs2OFZjiZwQP0zw@mail.gmail.com>
	<CAGK4HS-tOE1uZR2PE+_DShEb3y5ZAn=dtECY1AmmyO2AmTVzTA@mail.gmail.com>
	<1350629413.2293.157.camel@edumazet-glaptop>
	<1350634013.2293.262.camel@edumazet-glaptop>
	<CAGK4HS_9mLzL9ESm=n5hvO0cw1hkHFMCSmBiYTBnqEMqQOvPvQ@mail.gmail.com>
	<1350642562.2293.411.camel@edumazet-glaptop>
	<alpine.DEB.2.00.1210221251520.1684@cleese>
	<1350936519.8609.1239.camel@edumazet-glaptop>
	<CAGK4HS9N9b64pKobWE=9wM-ZqNL-uJiGoAWNkqu=F=-NgHM=0Q@mail.gmail.com>
	<1351205417.6537.272.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: enh <enh@google.com>,
	Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:64256 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751485Ab2JYXQr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Oct 2012 19:16:47 -0400
Received: by mail-ob0-f174.google.com with SMTP id uo13so2112334obb.19
        for <netdev@vger.kernel.org>; Thu, 25 Oct 2012 16:16:46 -0700 (PDT)
In-Reply-To: <1351205417.6537.272.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25 October 2012 15:50, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Mon, 2012-10-22 at 15:11 -0700, Vijay Subramanian wrote:
>
>> >
>> > All these facilities sound very complex and not really usable by clients
>> > (ie users not willing to wait more than few seconds anyway)
>> >
>>
>> Fair enough. We can drop this if it is not worth the trouble or if I
>> have missed any other scenario.
>>
>
> Sorry my comment was not related to your patch, but existing logic.
>
> It seems there is no value resending SYNACK, as we received the client
> ACK.
>
> Please send an official patch ?
>
>
>
Eric,
I will send a patch shortly.

Thanks,
Vijay
