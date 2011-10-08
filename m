From: Olaf van der Spek <ml@vdspek.org>
Subject: Re: SOMAXCONN = 128, but max defaults to 2048
Date: Sat, 8 Oct 2011 14:44:29 +0200
Message-ID: <CAGVGHmtT1UQn4oZiSd_uzBQLcZextA3Hap2ZLhgKG3A3xWfkqg@mail.gmail.com>
References: <CAGVGHmt1OVOj0NSEo3qHCh1CR10eZTNjxuUh_mB6sXxcx5gKmA@mail.gmail.com>
	<1318077339.5276.17.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:53897 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751802Ab1JHMoa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Oct 2011 08:44:30 -0400
Received: by vcbfk10 with SMTP id fk10so3680070vcb.19
        for <netdev@vger.kernel.org>; Sat, 08 Oct 2011 05:44:30 -0700 (PDT)
In-Reply-To: <1318077339.5276.17.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 8, 2011 at 2:35 PM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> Le samedi 08 octobre 2011 =E0 13:51 +0200, Olaf van der Spek a =E9cri=
t :
>> Is the name of SOMAXCONN wrong and is it actually defining the defau=
lt?
>> Would there be a disadvantage to defining SOMAXCONN as INT_MAX and
>> letting the kernel control the actual max?
>>
>
> You mean : remove somaxconn tunable ?

No, I mean basically removing the compile-time value and only using
the run-time value (from the kernel).

> accept()/listen() is not bound to TCP only.

What else is that value used for?

> We had a recent discussion on the matter lately, but Hagen Paul Pfeif=
er
> did not polish his patches enough :
>
> http://lists.openwall.net/netdev/2011/03/20/3

Isn't it a single-line change?

Olaf
