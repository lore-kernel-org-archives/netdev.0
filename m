From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Linux Route Cache performance tests
Date: Mon, 07 Nov 2011 10:08:42 +0100
Message-ID: <1320656922.2361.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <4EB6AE62.5050803@itcare.pl>
	     <1320600597.6506.7.camel@edumazet-laptop> <4EB6D1D8.8040604@itcare.pl>
	    <1320605326.6506.27.camel@edumazet-laptop> <4EB6DE06.7050009@itcare.pl>
	   <1320608290.6506.33.camel@edumazet-laptop> <4EB6ED2E.1070106@itcare.pl>
	  <1320614788.6506.38.camel@edumazet-laptop> <4EB702D3.1090703@itcare.pl>
	 <1320620915.6506.44.camel@edumazet-laptop> <4EB798A5.7000900@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: =?UTF-8?Q?Pawe=C5=82?= Staszewski <pstaszewski@itcare.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:64578 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751883Ab1KGJIq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2011 04:08:46 -0500
Received: by wwi36 with SMTP id 36so6403616wwi.1
        for <netdev@vger.kernel.org>; Mon, 07 Nov 2011 01:08:45 -0800 (PST)
In-Reply-To: <4EB798A5.7000900@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 07 novembre 2011 =C3=A0 09:36 +0100, Pawe=C5=82 Staszewski a =C3=
=A9crit :

> Yes after enabling NUMA I can change rhash_entries on kernel boot.
>=20
> And what is the most important for big route cahce is rhash_entries
> if route cache size exceed hash size performance will drop 6x to 8x
> So the best settings for route cache are:
> rhash_entries =3D gc_thresh =3D max_size
>=20
> Eric tell me what are the plans for removing route cache from kernel =
?
> Because as You see with route cache performance is better
> And without route cache performance is not soo good than with route=20
> cache enabled but it is stable for all situations even DDOS with 10kk=
=20
> random_ips
>=20
> So for the feature we need to prepare for lower kernel IP forwarding=20
> performance because of no route cache ?
> Or removing route cache will save some time in IP stack  processing ?
>=20

Obviously, cache removal will be possible only when performance without
it is the same.

Work is in progress, it started a long time ago.
