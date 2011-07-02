From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH] Disable router anycast address for /127 prefixes
Date: Sat, 02 Jul 2011 11:38:19 +0200
Message-ID: <87r569rpis.fsf@nemi.mork.no>
References: <20110630104713.52e085dd@nehalam.ftrdhcpuser.net>
	<1309519330-16649-1-git-send-email-bjorn@mork.no>
	<4E0DDDA5.20401@hp.com> <87y60hsvr2.fsf@nemi.mork.no>
	<4E0E1B85.1080906@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:42308 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753040Ab1GBJi1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jul 2011 05:38:27 -0400
In-Reply-To: <4E0E1B85.1080906@hp.com> (Brian Haley's message of "Fri, 01 Jul
	2011 15:09:57 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brian Haley <brian.haley@hp.com> writes:
> On 07/01/2011 02:26 PM, Bj=C3=B8rn Mork wrote:
>> Brian Haley <brian.haley@hp.com> writes:
>>
>>> I'm not sure you'd need this part as there shouldn't be a /127 in t=
he list to remove.
>>=20
>> I don't understand exactly what you mean here....=20
>
> If you never add an anycast address when the prefix length is 127, th=
e address
> wouldn't be there when you went to remove it.  In other words, the ca=
ll to
> __ipv6_dev_ac_dec() would return -ENOENT, which is ignored anyways.

Doh!  Of course.  Sorry for being that slow...

And thanks for taking the time to feed it to me with a small enough
spoon :-)

> It's not a common codepath so the two lines of code wouldn't hurt any=
thing
> I guess...

Personally I prefer "symmetric" coding because it leaves fewer question=
s
unanswered (necessary for the slow among us, as demonstrated above).

But I think that's for those actually maintaining this code to decide.
I can post an updated patch if required, or feel free to apply only the
first hunk.


Bj=C3=B8rn
