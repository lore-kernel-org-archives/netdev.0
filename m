From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: add sysctl allow_so_priority for SO_PRIORITY
 setsockopt
Date: Sat, 22 Oct 2011 02:58:36 -0400 (EDT)
Message-ID: <20111022.025836.1306779710775525629.davem@davemloft.net>
References: <1319235725-3046-1-git-send-email-zenczykowski@gmail.com>
	<20111022.000406.350185785547409199.davem@davemloft.net>
	<CAHo-OoxtAmzPjr4R7jQOk9GGQo7i-qVmoaY8vTYDQDj1HXsPNA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: zenczykowski@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38278 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751639Ab1JVG6l convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Oct 2011 02:58:41 -0400
In-Reply-To: <CAHo-OoxtAmzPjr4R7jQOk9GGQo7i-qVmoaY8vTYDQDj1HXsPNA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =AFenczykowski <zenczykowski@gmail.com>
Date: Fri, 21 Oct 2011 23:49:00 -0700

> However, processes can also manually override the sk_priority by call=
ing
> SO_PRIORITY directly, at which point their IP_TOS and SO_PRIORITY no
> longer match.
>=20
> This patch allows you to disable this ability.

I also don't see why we'd want to allow disabling this either.

I really hate these patches that offer ways to disable things
that normally work, and thus break apps when the non-default
is selected.

I kind of have a feeling the kind of situation you're trying to
account for, you have some cloud where people run random stuff
that you don't control.

But you didn't specify this, and we just have to guess.  Why don't you
describe the specific situation where you want to modify this setting?

Please do this instead of just talking about what the side effects are
inside of the kernel.  That's much less interesting when it comes to
patches like this.
