From: Victor Julien <victor@inliniac.net>
Subject: Re: [PATCH 2/2] packet: Add fanout support.
Date: Tue, 05 Jul 2011 19:15:35 +0200
Message-ID: <4E1346B7.4000105@inliniac.net>
References: <20110704.212014.236340473910292460.davem@davemloft.net>  <1309846875.2720.43.camel@edumazet-laptop> <4E12B5A6.2020802@inliniac.net>  <1309849214.2720.45.camel@edumazet-laptop>  <D3F292ADF945FB49B35E96C94C2061B91257D61B@nsmail.netscout.com>  <1309882577.2271.23.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <4E133A09.8030907@inliniac.net> <1309882999.2271.25.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Loke, Chetan" <Chetan.Loke@netscout.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-27.netfusion.at ([83.215.238.27]:34393 "EHLO
	tulpe.vuurmuur.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751931Ab1GERQF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 13:16:05 -0400
In-Reply-To: <1309882999.2271.25.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/05/2011 06:23 PM, Eric Dumazet wrote:
> Le mardi 05 juillet 2011 =C3=A0 18:21 +0200, Victor Julien a =C3=A9cr=
it :
>> On 07/05/2011 06:16 PM, Eric Dumazet wrote:
>>> Remember, goal is that _all_ packets of a given flow end in same qu=
eue.
>>>
>>
>> What about a hashing scheme based on just the ip addresses? Would ma=
ke
>> rxhash useless for this purpose, but would be a lot simpler overall =
maybe...
>>
>=20
> What about loads where a single IP address is used ?

How would that be a problem?

> I wonder what's the problem, since David added a defrag unit ;)

No problem, I just suggested it as Chetan Loke brought up the hashing
suggestion. David's solution would work fine for me.

--=20
---------------------------------------------
Victor Julien
http://www.inliniac.net/
PGP: http://www.inliniac.net/victorjulien.asc
---------------------------------------------

