From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Sundance network driver (D-Link DFE-580TX) timeouts rendering
 interface unusable
Date: Mon, 30 Jan 2012 15:28:56 +0100
Message-ID: <1327933736.2288.41.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <SNT141-W3553B2629FBBC84A5A140596860@phx.gbl>
	 <1327205171.8004.96.camel@deadeye>
	 <SNT141-W5087B9A5022955EA5564DB96890@phx.gbl>
	 <20120126220640.GO12704@decadent.org.uk>
	 <SNT141-W58AC5ADD0BC9DE29AFA00D968E0@phx.gbl>
	 <1327811546.5400.291.camel@deadeye>
	 <CAHj3AVm8cjkj83QHGAqOji6t4uWFr6jAAADu7vLKyfEORk1LoA@mail.gmail.com>
	 <1327918447.2288.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1327932311.5400.429.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Denis Kirjanov <kirjanov@gmail.com>,
	"Mike ." <mike-bugreport@hotmail.com>, 656476@bugs.debian.org,
	netdev <netdev@vger.kernel.org>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:38027 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753184Ab2A3O3A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2012 09:29:00 -0500
Received: by bkas6 with SMTP id s6so3216331bka.19
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2012 06:28:59 -0800 (PST)
In-Reply-To: <1327932311.5400.429.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 30 janvier 2012 =C3=A0 14:05 +0000, Ben Hutchings a =C3=A9crit=
 :

> Yes, I spotted that.  But no descriptors are pushed to the hardware
> here; that's done in the driver's TX tasklet.  Although... maybe that
> can run immediately when scheduled from here?  I've never had to deal
> with tasklets so I really don't know their semantics.

Thats probable on SMP ...
