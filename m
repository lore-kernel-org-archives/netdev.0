From: nisse@southpole.se (Niels =?utf-8?Q?M=C3=B6ller?=)
Subject: Re: What's the right way to use a *large* number of source addresses?
Date: Fri, 23 May 2014 16:12:22 +0200
Message-ID: <6za9a8vb21.fsf@southpole.se>
References: <6zlhtsvnqp.fsf@southpole.se>
	<20140523101144.GH24523@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Jonas Bonn <jonas@southpole.se>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.southpole.se ([37.247.8.11]:47857 "EHLO mail.southpole.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752045AbaEWOM1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 May 2014 10:12:27 -0400
In-Reply-To: <20140523101144.GH24523@breakpoint.cc> (Florian Westphal's
	message of "Fri, 23 May 2014 12:11:44 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46lorian Westphal <fw@strlen.de> writes:

> Niels M=C3=B6ller <nisse@southpole.se> wrote:

>> 3. Just set the desired local address with the bind call. Currently,
>>    this gives an EADDRNOTAVAIL error, so the first step would be som=
e
>>    option to allow arbitrary source addresses.
>
> See 'Making non-local sockets work' in Documentation/networking/tprox=
y.txt

I'd just like to say that I followed these docs, and I got a working
connection. Thanks again, I really couldn't locate this info on my own.

I do find the EINVAL error I got from connect, when only using sysctl
net.ipv4.ip_nonlocal_bind=3D1, and using bind with a nonlocal address, =
a
bit puzzling. I don't see any obviously better error to return, though.

Regards,
/Niels
