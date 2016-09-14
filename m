From: Vincent Bernat <vincent@bernat.im>
Subject: Re: [net v1] fib_rules: interface group matching
Date: Wed, 14 Sep 2016 14:43:59 +0200
Message-ID: <87wpieps6o.fsf@zoro.exoscale.ch>
References: <20160914124025.13417-1-vincent@bernat.im>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
        David Ahern <dsa@cumulusnetworks.com>,
        Wilson Kok <wkok@cumulusnetworks.com>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bart.luffy.cx ([78.47.78.131]:57221 "EHLO bart.luffy.cx"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756072AbcINMvS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Sep 2016 08:51:18 -0400
In-Reply-To: <20160914124025.13417-1-vincent@bernat.im> (Vincent Bernat's
        message of "Wed, 14 Sep 2016 14:40:25 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 =E2=9D=A6 14 septembre 2016 14:40 CEST, Vincent Bernat <vincent@bernat.im>=
=C2=A0:

> Each interface can be assigned to a numeric group using IFLA_GROUP. This
> commit enables a user to reference such a group into an IP rule. Here is
> an example of output of iproute2:
>
>     $ ip rule show
>     0:      from all lookup local
>     32764:  from all iifgroup 2 lookup 2
>     32765:  from all iifgroup 1 lookup 1
>     32766:  from all lookup main
>     32767:  from all lookup default

The patch for iproute2 is available here (didn't post it inline to avoid
confuse patchwork):
 http://paste.debian.net/821247/
--=20
Say what you mean, simply and directly.
            - The Elements of Programming Style (Kernighan & Plauger)
