From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: fe80::/64 route missing on GRE tunnels
Date: Mon, 17 Feb 2014 11:34:07 +0100
Message-ID: <5301E59F.5090506@6wind.com>
References: <20140211215510.GA6994@sesse.net> <20140211215928.GA7862@sesse.net> <20140215074559.GA8634@order.stressinduktion.org> <20140215121027.GC8634@order.stressinduktion.org> <5301D843.4020802@6wind.com> <20140217094557.GB32630@sesse.net> <5301DD8A.10808@6wind.com> <20140217101730.GC32630@sesse.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org, itk-intern@samfundet.no,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	sesse@samfundet.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f54.google.com ([74.125.82.54]:45042 "EHLO
	mail-wg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751490AbaBQKeK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 05:34:10 -0500
Received: by mail-wg0-f54.google.com with SMTP id l18so2060827wgh.33
        for <netdev@vger.kernel.org>; Mon, 17 Feb 2014 02:34:08 -0800 (PST)
In-Reply-To: <20140217101730.GC32630@sesse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 17/02/2014 11:17, Steinar H. Gunderson a =C3=A9crit :
> On Mon, Feb 17, 2014 at 10:59:38AM +0100, Nicolas Dichtel wrote:
>>> It is added (ip -6 addr add fe80::1 dev foo), but it doesn't help w=
ithout the
>>> /64 being present.
>> With 'ip -6 addr add fe80::1/64 dev foo', the link local route will =
be added.
>
> Possible, but you're still breaking userspace. You could argue the tu=
nnel
> setup system in question should have added a /64 in the first place, =
but it
> is deployed at a number of locations and changing all of them is not =
trivial.
I will propose a patch (instead of reverting the original one).
