From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: fe80::/64 route missing on GRE tunnels
Date: Mon, 17 Feb 2014 10:59:38 +0100
Message-ID: <5301DD8A.10808@6wind.com>
References: <20140211215510.GA6994@sesse.net> <20140211215928.GA7862@sesse.net> <20140215074559.GA8634@order.stressinduktion.org> <20140215121027.GC8634@order.stressinduktion.org> <5301D843.4020802@6wind.com> <20140217094557.GB32630@sesse.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org, itk-intern@samfundet.no,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f53.google.com ([74.125.82.53]:40364 "EHLO
	mail-wg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753188AbaBQJ7l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 04:59:41 -0500
Received: by mail-wg0-f53.google.com with SMTP id x12so2116809wgg.32
        for <netdev@vger.kernel.org>; Mon, 17 Feb 2014 01:59:40 -0800 (PST)
In-Reply-To: <20140217094557.GB32630@sesse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 17/02/2014 10:45, Steinar H. Gunderson a =C3=A9crit :
> On Mon, Feb 17, 2014 at 10:37:07AM +0100, Nicolas Dichtel wrote:
>> I'm not sure to understand the problem. In the case described above,=
 there is no
>> fe80::/64 route because there is no link local address.
>> What source address will be used to communicate over this gre interf=
ace?
>
> It is added (ip -6 addr add fe80::1 dev foo), but it doesn't help wit=
hout the
> /64 being present.

With 'ip -6 addr add fe80::1/64 dev foo', the link local route will be =
added.
