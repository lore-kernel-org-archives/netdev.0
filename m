From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH] ipv6: fix raw socket checksum for udplite
Date: Tue, 26 Mar 2013 22:30:25 -0400
Message-ID: <515259C1.20204@hp.com>
References: <1364337095-19663-1-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?B?TWFjaWVqIMW7ZW5jenlrb3dza2k=?= <maze@google.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	Mike Dalton <mwdalton@google.com>
To: =?UTF-8?B?TWFjaWVqIMW7ZW5jenlrb3dza2k=?= <zenczykowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:17613 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751625Ab3C0Ca3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 22:30:29 -0400
In-Reply-To: <1364337095-19663-1-git-send-email-zenczykowski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/26/2013 06:31 PM, Maciej =C5=BBenczykowski wrote:
> From: Maciej =C5=BBenczykowski <maze@google.com>
>=20
> Commit d3a1be9cba86 from Brian Haley in Nov 2006
> "[IPv6]: Only modify checksum for UDP" forgot about
> UDPLITE.

I'm not sure I'd say I "forgot about" it, UDPLITE support didn't exist =
in Linux
until three+ weeks after that commit.

commit d3a1be9cba86c4385a5fe46673bbb4730551f454
Author: Brian Haley <brian.haley@hp.com>
Date:   Fri Nov 10 14:54:51 2006 -0800

    [IPv6]: Only modify checksum for UDP

commit ba4e58eca8aa9473b44fdfd312f26c4a2e7798b3
Author: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date:   Mon Nov 27 11:10:57 2006 -0800

    [NET]: Supporting UDP-Lite (RFC 3828) in Linux

I see no reason your patch isn't correct though.

Acked-by: Brian Haley <brian.haley@hp.com>

-Brian
