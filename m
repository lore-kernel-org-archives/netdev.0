From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Linux Route Cache performance tests
Date: Mon, 07 Nov 2011 10:16:25 +0100
Message-ID: <1320657385.2361.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <4EB6AE62.5050803@itcare.pl>
	 <1320600597.6506.7.camel@edumazet-laptop> <4EB6D1D8.8040604@itcare.pl>
	 <1320605326.6506.27.camel@edumazet-laptop> <4EB6DE06.7050009@itcare.pl>
	 <1320608290.6506.33.camel@edumazet-laptop> <4EB6ED2E.1070106@itcare.pl>
	 <1320614788.6506.38.camel@edumazet-laptop> <4EB702D3.1090703@itcare.pl>
	 <1320620915.6506.44.camel@edumazet-laptop> <4EB798A5.7000900@itcare.pl>
	 <1320656922.2361.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: =?UTF-8?Q?Pawe=C5=82?= Staszewski <pstaszewski@itcare.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:47029 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752357Ab1KGJQ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2011 04:16:29 -0500
Received: by bke11 with SMTP id 11so3402108bke.19
        for <netdev@vger.kernel.org>; Mon, 07 Nov 2011 01:16:28 -0800 (PST)
In-Reply-To: <1320656922.2361.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 07 novembre 2011 =C3=A0 10:08 +0100, Eric Dumazet a =C3=A9crit=
 :

> Obviously, cache removal will be possible only when performance witho=
ut
> it is the same.
>=20
> Work is in progress, it started a long time ago.
>=20

One of the reason to get rid of this cache is its memory use.

256 bytes per entry, thats a lot of memory if you need 2.000.000
entries...
