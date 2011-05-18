From: Jacek Luczak <difrost.kernel@gmail.com>
Subject: Re: PATCH] SCTP: fix race between sctp_bind_addr_free() and sctp_bind_addr_conflict()
Date: Wed, 18 May 2011 16:48:35 +0200
Message-ID: <BANLkTimsT3fPZnKXVwBRADN=xSV4R-+GWA@mail.gmail.com>
References: <BANLkTimWpmFj1gx=XvvoXFVxL9q927iWfw@mail.gmail.com>
	<1305729762.2991.34.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Vladislav Yasevich <vladislav.yasevich@hp.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:52509 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933044Ab1EROsf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2011 10:48:35 -0400
Received: by pzk9 with SMTP id 9so735781pzk.19
        for <netdev@vger.kernel.org>; Wed, 18 May 2011 07:48:35 -0700 (PDT)
In-Reply-To: <1305729762.2991.34.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/5/18 Eric Dumazet <eric.dumazet@gmail.com>:
> Le mercredi 18 mai 2011 =E0 16:36 +0200, Jacek Luczak a =E9crit :
>
>> ---
>> =A0net/sctp/bind_addr.c | =A0 10 ++++------
>> =A01 files changed, 4 insertions(+), 6 deletions(-)
>>
>> diff --git a/net/sctp/bind_addr.c b/net/sctp/bind_addr.c
>> index faf71d1..6150ac5 100644
>> --- a/net/sctp/bind_addr.c
>> +++ b/net/sctp/bind_addr.c
>> @@ -140,14 +140,12 @@ void sctp_bind_addr_init(struct sctp_bind_addr
>> *bp, __u16 port)
>> =A0/* Dispose of the address list. */
>
> I am afraid your mailer mangled the patch.
>
> You should have only one line :
>
> @@ -140,14 +140,12 @@ void sctp_bind_addr_init(struct sctp_bind_addr =
*bp, __u16 port)
>
> Instead, there is a line wrap :
>
> @@ -140,14 +140,12 @@ void sctp_bind_addr_init(struct sctp_bind_addr
> *bp, __u16 port)
>

Sadly I'm completely aware of that. I don't have any such here that
actually would not do this. Patch is attached to email just because of
that. I can resend this in the evening from home.

-Jacek
