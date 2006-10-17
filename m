From: Mitsuru Chinen <mitch@jp.ibm.com>
Subject: Re: [PATCH 7/13] [RFC] [IPV6] Move source address selection into
 route lookup.
Date: Tue, 17 Oct 2006 19:14:00 +0900
Message-ID: <4534ACE8.3070806@jp.ibm.com>
References: <4534201D.7070002@tcs.hut.fi>	<20061016.222223.26532234.davem@davemloft.net>	<45348DD4.4000600@6wind.com> <20061017.175231.45194288.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jean-mickael.guerin@6wind.com, davem@davemloft.net,
	vnuorval@tcs.hut.fi, tgraf@suug.ch, kim.nordlund@nokia.com,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:28651 "EHLO e2.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S932179AbWJQKOQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2006 06:14:16 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id k9HAEFGN000994
	for <netdev@vger.kernel.org>; Tue, 17 Oct 2006 06:14:15 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k9HAEFOT127828
	for <netdev@vger.kernel.org>; Tue, 17 Oct 2006 06:14:15 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k9HAEE81002738
	for <netdev@vger.kernel.org>; Tue, 17 Oct 2006 06:14:15 -0400
To: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>
In-Reply-To: <20061017.175231.45194288.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E wrote:
> In article <45348DD4.4000600@6wind.com> (at Tue, 17 Oct 2006 10:01:24=
 +0200), Jean-Mickael Guerin <jean-mickael.guerin@6wind.com> says:
>=20
>>> Although this conversion is very clean and the next patch
>>> is very logic, I'm going to hold on all patches from 7 onward
>>> so there is some time for some discussion of the RFC'ness
>>> of them :-)
>>>
>> With regard to RFC'ness, passing self tests TAHI "Ready Logo 2" with=
=20
>> SUBTREE
>> turned on could be a valuable feedback.
>=20
> Have you done it?
>=20
> We've been trying to pass that, but we failed to compile;
> we probably used wrong tree...

Excuse me. I overlooked an error message from patch command.
When I appiled the patch manually, we could compile them.

We will double-check these patches with TAHI, either.
And then, we will report the results.

Best Regards,
--=20
Mitsuru Chinen <mitch@jp.ibm.com>

