From: Martin Mares <mj@ucw.cz>
Subject: Re: [PATCH 0/10] af_unix: add multicast and filtering features to
 AF_UNIX
Date: Mon, 5 Mar 2012 16:49:38 +0100
Message-ID: <mj+md-20120305.154556.19668.albireo@ucw.cz>
References: <20120301.170848.432407217191581288.davem@davemloft.net>
 <CABBYNZLwHKd5srzYYzWNL-iaeuH1K31824pY_bjRSbSLkv0QtA@mail.gmail.com>
 <20120302.035509.1994457175982020283.davem@davemloft.net>
 <4F509274.9060302@collabora.co.uk>
 <1330694031.2469.15.camel@edumazet-laptop>
 <4F50F6AA.9050909@collabora.co.uk>
 <20120302170823.7117821b@pyramind.ukuu.org.uk>
 <CABBYNZKhoT-POaaSvHoNLXU+hkPCiY_eqjEqDgzCqq4RvEvNXg@mail.gmail.com>
 <mj+md-20120305.140318.15543.albireo@ucw.cz>
 <4F54D794.5090903@collabora.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Luiz Augusto von Dentz <luiz.dentz@gmail.com>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	ying.xue@windriver.com, rodrigo.moya@collabora.co.uk,
	javier@collabora.co.uk, lennart@poettering.net,
	kay.sievers@vrfy.org, alban.crequy@collabora.co.uk,
	bart.cerneels@collabora.co.uk, sjoerd.simons@collabora.co.uk,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Marcel Holtmann <marcel@holtmann.org>
To: Javier Martinez Canillas <javier.martinez@collabora.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from jabberwock.ucw.cz ([46.255.230.98]:42641 "EHLO
	jabberwock.ucw.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751580Ab2CEPtl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2012 10:49:41 -0500
Received: from albireo.ucw.cz (albireo.ucw.cz [89.239.2.32])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(Client CN "albireo.ucw.cz", Issuer "ucw.cz" (verified OK))
	by jabberwock.ucw.cz (Postfix) with ESMTPS id D92451C00D6
	for <netdev@vger.kernel.org>; Mon,  5 Mar 2012 16:49:39 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <4F54D794.5090903@collabora.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

> We still don't have performance numbers for D-bus using AF_UNIX
> multicast since our D-bus daemon branch is still not stable. But Alban
> did some tests for the first approach (creating a new socket address
> family AF_DBUS) and the performance gain was x1.8 for KVM/i386 and x3
> for N900/ARM.

I did not ask for the performance improvement in artificial benchmarks,
they will obviously show some :)

What I am interested in is a test showing that _in_real_world_, the system
spends considerable amount of time by passing messages. That is, a reason
for optimizing the thing at all.

				Have a nice fortnight
-- 
Martin `MJ' Mares                          <mj@ucw.cz>   http://mj.ucw.cz/
Faculty of Math and Physics, Charles University, Prague, Czech Rep., Earth
American patent law: two monkeys, fourteen days.
