From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net-netlink: Add a new attribute to expose TCLASS
 values via netlink
Date: Wed, 09 Nov 2011 20:53:44 -0500 (EST)
Message-ID: <20111109.205344.49946086292195784.davem@davemloft.net>
References: <1320711791-11005-1-git-send-email-zenczykowski@gmail.com>
	<20111109.153451.441383099995731023.davem@davemloft.net>
	<CAHo-OozNP2qi_RMjO7rS1=fyaU8w_3aZZLptqnYAkCAwhQDj_w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, muralira@google.com, shemminger@vyatta.com,
	eric.dumazet@gmail.com
To: zenczykowski@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33951 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752019Ab1KJBxu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2011 20:53:50 -0500
In-Reply-To: <CAHo-OozNP2qi_RMjO7rS1=fyaU8w_3aZZLptqnYAkCAwhQDj_w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =AFenczykowski <zenczykowski@gmail.com>
Date: Wed, 9 Nov 2011 17:50:27 -0800

> Yes, but an ipv6 socket is permitted to setsockopt SOL_IP in addition
> to SOL_IPV6.
> As such, one can simply setsockopt(ipv6_socket, SOL_IP, IP_TOS, value=
).

That's my whole point, this operation isn't currently possible, the
socket ops for ipv4 setsockopt() aren't hooked up to ipv6 mapped
sockets in the kernel right now.
