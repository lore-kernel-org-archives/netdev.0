From: =?ISO-8859-2?Q?=A9tefan_Gula?= <steweg@ynet.sk>
Subject: Re: [patch v3, iproute2 version 3.2.0] Source mode for macvlan interface
Date: Tue, 31 Jan 2012 08:29:45 +0100
Message-ID: <CAGsizzJ-uQ-qHm=A7watZ+-OjFm=MxoyP3Q0Zdi54ap9mmdhWA@mail.gmail.com>
References: <10839102.1251327929240954.JavaMail.root@5-MeO-DMT.ynet.sk> <20120130084003.50bcd3f2@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:42322 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752155Ab2AaHaF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2012 02:30:05 -0500
Received: by pbdu11 with SMTP id u11so376320pbd.19
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2012 23:30:05 -0800 (PST)
In-Reply-To: <20120130084003.50bcd3f2@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/1/30 Stephen Hemminger <shemminger@vyatta.com>:
> On Mon, 30 Jan 2012 14:14:00 +0100 (CET)
> Stefan Gula <steweg@ynet.sk> wrote:
>
>> From: Stefan Gula <steweg@gmail.com>
>>
>> Adjusting iproute2 utility to support new macvlan link type mode
>> called "source". Example of commands that can be applied:
>> =A0ip link add link eth0 name macvlan0 type macvlan mode source
>> =A0ip link set link macvlan0 type macvlan macaddr add 00:11:11:11:11=
:11
>> =A0ip link set link macvlan0 type macvlan macaddr del 00:11:11:11:11=
:11
>> =A0ip link set link macvlan0 type macvlan macaddr flush
>>
>> Signed-off-by: Stefan Gula <steweg@gmail.com>
>>
>
> Documentation update?
>
>
Good point... I have checked whole package iproute2 where macvlan or
vepa is mentioned. Especially documentation files. It turns out that
the only other file not changed was man/man8/ip-link.8. But there is
missing documentation even for other modes like "vepa, bridge
,private, passthru"... so where do you suggest adding the
documentation? Help message in the code was already modified - try:
/ip/ip link add type macvlan help
