From: Vincent Bernat <vincent@bernat.im>
Subject: Re: [PATCH net-next v2] bridge: also trigger RTM_NEWLINK when interface is released from bridge
Date: Thu, 21 Sep 2017 00:12:53 +0200
Message-ID: <87bmm56mu2.fsf@luffy.cx>
References: <m3zi9vbrfp.fsf@luffy.cx>
        <20170916141833.28344-1-vincent@bernat.im>
        <20170920.140956.781667692297467325.davem@davemloft.net>
        <16e5566a-909d-ba83-7637-1fb6c93126bc@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: David Miller <davem@davemloft.net>, stephen@networkplumber.org,
        bridge@lists.linux-foundation.org, netdev@vger.kernel.org
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bart.luffy.cx ([78.47.78.131]:56321 "EHLO bart.luffy.cx"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751408AbdITWM4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 20 Sep 2017 18:12:56 -0400
In-Reply-To: <16e5566a-909d-ba83-7637-1fb6c93126bc@gmail.com> (David Ahern's
        message of "Wed, 20 Sep 2017 15:57:16 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 =E2=9D=A6 20 septembre 2017 15:57 -0600, David Ahern <dsahern@gmail.com>=
=C2=A0:

> The DELLINK is for AF_BRIDGE family (ifi_family). Adding family to
> print_linkinfo and running the monitor I get:
>
>
> [LINK]family 0: 35: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc
> noqueue master br0 state UNKNOWN group default
>     link/ether d6:c3:73:86:3c:73 brd ff:ff:ff:ff:ff:ff
>
> [LINK]family 7: 35: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500
> master br0 state UNKNOWN
>     link/ether d6:c3:73:86:3c:73
>
> [LINK]Deleted family 7: 35: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu
> 1500 master br0 state UNKNOWN
>     link/ether d6:c3:73:86:3c:73

I didn't know about the family. We can drop the patch.
--=20
One of the most striking differences between a cat and a lie is that a cat =
has
only nine lives.
		-- Mark Twain, "Pudd'nhead Wilson's Calendar"
