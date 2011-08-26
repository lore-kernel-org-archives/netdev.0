From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH] iptables/man: IPv6 TOS mangling fix was backported to
 2.6.35-longterm too
Date: Fri, 26 Aug 2011 15:16:39 +0200 (CEST)
Message-ID: <alpine.LNX.2.01.1108261515260.7734@frira.zrqbmnf.qr>
References: <1307320871-31770-1-git-send-email-pablo@netfilter.org>  <1307320871-31770-2-git-send-email-pablo@netfilter.org>  <BANLkTikAs7fN2JQJTUwQHAYPPGMf8i9uEA@mail.gmail.com>  <alpine.LNX.2.01.1106061618370.17430@frira.zrqbmnf.qr>  <1308213411.4062.22.camel@nausicaa>
  <alpine.LNX.2.01.1106161705300.10015@frira.zrqbmnf.qr>  <4DFA1DFC.3000804@trash.net> <1308273097.8612.1.camel@nexus.oss.ntt.co.jp>  <1308273246.8612.3.camel@nexus.oss.ntt.co.jp>  <4DFACE41.5010906@trash.net>  <1312246840.8407.2.camel@nexus.oss.ntt.co.jp>
 <1314154554.1878.7.camel@nausicaa>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>,
	Linux Networking Developer Mailing List
	<netdev@vger.kernel.org>
To: Fernando Luis Vazquez Cao <fernando@oss.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from seven.medozas.de ([188.40.89.202]:57182 "EHLO seven.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754884Ab1HZNQm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Aug 2011 09:16:42 -0400
In-Reply-To: <1314154554.1878.7.camel@nausicaa>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 2011-08-24 04:55, Fernando Luis Vazquez Cao wrote:

>Fernando Luis V=C3=A1zquez Cao wrote:
>> Update man page accordingly.
>>=20
>> Signed-off-by: Fernando Luis Vazquez Cao <fernando@oss.ntt.co.jp>
>> ---
>>=20
>> -longterm releases 2.6.32.42 (or later) and 2.6.33.15 (or later), th=
ere is a bug
>> -whereby IPv6 TOS mangling does not behave as documented and differs=
 from the
>> -IPv4 version. The TOS mask indicates the bits one wants to zero out=
, so it needs
>> -to be inverted before applying it to the original TOS field. Howeve=
r, the
>> +longterm releases 2.6.32 (>=3D.42), 2.6.33 (>=3D.15), and 2.6.35 (>=
=3D.14), there is
>> +a bug whereby IPv6 TOS mangling does not behave as documented and d=
iffers from
>> +the IPv4 version. The TOS mask indicates the bits one wants to zero=
 out, so it
>> +needs to be inverted before applying it to the original TOS field. =
However, the
>>  aformentioned kernels forgo the inversion which breaks --set-tos an=
d its
>>  mnemonics.
>
>Ping?

Patch picked up now.
