From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: SYN attack, with FIN flag set
Date: Sat, 03 Dec 2011 08:55:02 +0100
Message-ID: <1322898902.2762.81.camel@edumazet-laptop>
References: <1755dc626dee301261ef4fe4cd66fd47@visp.net.lb>
	 <1322897233.2762.79.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:53426 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751848Ab1LCHzH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2011 02:55:07 -0500
Received: by wgbds13 with SMTP id ds13so2515526wgb.1
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2011 23:55:04 -0800 (PST)
In-Reply-To: <1322897233.2762.79.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 03 d=C3=A9cembre 2011 =C3=A0 08:27 +0100, Eric Dumazet a =C3=A9=
crit :

> I believe netfilter tcp conntrack considers SYN|FIN as INVALID
>=20

Or if you cannot afford conntracking, just do

iptables -A INPUT -p tcp --tcp-flags SYN,FIN SYN,FIN -j DROP
