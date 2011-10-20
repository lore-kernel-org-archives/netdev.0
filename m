From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: change capability used by socket options
 IP{,V6}_TRANSPARENT
Date: Thu, 20 Oct 2011 00:19:39 -0400 (EDT)
Message-ID: <20111020.001939.548341110762997206.davem@davemloft.net>
References: <1318889783-23183-1-git-send-email-zenczykowski@gmail.com>
	<20111019.193435.1214580639401316303.davem@davemloft.net>
	<CANP3RGf1ZyNEiADXMsD1C=4GMyOMvxEZQ93nYpghhXhCJKNF6Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bazsi@balabit.hu
To: zenczykowski@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34226 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751485Ab1JTETt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2011 00:19:49 -0400
In-Reply-To: <CANP3RGf1ZyNEiADXMsD1C=4GMyOMvxEZQ93nYpghhXhCJKNF6Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =AFenczykowski <zenczykowski@gmail.com>
Date: Wed, 19 Oct 2011 20:32:31 -0700

> Are you okay with the patch without any warnings or deprecation marki=
ngs?
> Or are you against opening up CAP_NET_RAW to this in general?

I don't see any real benefit.

If it has been decided that you can't create a new capability for
tproxy, so that tasks can be segregated out of these more powerful
networking capability levels, I simply don't see the point.

A process with CAP_NET_RAW can spit whatever crap they want onto the
network, and receive all packets with impunity.

I can't see what this buys us at all, sorry.
