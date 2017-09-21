From: Vincent Bernat <vincent@bernat.im>
Subject: Re: [PATCH net-next v2] bridge: also trigger RTM_NEWLINK when interface is released from bridge
Date: Thu, 21 Sep 2017 12:04:15 +0200
Message-ID: <87h8vw5pwg.fsf@luffy.cx>
References: <m3zi9vbrfp.fsf@luffy.cx>
        <20170916141833.28344-1-vincent@bernat.im>
        <20170920.140956.781667692297467325.davem@davemloft.net>
        <16e5566a-909d-ba83-7637-1fb6c93126bc@gmail.com>
        <20170920162140.369bb198@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: David Ahern <dsahern@gmail.com>,
        David Miller <davem@davemloft.net>,
        bridge@lists.linux-foundation.org, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bart.luffy.cx ([78.47.78.131]:59367 "EHLO bart.luffy.cx"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751387AbdIUKEV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 21 Sep 2017 06:04:21 -0400
In-Reply-To: <20170920162140.369bb198@xeon-e3> (Stephen Hemminger's message of
        "Wed, 20 Sep 2017 16:21:40 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 =E2=9D=A6 20 septembre 2017 16:21 -0700, Stephen Hemminger <stephen@networ=
kplumber.org>=C2=A0:

> The one concern is that ports added or removed through ioctl should
> cause same events as doing the same thing via netlink. Some users use
> brctl (ioctl) and others use newer bridge (netlink) API.

I'll make a third iteration to have the same notifications when using
ioctl() with details in the commit message.
--=20
When in doubt, tell the truth.
		-- Mark Twain
